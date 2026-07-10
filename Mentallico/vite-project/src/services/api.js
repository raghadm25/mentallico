/**
 * Centralized API service layer.
 *
 * All requests go through the Vite dev-server proxy (/api → http://localhost:8000)
 * so there are no CORS preflight issues during local development.
 *
 * Token storage
 * -------------
 * login()     → stores access + refresh tokens in localStorage
 * logout()    → clears both tokens
 * getToken()  → returns the current access token (or null)
 *
 * Expired-token handling
 * -----------------------
 * Every authenticated request that comes back 401 is retried exactly once
 * after silently exchanging the refresh token for a new access token
 * (POST /auth/token/refresh/). If that also fails — refresh token missing,
 * expired, or blacklisted — the session is cleared and the browser is sent
 * to /login instead of surfacing a raw "token not valid" error to the user.
 *
 * Chat session storage
 * --------------------
 * The active session_id is kept in localStorage so it survives page refreshes.
 */

// In local dev this stays relative ("/api/v1") and rides Vite's dev-server
// proxy (vite.config.js) straight to Django — no CORS preflight needed.
// A production static build has no such proxy, so VITE_API_BASE_URL must be
// set to the deployed backend's absolute origin (e.g. https://mentallico-api.onrender.com).
const BASE_URL = `${import.meta.env.VITE_API_BASE_URL || ""}/api/v1`;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getToken() {
  return localStorage.getItem("access_token");
}

/**
 * Decode the payload section of a JWT without any external library.
 * Returns null if the token is malformed.
 */
function parseJwt(token) {
  try {
    const base64 = token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(base64));
  } catch {
    return null;
  }
}

/**
 * Return the stored display name, or null if the user is not logged in.
 * Reads directly from localStorage so it works across page refreshes.
 */
export function getStoredUserName() {
  return localStorage.getItem("user_name") || null;
}

/** Return the stored profile picture URL, or null if none is cached yet. */
export function getStoredUserAvatar() {
  return localStorage.getItem("user_avatar") || null;
}

function buildHeaders(extraHeaders = {}) {
  const headers = { "Content-Type": "application/json", ...extraHeaders };
  const token = getToken();
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }
  return headers;
}

/** Auth-only headers, no Content-Type — the browser sets the multipart boundary itself. */
function buildFormDataHeaders() {
  const headers = {};
  const token = getToken();
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }
  return headers;
}

async function handleResponse(res) {
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const message =
      data?.detail ||
      data?.non_field_errors?.[0] ||
      Object.values(data)?.[0]?.[0] ||
      `Request failed (${res.status})`;
    throw new Error(message);
  }
  return data;
}

/**
 * Exchange the stored refresh token for a new access token.
 * @returns {boolean} true if a new access token was obtained and stored.
 */
