import React, { useState, useEffect, useRef } from 'react';
import './ChatBot.css';
import {
  getOrCreateSession,
  startSession,
  sendMessage,
  loadHistory,
} from '../services/api';

const ChatBot = () => {
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState([]);
  const [sessionId, setSessionId] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const [isRecording, setIsRecording] = useState(false);

  const mediaRecorder = useRef(null);
  const audioChunks = useRef([]);
  const messagesEndRef = useRef(null);

  // -------------------------------------------------------------------------
  // On mount: restore or create a session, then load its history
  // -------------------------------------------------------------------------
  useEffect(() => {
    const initSession = async () => {
      try {
        const id = await getOrCreateSession();
        setSessionId(id);

        const history = await loadHistory(id);
        if (history.messages.length > 0) {
          setMessages(history.messages);
        } else {
          // Show the welcome message for a brand-new session
          setMessages([
            {
              id: 'welcome',
              text: "Hello! I am your mental health assistant. How are you feeling today?",
              sender: 'bot',
              type: 'text',
            },
          ]);
        }
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
  }, []);

  // Auto-scroll to latest message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // -------------------------------------------------------------------------
  // Send a text message
  // -------------------------------------------------------------------------
  const handleSend = async () => {
    if (!input.trim() || isLoading || !sessionId) return;

    const userText = input.trim();
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
    } catch (err) {
      setError(err.message || "Failed to send message. Please try again.");
      // Remove the optimistic message on failure
      setMessages((prev) => prev.filter((m) => m.id !== optimisticMsg.id));
    } finally {
      setIsLoading(false);
    }
  };

  // -------------------------------------------------------------------------
  // Start a fresh session
  // -------------------------------------------------------------------------
  const handleNewChat = async () => {
    try {
      const id = await startSession();
      setSessionId(id);
      setMessages([
        {
          id: 'welcome',
          text: "Hello! I am your mental health assistant. How are you feeling today?",
          sender: 'bot',
          type: 'text',
        },
      ]);
      setError(null);
    } catch (err) {
      setError("Could not start a new session.");
    }
  };

  // -------------------------------------------------------------------------
  // Voice recording (client-side only — no backend integration yet)
  // -------------------------------------------------------------------------
  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      mediaRecorder.current = new MediaRecorder(stream);
      audioChunks.current = [];
      mediaRecorder.current.ondataavailable = (e) => audioChunks.current.push(e.data);
      mediaRecorder.current.onstop = () => {
        const audioBlob = new Blob(audioChunks.current, { type: 'audio/wav' });
        const audioUrl = URL.createObjectURL(audioBlob);
        setMessages((prev) => [
          ...prev,
          { id: Date.now(), audio: audioUrl, sender: 'user', type: 'voice' },
        ]);
      };
      mediaRecorder.current.start();
      setIsRecording(true);
    } catch {
      alert("Microphone access was denied.");
    }
  };

  const stopRecording = () => {
    if (mediaRecorder.current) {
      mediaRecorder.current.stop();
      setIsRecording(false);
    }
  };

  // -------------------------------------------------------------------------
  // Sidebar history (static placeholder — replace with real session list API)
  // -------------------------------------------------------------------------
  const history = [
    "How To Get Over The Feeling Of Guilt?",
    "Best Books To Read About Personal Growth",
    "Daily Fights With Chronic Illness",
    "Feeling Misunderstood",
  ];

  // -------------------------------------------------------------------------
  // Render
  // -------------------------------------------------------------------------
  return (
    <div className="chat-page-container">
      {/* Sidebar */}
      <aside className="sidebar">
        <h2 className="logo">Mentallico</h2>
        <div className="search-box">
          <input type="text" placeholder="Search History" />
        </div>
        <nav className="history-list">
          <p className="section-title">Chat History</p>
          {history.map((item, index) => (
            <div key={index} className="history-item">{item}</div>
          ))}
        </nav>
        <div className="user-profile">
          <img
            src="https://xsgames.co/randomusers/assets/avatars/female/7.jpg"
            alt="user"
          />
          <div className="user-info">
            <p className="user-name">Jane Doe</p>
          </div>
        </div>
      </aside>

      {/* Main chat area */}
      <main className="main-chat">
        <header className="chat-nav">
          <button className="new-chat-btn" onClick={handleNewChat}>
            New Chat
          </button>
        </header>

        <div className="chat-content">
          <h1 className="welcome-text">I&apos;m Here To Listen.</h1>

          {/* Error banner */}
          {error && (
            <div className="error-banner" style={{ color: '#c0392b', padding: '8px 0' }}>
              {error}
            </div>
          )}

          {/* Messages */}
          <div className="messages-container">
            {messages.map((msg) => (
              <div key={msg.id} className={`msg ${msg.sender}-msg`}>
                <div className="bubble">
                  {msg.type === 'text'
                    ? msg.text
                    : <audio src={msg.audio} controls />}
                </div>
              </div>
            ))}

            {/* Typing indicator while waiting for bot reply */}
            {isLoading && (
              <div className="msg bot-msg">
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
            <div className="action-buttons">
              <button
                className={`mic-btn ${isRecording ? 'active' : ''}`}
                onMouseDown={startRecording}
                onMouseUp={stopRecording}
              >
                🎤
              </button>
              <button
                className="send-btn"
                onClick={handleSend}
                disabled={isLoading}
              >
                ➤
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default ChatBot;
