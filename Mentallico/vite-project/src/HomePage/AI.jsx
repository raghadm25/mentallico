import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./AI.css";
import robotIcon from "../assets/Robot.png";
import personIcon from "../assets/Person.png";
import sendIcon from "../assets/Send.png";
import ellipse16 from "../assets/Ellipse 16.png";

const AI = () => {
  const navigate = useNavigate();
  const [input, setInput] = useState("");

  const handleSend = () => {
    const text = input.trim();
    if (!text) return;
    navigate('/chat', { state: { prefill: text } });
  };

  return (
    <section className="last-section-container">
      <h2 className="ls-header">Your AI Assistant, Always Ready</h2>

      <div className="last-section-card">
        
        
        
        <div className="chat-row bot-row">
          <img src={robotIcon} alt="AI" className="chat-icon" />
          <div className="chat-bubble bot-bubble">
            How are you feeling today?
          </div>
        </div>

        <div className="chat-row user-row">
          <div className="chat-bubble user-bubble">
            I’m feeling a little anxious
          </div>
          <img src={personIcon} alt="User" className="chat-icon" />
        </div>

        <div className="chat-row bot-row">
          <img src={robotIcon} alt="AI" className="chat-icon" />
          <div className="chat-bubble bot-bubble">
            I’m sorry to hear that. Let’s make you feel better! <br />
            Tell me about why you’re feeling that way and I can help with that.
          </div>
        </div>

        <div className="chat-input-area">
          <input
            type="text"
            placeholder="Type your message..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
          />


          <div>

              <button className="send-btn" onClick={handleSend}>

            <img src={sendIcon} alt="Send" />


          </button>
          </div>
        </div>

      </div>
      
      
      <img src={ellipse16} alt="" className="ellipse-16" />

    </section>
  );
};

export default AI;