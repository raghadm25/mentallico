import React from "react";
import "./OurStory.css";

const OurStory = () => {
 return (
    <section className="our-story-section">
      {/* Ellipse 18 - Secondary (بنفسجي) */}
      <div className="ellipse-blur ellipse-18"></div>

      <div className="our-story-container">
        <h2 className="story-title">Our Story</h2>

        <div className="story-content">
          <p className="story-paragraph">
            <span className="fancy-letter">W</span>e started this journey after
            seeing how many people around us struggled in silence. Between long
            waiting times, stigma, and lack of resources, getting mental health
            support often felt impossible. We wanted to change that.
          </p>

          <p className="story-paragraph">
            That's when the idea was born. What if there was a way to bring
            support closer? To combine the power of technology with the
            compassion of real human therapists? What if anyone, anywhere, could
            access a safe space instantly, without fear or shame?{" "}
            <span className="story-link">Mentallico</span> grew out of that dream
            — to bridge the gap between AI-driven support and human care,
            creating a platform that's immediate, affordable, and stigma-free.
          </p>
        </div>
      </div>
    </section>
  );
};

export default OurStory;