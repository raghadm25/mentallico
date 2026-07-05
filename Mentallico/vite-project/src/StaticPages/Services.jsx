import React from 'react';
import { Link } from 'react-router-dom';
import '../StaticPages/tokens.css';
import './Services.css';

const SERVICES = [
  {
    title: 'AI Chat Support',
    description: 'Talk anytime to an AI assistant trained to listen, reflect, and support you through difficult moments.',
    to: '/chat',
    cta: 'Start chatting',
  },
  {
    title: 'Therapist Directory',
    description: 'Search and book sessions with licensed mental health therapists across a range of specialties.',
    to: '/Therapists',
    cta: 'Meet our therapists',
  },
  {
    title: 'Resource Library',
    description: 'Curated books, podcasts, and exercises to help you understand and manage your mental health.',
    to: '/ResourcesCenter',
    cta: 'Browse resources',
  },
  {
    title: 'Community',
    description: 'Share your journey, connect with others who understand, and find support in a safe space.',
    to: '/Community',
    cta: 'Join the community',
  },
];

const Services = () => {
  return (
    <div className="static-page">
      <h1>Our Services</h1>
      <p className="static-subtitle">Everything Mentallico offers, in one place.</p>

      <div className="services-grid">
        {SERVICES.map((service) => (
          <Link to={service.to} className="service-card" key={service.title}>
            <h2>{service.title}</h2>
            <p>{service.description}</p>
            <span className="service-cta">{service.cta} →</span>
          </Link>
        ))}
      </div>
    </div>
  );
};

export default Services;
