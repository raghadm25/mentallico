import React from 'react';
import '../StaticPages/tokens.css';
import './Legal.css';

const Privacy = () => {
  return (
    <div className="static-page">
      <h1>Privacy Policy</h1>
      <p className="static-subtitle legal-draft-note">
        Last updated: this is a draft template — please have it reviewed by legal counsel before relying on it.
      </p>

      <section>
        <h2>1. Data We Collect</h2>
        <p>
          We collect the information you provide when you register (name, email), the messages you
          send in chat sessions, community posts and comments you create, and articles you save.
        </p>
      </section>

      <section>
        <h2>2. How We Use It</h2>
        <p>
          Your data is used to provide the service — running your chat sessions, displaying your
          posts, and keeping your saved collection. We do not sell your personal data.
        </p>
      </section>

      <section>
        <h2>3. Third-Party Services</h2>
        <p>
          Chat messages are processed by a third-party AI model hosted on Hugging Face to generate
          responses. Your chat history is stored in our database so conversations keep context across
          messages.
        </p>
      </section>

      <section>
        <h2>4. Cookies &amp; Local Storage</h2>
        <p>
          We use your browser's local storage (not cookies) to keep you signed in — this stores your
          access and refresh tokens, your display name, and your active chat session id. Clearing your
          browser's local storage will sign you out.
        </p>
      </section>

      <section>
        <h2>5. Data Retention</h2>
        <p>
          Your data is retained while your account is active. You may request deletion of your account
          and associated data at any time.
        </p>
      </section>

      <section>
        <h2>6. Your Rights</h2>
        <p>
          You can view and update your profile information at any time from your account settings, and
          you can request a copy or deletion of your data by contacting us.
        </p>
      </section>

      <section>
        <h2>7. Contact</h2>
        <p>
          Questions about this policy? Reach us at{' '}
          <a href="mailto:mentallico@gmail.com">mentallico@gmail.com</a>.
        </p>
      </section>
    </div>
  );
};

export default Privacy;