async function tryRefreshAccessToken() {
  const refreshToken = localStorage.getItem("refresh_token");
  if (!refreshToken) return false;

  try {
    const res = await fetch(`${BASE_URL}/auth/token/refresh/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh: refreshToken }),
    });
    if (!res.ok) return false;
    const data = await res.json();
    localStorage.setItem("access_token", data.access);
    return true;
  } catch {
    return false;
  }
}

/** Session is unrecoverable — clear it and send the user to log back in. */
function handleAuthFailure() {
  logout();
  if (typeof window !== "undefined" && !window.location.pathname.startsWith("/login")) {
    window.location.href = "/login";
  }
}

/**
 * Core request function. Every helper below (post/get/del/patch/put and
 * their FormData variants) funnels through this so expired-token recovery
 * only has to be implemented once.
 *
 * @param {string} method
 * @param {string} path
 * @param {{ json?: any, formData?: FormData, isRetry?: boolean }} options
 */
async function request(method, path, { json, formData, isRetry = false } = {}) {
  const hadToken = !!getToken();
  const headers = formData !== undefined ? buildFormDataHeaders() : buildHeaders();
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: formData !== undefined ? formData : json !== undefined ? JSON.stringify(json) : undefined,
  });

  // Only treat a 401 as "your session expired" when we actually sent a
  // token — an unauthenticated 401 (e.g. a bad login attempt) is a normal
  // error the caller should see, not a session recovery situation.
  if (res.status === 401 && hadToken && !isRetry) {
    const refreshed = await tryRefreshAccessToken();
    if (refreshed) {
      return request(method, path, { json, formData, isRetry: true });
    }
    handleAuthFailure();
    throw new Error("Your session has expired. Please log in again.");
  }

  if (res.status === 204) return null;
  return handleResponse(res);
}

async function post(path, body) {
  return request("POST", path, { json: body });
}

async function get(path) {
  return request("GET", path);
}

async function del(path) {
  return request("DELETE", path);
}

async function patch(path, body) {
  return request("PATCH", path, { json: body });
}

async function put(path, body) {
  return request("PUT", path, { json: body });
}

async function postFormData(path, formData) {
  return request("POST", path, { formData });
}

async function patchFormData(path, formData) {
  return request("PATCH", path, { formData });
}

/** True if an access token is stored, i.e. the user is logged in. */
export function isLoggedIn() {
  return !!getToken();
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

/**
 * Register a new account.
 * Maps the single "name" field from the signup form to first_name / last_name.
 *
 * @param {string} name
 * @param {string} email
 * @param {string} password
 * @param {string} passwordConfirm
 */
export async function register(name, email, password, passwordConfirm) {
  const parts = name.trim().split(" ");
  const firstName = parts[0] || name;
  const lastName = parts.slice(1).join(" ") || ".";

  return post("/auth/register/", {
    first_name: firstName,
    last_name: lastName,
    email,
    password,
    password_confirm: passwordConfirm,
  });
}

/**
 * Store JWT tokens + derived display name/email from the access token's
 * payload, so every component can read them from localStorage without an
 * extra /profile/ round trip. Shared by every way of establishing a session
 * (password login, Google sign-in, ...).
 */
function storeAuthTokens(data) {
  localStorage.setItem("access_token", data.access);
  localStorage.setItem("refresh_token", data.refresh);

  const payload = parseJwt(data.access);
  const displayName =
    payload?.full_name?.trim() ||
    payload?.email?.split("@")[0] ||
    "User";
  localStorage.setItem("user_name", displayName);
  if (payload?.email) {
    localStorage.setItem("user_email", payload.email);
  }
}

/**
 * Log in and store JWT tokens.
 *
 * @param {string} email
 * @param {string} password
 * @returns {{ access: string, refresh: string }}
 */
export async function login(email, password) {
  const data = await post("/auth/login/", { email, password });
  storeAuthTokens(data);
  return data;
}

/**
 * Exchange a Google OAuth2 access token (from Google Identity Services) for
 * this app's own JWT pair. Works for both sign-up and login — the backend
 * gets-or-creates the account by email either way.
 *
 * @param {string} googleAccessToken
 * @returns {{ access: string, refresh: string, created: boolean }}
 */
export async function loginWithGoogle(googleAccessToken) {
  const data = await post("/auth/google/", { access_token: googleAccessToken });
  storeAuthTokens(data);
  return data;
}

/**
 * Exchange a Facebook OAuth2 access token (from the Facebook JS SDK's
 * FB.login()) for this app's own JWT pair. Same get-or-create-by-email
 * behavior as loginWithGoogle.
 *
 * @param {string} facebookAccessToken
 * @returns {{ access: string, refresh: string, created: boolean }}
 */
export async function loginWithFacebook(facebookAccessToken) {
  const data = await post("/auth/facebook/", { access_token: facebookAccessToken });
  storeAuthTokens(data);
  return data;
}

/** Return the stored email, or null if the user is not logged in. */
export function getStoredUserEmail() {
  const stored = localStorage.getItem("user_email");
  if (stored) return stored;

  // Sessions started before this field existed won't have it cached yet —
  // fall back to decoding it from the current token and backfill for next time.
  const token = getToken();
  const email = token ? parseJwt(token)?.email : null;
  if (email) {
    localStorage.setItem("user_email", email);
    return email;
  }
  return null;
}

/** Clear all stored auth data and session state. */
export function logout() {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  localStorage.removeItem("session_id");
  localStorage.removeItem("user_name");
  localStorage.removeItem("user_email");
  localStorage.removeItem("user_avatar");
}

// ---------------------------------------------------------------------------
// Account / profile
// ---------------------------------------------------------------------------

/** @returns the logged-in user's profile (id, email, first_name, last_name, full_name, date_of_birth, gender, phone_number, profile_picture, bio, date_joined) */
export async function getProfile() {
  const data = await get("/auth/profile/");
  syncStoredProfileCache(data);
  return data;
}

/**
 * Partially update the logged-in user's profile (text fields only).
 * @param {object} fields e.g. { first_name, last_name, bio, phone_number, date_of_birth, gender }
 */
export async function updateProfile(fields) {
  const data = await patch("/auth/profile/", fields);
  syncStoredProfileCache(data);
  return data;
}

/**
 * Partially update the profile including a new profile picture.
 * @param {object} fields text fields to update alongside the picture
 * @param {File} file the new profile picture
 */
export async function updateProfileWithPicture(fields, file) {
  const formData = new FormData();
  Object.entries(fields).forEach(([key, value]) => {
    if (value !== undefined && value !== null) formData.append(key, value);
  });
  formData.append("profile_picture", file);
  const data = await patchFormData("/auth/profile/", formData);
  syncStoredProfileCache(data);
  return data;
}

/**
 * Keep the cached display name / avatar in sync with the backend so every
 * page (Navbar, ChatBot sidebar, etc.) reflects profile changes immediately,
 * without each of them having to call getProfile() first.
 */
function syncStoredProfileCache(profile) {
  const displayName = `${profile.first_name || ""} ${profile.last_name || ""}`.trim();
  if (displayName) {
    localStorage.setItem("user_name", displayName);
  }
  if (profile.profile_picture) {
    localStorage.setItem("user_avatar", profile.profile_picture);
  } else {
    localStorage.removeItem("user_avatar");
  }
}

/**
 * Change the logged-in user's password.
 * @param {string} oldPassword
 * @param {string} newPassword
 * @param {string} newPasswordConfirm
 */
export async function changePassword(oldPassword, newPassword, newPasswordConfirm) {
  return put("/auth/change-password/", {
    old_password: oldPassword,
    new_password: newPassword,
    new_password_confirm: newPasswordConfirm,
  });
}

// ---------------------------------------------------------------------------
// Chat
// ---------------------------------------------------------------------------

/**
 * Start a new chat session.
 * Persists the session_id to localStorage.
 *
 * @returns {string} session_id
 */
export async function startSession() {
  const data = await post("/chat/start/", {});
  localStorage.setItem("session_id", data.session_id);
  return data.session_id;
}

// Shared in-flight promise so two near-simultaneous callers (e.g. React 18
// StrictMode double-invoking effects in development) can't each see "no
// session yet" and race to create two separate sessions.
let pendingSessionCreation = null;

/** Retrieve (or lazily create) the active session_id. */
export async function getOrCreateSession() {
  const existing = localStorage.getItem("session_id");
  if (existing) return existing;

  if (!pendingSessionCreation) {
    pendingSessionCreation = startSession().finally(() => {
      pendingSessionCreation = null;
    });
  }
  return pendingSessionCreation;
}

/**
 * Send a user message and receive a bot reply.
 *
 * @param {string} sessionId
 * @param {string} message
 * @returns {{ user_message, bot_message }}
 *   Each message: { id: string, text: string, sender: "user"|"bot", type: "text" }
 */
export async function sendMessage(sessionId, message) {
  return post("/chat/send/", { session_id: sessionId, message });
}

/**
 * Load full message history for a session.
 *
 * @param {string} sessionId
 * @returns {{ session_id, title, status, messages: Array }}
 */
export async function loadHistory(sessionId) {
  return get(`/chat/history/${sessionId}/`);
}

/**
 * List the logged-in user's chat sessions, newest first (requires login).
 * @returns {Array} sessions ({ id, title, status, message_count, started_at, ... })
 */
export async function listSessions() {
  const data = await get("/chat/sessions/");
  return data.results ?? data;
}

/** Delete a chat session (requires login; blocked server-side if already analyzed). */
export async function deleteSession(sessionId) {
  return del(`/chat/sessions/${sessionId}/`);
}

// ---------------------------------------------------------------------------
// Community feed
// ---------------------------------------------------------------------------

/** @returns {Array} posts, newest first, each with like_count/comment_count/is_liked/is_saved */
export async function listPosts() {
  const data = await get("/community/posts/");
  return data.results ?? data;
}

/**
 * Create a new post as the logged-in user.
 * @param {string} content
 * @param {File} [imageFile] optional attached image
 */
export async function createPost(content, imageFile) {
  if (imageFile) {
    const formData = new FormData();
    formData.append("content", content);
    formData.append("image", imageFile);
    return postFormData("/community/posts/", formData);
  }
  return post("/community/posts/", { content });
}

/** Toggle like on a post. @returns {{ liked: boolean, like_count: number }} */
export async function toggleLike(postId) {
  return post(`/community/posts/${postId}/like/`, {});
}

/** Toggle "save to collection" on a post. @returns {{ saved: boolean }} */
export async function toggleSavePost(postId) {
  return post(`/community/posts/${postId}/save/`, {});
}

/** @returns {Array} comments for a post, oldest first */
export async function listComments(postId) {
  return get(`/community/posts/${postId}/comments/`);
}

/** Add a comment as the logged-in user. */
export async function addComment(postId, content) {
  return post(`/community/posts/${postId}/comments/`, { content });
}

/** Delete a post. Only the post's own author may do this (enforced server-side). */
export async function deletePost(postId) {
  return del(`/community/posts/${postId}/`);
}

/** @returns {Array} the logged-in user's saved posts, newest-saved first */
export async function listSavedPosts() {
  const data = await get("/community/posts/saved/");
  return data.results ?? data;
}

// ---------------------------------------------------------------------------
// Resources — saved articles
// ---------------------------------------------------------------------------

/** @returns {Array} published articles carrying the given tag */
export async function listResourcesByTag(tag) {
  const data = await get(`/resources/articles/?tag=${encodeURIComponent(tag)}`);
  return data.results ?? data;
}

/** @returns {Array} the logged-in user's saved articles ({ id, article: {...}, saved_at }) */
export async function listSavedResources() {
  const data = await get("/resources/saved/");
  return data.results ?? data;
}

/** Bookmark an article. @returns the new SavedResource ({ id, article, ... }) */
export async function saveResource(articleId) {
  return post("/resources/saved/", { article_id: articleId });
}

/** Remove a bookmark by its SavedResource id (not the article id). */
export async function unsaveResource(savedResourceId) {
  return del(`/resources/saved/${savedResourceId}/`);
}

// ---------------------------------------------------------------------------
// Wellness — mood calendar, journal entries, habits
// ---------------------------------------------------------------------------

/** @returns {{ year, month, entries: Array<{id, date, mood}> }} every mood logged that month */
export async function getMoodCalendar(year, month) {
  return get(`/wellness/moods/?year=${year}&month=${month}`);
}

/**
 * Log (or overwrite) a day's mood — one per user per day.
 * @param {string} mood one of MoodEntry.MoodChoices
 * @param {string} [date] ISO date, defaults to today server-side
 */
export async function logMood(mood, date) {
  return post("/wellness/moods/", date ? { mood, date } : { mood });
}

/** Removes a day's logged mood entirely. */
export async function deleteMood(date) {
  return del(`/wellness/moods/${date}/`);
}

/** @returns {{ start, end, entries: Array<{id, date, content}> }} journal entries in a date range */
export async function getJournalWeek(startDate, days = 7) {
  return get(`/wellness/journal/?start=${startDate}&days=${days}`);
}

/** @returns {{ date, content }} the entry for one day, content is null if none was written */
export async function getJournalEntry(date) {
  return get(`/wellness/journal/${date}/`);
}

/** Create or overwrite the journal entry for a given day. */
export async function saveJournalEntry(date, content) {
  return post(`/wellness/journal/${date}/`, { content });
}

/** @returns {Array} the user's habits, each with is_completed_today and completion_rate */
export async function listHabits() {
  return get("/wellness/habits/");
}

/** Get-or-create a habit by name for the current user. @returns the habit summary */
export async function createOrGetHabit(name, iconKey) {
  return post("/wellness/habits/", { name, icon_key: iconKey });
}

/** Toggle today's completion for a habit. @returns the updated habit summary */
export async function toggleHabit(habitId) {
  return post(`/wellness/habits/${habitId}/toggle/`, {});
}

/** Soft-deletes a habit (drops it from the user's tracked list). */
export async function deleteHabit(habitId) {
  return del(`/wellness/habits/${habitId}/`);
}

/** Directly sets a habit's manual progress (0-100). @returns the updated habit summary */
export async function updateHabitProgress(habitId, progress) {
  return patch(`/wellness/habits/${habitId}/`, { progress });
}
