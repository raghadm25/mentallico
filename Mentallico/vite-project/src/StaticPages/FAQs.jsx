import React, { useState } from 'react';
import '../StaticPages/tokens.css';
import './FAQs.css';

const QUESTIONS = [
  {
    q: 'What is Mentallico?',
    a: 'Mentallico is a mental wellness platform combining an AI chat assistant, a directory of licensed mental health experts, a curated resource library, and a supportive community feed.',
  },
  {
    q: 'Is the AI assistant a replacement for therapy?',
    a: 'No. The AI assistant is a supportive tool for everyday check-ins and reflection — it is not a licensed clinician and is not a substitute for professional diagnosis or treatment. If you are in crisis, please contact emergency services or a crisis hotline.',
  },
  {
    q: 'Is my data private?',
    a: 'Your chat conversations and profile information are stored securely and are only accessible to you. See our Privacy Policy for full details on what we collect and how it is used.',
  },
  {
    q: 'How do I book a session with a therapist?',
    a: 'Visit the Therapists page, search or filter by specialty, and click "Book Session" or "View Profile" on any therapist card to see availability and request a session.',
  },
  {
    q: 'Is Mentallico free to use?',
    a: 'Core features — the AI assistant, community feed, and resource library — are free. Booking a session directly with an expert may involve their own session fees, shown on their profile.',
  },
  {
    q: 'How do I delete my account?',
    a: 'Contact us at mentallico@gmail.com and we will process your deletion request in line with our Privacy Policy.',
  },
];

const FAQs = () => {
  const [openIndex, setOpenIndex] = useState(null);

  return (
    <div className="static-page">
      <h1>Frequently Asked Questions</h1>
      <p className="static-subtitle">Answers to what people ask us most.</p>

      <div className="faq-list">
        {QUESTIONS.map((item, index) => (
          <div key={item.q} className="faq-item">
            <button
              type="button"
              className="faq-question"
              onClick={() => setOpenIndex(openIndex === index ? null : index)}
            >
              {item.q}
              <span className="faq-toggle">{openIndex === index ? '−' : '+'}</span>
            </button>
            {openIndex === index && <p className="faq-answer">{item.a}</p>}
          </div>
        ))}
      </div>
    </div>
  );
};

export default FAQs;
