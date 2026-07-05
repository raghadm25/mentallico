import React from 'react';
import '../StaticPages/tokens.css';
import './Legal.css';

const Terms = () => {
  return (
    <div className="static-page">
      <h1>Terms and Conditions</h1>
      <p className="static-subtitle legal-draft-note">
        Last updated: this is a draft template — please have it reviewed by legal counsel before relying on it.
      </p>

      <section>
        <h2>1. Acceptance of Terms</h2>
        <p>
          By creating an account or using Mentallico, you agree to these Terms and Conditions.
          If you do not agree, please do not use the platform.
        </p>
      </section>

      <section>
        <h2>2. Use of Service</h2>
        <p>
          Mentallico provides an AI chat assistant, an expert directory, a resource library, and a
          community feed. You agree to use these features respectfully and not to post content that
          is abusive, harmful, or violates the rights of others.
        </p>
      </section>

      <section>
        <h2>3. Medical Disclaimer</h2>
        <p>
          Mentallico, including its AI assistant, is not a substitute for professional medical advice,
          diagnosis, or treatment. Always seek the advice of a qualified mental health professional
          with any questions you may have. If you are experiencing a crisis, contact emergency
          services or a crisis hotline immediately.
        </p>
      </section>

      <section>
        <h2>4. User Responsibilities</h2>
        <p>
          You are responsible for the accuracy of the information you provide and for maintaining the
          confidentiality of your account credentials.
        </p>
      </section>

      <section>
        <h2>5. Limitation of Liability</h2>
        <p>
          Mentallico is provided "as is" without warranties of any kind. To the fullest extent
          permitted by law, Mentallico is not liable for any damages arising from your use of the
          platform.
        </p>
      </section>

      <section>
        <h2>6. Changes to These Terms</h2>
        <p>
          We may update these Terms from time to time. Continued use of Mentallico after changes
          constitutes acceptance of the updated Terms.
        </p>
      </section>

      <section>
        <h2>7. Contact</h2>
        <p>
          Questions about these Terms? Reach us at{' '}
          <a href="mailto:mentallico@gmail.com">mentallico@gmail.com</a>.
        </p>
      </section>
    </div>
  );
};

export default Terms;
