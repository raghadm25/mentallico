import React, { useState, useEffect, useRef } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { useAudioRecorder } from './useAudioRecorder';
import './ChatBot.css';
import {
  getOrCreateSession,
  startSession,
  sendMessage,
  loadHistory,
  listSessions,
  deleteSession,
  isLoggedIn,
  getStoredUserName,
  getStoredUserEmail,
  getStoredUserAvatar,
  getProfile,
  logout,
} from '../services/api';
import robotIcon from '../assets/Robot.png';
import personIcon from '../assets/Person.png';
import sendIcon from '../assets/send.png';
import searchIcon from '../assets/search-icon.png';

const SUGGESTIONS = [
  'Try A Breathing Exercise',
  'I Feel Anxious And Want To Calm Down',
  'I Just Need To Vent',
  'Help Me Understand My Mood',
  'I Want To Learn How To Say No.',
];

const ChatBot = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [input, setInput] = useState(location.state?.prefill || "");
  const [messages, setMessages] = useState([]);
  const [sessionId, setSessionId] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [menuOpen, setMenuOpen] = useState(false);

  const [sessions, setSessions] = useState([]);
  const [sessionsLoading, setSessionsLoading] = useState(false);
  const [avatarUrl, setAvatarUrl] = useState(() => getStoredUserAvatar());
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const loggedIn = isLoggedIn();

  // Called directly from inside mediaRecorder.onstop (see useAudioRecorder),
  // only once the Blob and its corrected duration are fully ready — never
  // before. This is the entire "send" action for a voice message.
  const handleRecordingComplete = (audioUrl) => {
    setMessages((prev) => [
      ...prev,
      { id: Date.now(), audio: audioUrl, sender: 'user', type: 'voice' },
    ]);
  };

  const recorder = useAudioRecorder({ onRecordingComplete: handleRecordingComplete });
  const messagesEndRef = useRef(null);

  // Surface any recording error (denied permission, no mic, etc.) in the
  // same error banner the rest of the page already uses.
  useEffect(() => {
    if (recorder.error) setError(recorder.error);
  }, [recorder.error]);

  // -------------------------------------------------------------------------
  // On mount: restore or create a session, then load its history
  // -------------------------------------------------------------------------
  useEffect(() => {
    const initSession = async () => {
      try {
        const id = await getOrCreateSession();
        setSessionId(id);

        const history = await loadHistory(id);
        setMessages(history.messages);
      } catch (err) {
        // Surface the real error so it is visible during development.
        // Common causes: Django not running, migrations not applied, CORS issue.
        const detail = err?.message || String(err);
        setError(
          `Could not connect to the server. ${detail} — ` +
          "Make sure Django is running on http://127.0.0.1:8000 and " +
          "migrations have been applied (python manage.py migrate)."
        );
      }
    };

    initSession();
    refreshSessions();

    // Keep the sidebar photo in sync with whatever is set on the account —
    // getProfile() also refreshes the localStorage cache used for the
    // instant first paint above.
    if (loggedIn) {
      getProfile()
        .then((data) => setAvatarUrl(data.profile_picture || null))
        .catch(() => {});
    }
  }, []);

  // Auto-scroll to latest message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // -------------------------------------------------------------------------
  // Sidebar chat history — real sessions for logged-in users
  // -------------------------------------------------------------------------
  const refreshSessions = async () => {
    if (!isLoggedIn()) return;
    setSessionsLoading(true);
    try {
      const list = await listSessions();
      setSessions(list);
    } catch {
      // Non-critical — the sidebar just stays empty if this fails.
    } finally {
      setSessionsLoading(false);
    }
  };

  const handleSelectSession = async (session) => {
    setSidebarOpen(false);
    if (session.id === sessionId) return;
    setError(null);
    try {
      const history = await loadHistory(session.id);
      setSessionId(session.id);
      localStorage.setItem('session_id', session.id);
      setMessages(history.messages);
    } catch (err) {
      setError(err.message || 'Could not load that conversation.');
    }
  };

  // -------------------------------------------------------------------------
  // Send a text message
  // -------------------------------------------------------------------------
  const sendText = async (rawText) => {
    const userText = rawText.trim();
    if (!userText || isLoading || !sessionId) return;

    setInput("");
    setError(null);

    // Optimistically show the user message immediately
    const optimisticMsg = {
      id: `temp-${Date.now()}`,
      text: userText,
      sender: 'user',
      type: 'text',
    };
    setMessages((prev) => [...prev, optimisticMsg]);
    setIsLoading(true);

    try {
      const data = await sendMessage(sessionId, userText);

      // Replace the optimistic message with the confirmed one, then add bot reply
      setMessages((prev) => [
        ...prev.filter((m) => m.id !== optimisticMsg.id),
        data.user_message,
        data.bot_message,
      ]);
      refreshSessions();
    } catch (err) {
      setError(err.message || "Failed to send message. Please try again.");
      // Remove the optimistic message on failure
      setMessages((prev) => prev.filter((m) => m.id !== optimisticMsg.id));
    } finally {
      setIsLoading(false);
    }
  };

  const handleSend = () => sendText(input);
  const handleSuggestionClick = (text) => sendText(text);

  // -------------------------------------------------------------------------
  // Start a fresh session
  // -------------------------------------------------------------------------
  const [creatingChat, setCreatingChat] = useState(false);

  const handleNewChat = async () => {
    if (creatingChat) return;
    setCreatingChat(true);
    try {
      const id = await startSession();
      setSessionId(id);
      setMessages([]);
      setError(null);
      refreshSessions();
    } catch (err) {
      setError("Could not start a new session.");
    } finally {
      setCreatingChat(false);
    }
    setMenuOpen(false);
    setSidebarOpen(false);
  };

  // -------------------------------------------------------------------------
  // "•••" menu — delete current chat, log out
  // -------------------------------------------------------------------------
  const handleDeleteChat = async () => {
    setMenuOpen(false);
    if (!sessionId) return;
    try {
      await deleteSession(sessionId);
      await handleNewChat();
    } catch (err) {
      setError(err.message || 'Could not delete this chat.');
    }
  };

  const handleLogout = () => {
    setMenuOpen(false);
    logout();
    navigate('/login');
  };

  const hasMessages = messages.length > 0;
  const displayName = getStoredUserName() || 'Guest';
  const displayEmail = getStoredUserEmail() || (loggedIn ? '' : 'Not logged in');

  // -------------------------------------------------------------------------
  // Render
  // -------------------------------------------------------------------------
  return (
    <div className="chat-page-container">
      {/* Mobile-only backdrop, shown behind the sidebar drawer when open */}
      {sidebarOpen && (
        <div className="sidebar-backdrop" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <aside className={`sidebar${sidebarOpen ? ' open' : ''}`}>
        <h2 className="chatbot-logo">Mentallico</h2>
        <div className="search-box">
          <img src={searchIcon} alt="" className="chatbot-search-icon" />
          <input type="text" placeholder="Chat History" />
        </div>
        <nav className="history-list">
          {!loggedIn && (
            <p className="history-empty-hint">Log in to see your chat history.</p>
          )}
          {loggedIn && sessionsLoading && (
            <p className="history-empty-hint">Loading…</p>
          )}
          {loggedIn && !sessionsLoading && sessions.length === 0 && (
            <p className="history-empty-hint">No previous chats yet.</p>
          )}
          {loggedIn && sessions.map((session) => (
            <button
              key={session.id}
              type="button"
              className={`history-item${session.id === sessionId ? ' active' : ''}`}
              onClick={() => handleSelectSession(session)}
            >
              {session.title || 'New conversation'}
            </button>
          ))}
        </nav>
        <button type="button" className="sidebar-profile" onClick={() => navigate('/UserProfile')}>
          <img
            src={avatarUrl || 'https://www.w3schools.com/howto/img_avatar.png'}
            alt="user"
          />
          <div className="sidebar-profile-info">
            <p className="sidebar-profile-name">{displayName}</p>
            <p className="sidebar-profile-email">{displayEmail}</p>
          </div>
        </button>
      </aside>

      {/* Main chat area */}
      <main className="main-chat">
        <header className="chat-nav">
          <button
            type="button"
            className="sidebar-toggle-btn"
            aria-label={sidebarOpen ? 'Close chat history' : 'Open chat history'}
            onClick={() => setSidebarOpen((open) => !open)}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M3 6h18M3 12h18M3 18h18" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <button className="new-chat-btn" onClick={handleNewChat} disabled={creatingChat}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span>New Chat</span>
          </button>
          <div className="more-menu-wrapper">
            <button className="more-btn" aria-label="More options" onClick={() => setMenuOpen((open) => !open)}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                <circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>
              </svg>
            </button>
            {menuOpen && (
              <>
                <div className="more-menu-backdrop" onClick={() => setMenuOpen(false)} />
                <div className="more-menu">
                  <button type="button" onClick={handleDeleteChat} disabled={!sessionId}>
                    Delete this chat
                  </button>
                  {loggedIn && (
                    <button type="button" onClick={handleLogout}>
                      Log out
                    </button>
                  )}
                </div>
              </>
            )}
          </div>
        </header>

        {error && (
          <div className="error-banner">{error}</div>
        )}

        {!hasMessages ? (
          /* ── Empty state ─────────────────────────────────── */
          <div className="empty-state">
            <h1 className="empty-heading">
              I&apos;m Here To Listen And Help You Make Sense Of What&apos;s On Your Mind.
            </h1>
            <div className="empty-input-wrapper">
              <input
                type="text"
                placeholder="Type Your Text Here...."
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                disabled={isLoading}
              />
            </div>
            <div className="suggestion-chips">
              {SUGGESTIONS.map((s) => (
                <button
                  key={s}
                  className="suggestion-chip"
                  onClick={() => handleSuggestionClick(s)}
                  disabled={isLoading}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        ) : (
          /* ── Conversation ────────────────────────────────── */
          <div className="chat-content">
            <div className="messages-container">
              {messages.map((msg) => (
                <div key={msg.id} className={`msg ${msg.sender}-msg`}>
                  {msg.sender === 'bot' && <img src={robotIcon} alt="" className="msg-icon" />}
                  <div className="bubble">
                    {msg.type === 'text'
                      ? msg.text
                      : <audio src={msg.audio} controls />}
                  </div>
                  {msg.sender === 'user' && <img src={personIcon} alt="" className="msg-icon" />}
                </div>
              ))}

              {/* Typing indicator while waiting for bot reply */}
              {isLoading && (
                <div className="msg bot-msg">
                  <img src={robotIcon} alt="" className="msg-icon" />
                  <div className="bubble typing-indicator">
                    <span /><span /><span />
                  </div>
                </div>
              )}

              <div ref={messagesEndRef} />
            </div>

            {/* Input row */}
            <div className="input-wrapper">
              <input
                type="text"
                placeholder="Type Your Message Here"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                disabled={isLoading}
              />
              <div className="chatbot-action-buttons">
                {recorder.isRecording && (
                  <span className="mic-timer">{recorder.formattedTime}</span>
                )}
                <button
                  type="button"
                  className={`mic-btn ${recorder.isRecording ? 'active' : ''}`}
                  onClick={recorder.toggleRecording}
                  aria-label={recorder.isRecording ? 'Stop recording' : 'Record a voice message'}
                  title={recorder.isRecording ? 'Stop recording' : 'Record a voice message'}
                >
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M12 1a3 3 0 00-3 3v7a3 3 0 006 0V4a3 3 0 00-3-3z"/>
                    <path d="M19 10v1a7 7 0 01-14 0v-1M12 18v4M8 22h8" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                </button>
                <button
                  className="chatbot-send-btn"
                  onClick={handleSend}
                  disabled={isLoading}
                >
                  <img src={sendIcon} alt="Send" />
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default ChatBot;
