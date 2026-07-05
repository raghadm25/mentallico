import { useRef, useState } from 'react';
import { loginWithGoogle, loginWithFacebook } from '../services/api';

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID;
const FACEBOOK_APP_ID = import.meta.env.VITE_FACEBOOK_APP_ID;

/**
 * Shared Google + Facebook sign-in logic for the Sign Up and Log In pages.
 *
 * Both SDKs are loaded identically — a static <script> tag in index.html,
 * each initializing itself as soon as it arrives (window.google via Google's
 * own script, window.FB via the fbAsyncInit callback) — so this hook never
 * injects scripts itself. It just checks the SDK is ready before use, the
 * same way for both providers, and reports a clear message if not.
 *
 * Both providers ultimately exchange a provider access token for this app's
 * own JWT pair via the backend (POST /auth/google/ or /auth/facebook/), so
 * a successful social sign-in is indistinguishable from a normal login
 * afterwards — same tokens, same storage, same `onSuccess`.
 *
 * @param {{ onSuccess: () => void, onError: (message: string) => void }} handlers
 */
export function useSocialAuth({ onSuccess, onError }) {
  const [googleLoading, setGoogleLoading] = useState(false);
  const [facebookLoading, setFacebookLoading] = useState(false);
  const googleTokenClientRef = useRef(null);

  const handleGoogleTokenResponse = async (response) => {
    if (!response?.access_token) {
      onError('Google sign-in was cancelled.');
      return;
    }
    setGoogleLoading(true);
    try {
      await loginWithGoogle(response.access_token);
      onSuccess();
    } catch (err) {
      onError(err.message || 'Could not sign in with Google. Please try again.');
    } finally {
      setGoogleLoading(false);
    }
  };

  const handleGoogleClick = () => {
    if (!GOOGLE_CLIENT_ID) {
      onError("Google sign-in isn't configured yet — add a Client ID to VITE_GOOGLE_CLIENT_ID to enable it.");
      return;
    }
    if (!window.google?.accounts?.oauth2) {
      onError('Google sign-in is still loading. Please try again in a moment.');
      return;
    }

    // Created lazily (once) rather than in a mount effect, so there's no
    // race with the async Google script possibly not being loaded yet.
    if (!googleTokenClientRef.current) {
      googleTokenClientRef.current = window.google.accounts.oauth2.initTokenClient({
        client_id: GOOGLE_CLIENT_ID,
        scope: 'openid email profile',
        callback: handleGoogleTokenResponse,
      });
    }
    googleTokenClientRef.current.requestAccessToken();
  };

  const handleFacebookLoginResponse = async (response) => {
    if (!response.authResponse?.accessToken) {
      onError('Facebook sign-in was cancelled.');
      setFacebookLoading(false);
      return;
    }
    try {
      await loginWithFacebook(response.authResponse.accessToken);
      onSuccess();
    } catch (err) {
      onError(err.message || 'Could not sign in with Facebook. Please try again.');
    } finally {
      setFacebookLoading(false);
    }
  };

  const handleFacebookClick = () => {
    if (!FACEBOOK_APP_ID) {
      onError("Facebook sign-in isn't configured yet — add an App ID to VITE_FACEBOOK_APP_ID to enable it.");
      return;
    }
    // Mirrors the Google readiness check above exactly: the SDK is loaded
    // statically in index.html, so by the time a user can click this
    // button it's almost always ready — but if not, say so rather than
    // throwing on a missing window.FB.
    if (!window.FB) {
      onError('Facebook sign-in is still loading. Please try again in a moment.');
      return;
    }

    setFacebookLoading(true);
    window.FB.login(handleFacebookLoginResponse, { scope: 'public_profile,email' });
  };

  return { googleLoading, facebookLoading, handleGoogleClick, handleFacebookClick };
}
