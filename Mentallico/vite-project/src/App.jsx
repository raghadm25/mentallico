import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";

import Navbar from "./HomePage/Navbar";
import Footer from "./HomePage/Footer";
import SignUp from "./log in/SignUp";
import Login from "./log in/login";

import AboutUs from "./AboutPage/AboutUs";
import OurStory from "./AboutPage/OurStory";
import OurValues from "./AboutPage/OurValues";
import Mission from "./AboutPage/Mission";
import Vision from "./AboutPage/Vision";
import Frame from "./AboutPage/Frame";

import Community from "./Community/Community";
import ResourcesCenter from "./Resources/ResourcesCenter";
import UserProfile from "./User Profile/UserProfile";

import FAQs from "./StaticPages/FAQs";
import Services from "./StaticPages/Services";
import Terms from "./StaticPages/Terms";
import Privacy from "./StaticPages/Privacy";
import Settings from "./StaticPages/Settings";
import EditProfile from "./StaticPages/EditProfile";
import SavedCollection from "./StaticPages/SavedCollection";

import Therapist from "./Therapists/Therapist";
import TherapistProfile from "./Therapists/TherapistProfile";

import MoodTracker from "./AI Assistant/MoodTracker";
import ChatBot from "./AI Assistant/ChatBot";

import Hero from "./HomePage/Hero";
import Quote from "./HomePage/Quote";
import Features from "./HomePage/Features";
import SecondSection from "./HomePage/Secondsection";
import ExpertsSection from "./HomePage/ExpertsSection";
import ReviewSection from "./HomePage/ReviewSection";
import AI from "./HomePage/AI";

import "./App.css";

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>

          {/* ── Home ─────────────────────────────────────────────────── */}
          <Route
            path="/"
            element={
              <>
                <Navbar />
                <Hero />
                <Quote />
                <Features />
                <SecondSection />
                <ExpertsSection />
                <ReviewSection />
                <AI />
                <Footer />
              </>
            }
          />

          {/* ── About ────────────────────────────────────────────────── */}
          <Route
            path="/about"
            element={
              <>
                <Navbar />
                <AboutUs />
                <OurStory />
                <OurValues />
                <Mission />
                <Vision />
                <Frame />
                <Footer />
              </>
            }
          />

          {/* ── Community ────────────────────────────────────────────── */}
          <Route
            path="/Community"
            element={
              <>
                <Navbar />
                <Community />
                <Footer />
              </>
            }
          />

          {/* ── Therapists ───────────────────────────────────────────── */}
          <Route
            path="/Therapists"
            element={
              <>
                <Navbar />
                <Therapist />
                <Footer />
              </>
            }
          />
          <Route
            path="/therapist/:id"
            element={
              <>
                <Navbar />
                <TherapistProfile />
                <Footer />
              </>
            }
          />

          {/* ── AI Assistant flow ────────────────────────────────────── */}
          {/*
            Step 1 — /ai-assistant  : mood check-in (MoodTracker)
            Step 2 — /chat          : the actual chatbot (ChatBot)
            MoodTracker already calls navigate('/chat') on its "Let's Start" button.
            The old "/AI Assistant" path (with space) is kept as a redirect alias
            so any existing bookmarks still work.
          */}
          <Route
            path="/ai-assistant"
            element={
              <>
                <Navbar />
                <MoodTracker />
                <Footer />
              </>
            }
          />
          {/* Legacy alias — space-encoded path redirected to clean slug */}
          <Route
            path="/AI Assistant"
            element={
              <>
                <Navbar />
                <MoodTracker />
                <Footer />
              </>
            }
          />

          <Route path="/chat" element={<ChatBot />} />

          {/* ── Resources ────────────────────────────────────────────── */}
          <Route
            path="/ResourcesCenter"
            element={
              <>
                <Navbar />
                <ResourcesCenter />
                <Footer />
              </>
            }
          />

          {/* ── User Profile ─────────────────────────────────────────── */}
          <Route
            path="/UserProfile"
            element={
              <>
                <Navbar />
                <UserProfile />
                <Footer />
              </>
            }
          />

          {/* ── Auth ─────────────────────────────────────────────────── */}
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<SignUp />} />

          {/* ── Static / account pages ───────────────────────────────── */}
          <Route
            path="/faqs"
            element={
              <>
                <Navbar />
                <FAQs />
                <Footer />
              </>
            }
          />
          <Route
            path="/services"
            element={
              <>
                <Navbar />
                <Services />
                <Footer />
              </>
            }
          />
          <Route
            path="/terms"
            element={
              <>
                <Navbar />
                <Terms />
                <Footer />
              </>
            }
          />
          <Route
            path="/privacy"
            element={
              <>
                <Navbar />
                <Privacy />
                <Footer />
              </>
            }
          />
          <Route
            path="/settings"
            element={
              <>
                <Navbar />
                <Settings />
                <Footer />
              </>
            }
          />
          <Route
            path="/edit-profile"
            element={
              <>
                <Navbar />
                <EditProfile />
                <Footer />
              </>
            }
          />
          <Route
            path="/saved-collection"
            element={
              <>
                <Navbar />
                <SavedCollection />
                <Footer />
              </>
            }
          />

        </Routes>
      </div>
    </Router>
  );
}

export default App;
