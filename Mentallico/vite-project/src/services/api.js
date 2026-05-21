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
 * Chat session storage
 * --------------------
 * The active session_id is kept in localStorage so it survives page refreshes.
 */

const BASE_URL = "/api/v1";

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

function buildHeaders(extraHeaders = {}) {
  const headers = { "Content-Type": "application/json", ...extraHeaders };
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

async function post(path, body) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: "POST",
    headers: buildHeaders(),
    body: JSON.stringify(body),
  });
  return handleResponse(res);
}

async function get(path) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: "GET",
    headers: buildHeaders(),
  });
  return handleResponse(res);
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
 * Log in and store JWT tokens.
 *
 * @param {string} email
 * @param {string} password
 * @returns {{ access: string, refresh: string }}
 */
export async function login(email, password) {
  const data = await post("/auth/login/", { email, password });
  localStorage.setItem("access_token", data.access);
  localStorage.setItem("refresh_token", data.refresh);

  // The backend encodes full_name inside the JWT payload.
  // Decode it here so every component can read it from localStorage
  // without making an extra /profile/ API call.
  const payload = parseJwt(data.access);
  const displayName =
    payload?.full_name?.trim() ||
    payload?.email?.split("@")[0] ||
    "User";
  localStorage.setItem("user_name", displayName);

  return data;
}

/** Clear all stored auth data and session state. */
export function logout() {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  localStorage.removeItem("session_id");
  localStorage.removeItem("user_name");
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

/** Retrieve (or lazily create) the active session_id. */
export async function getOrCreateSession() {
  const existing = localStorage.getItem("session_id");
  if (existing) return existing;
  return startSession();
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
