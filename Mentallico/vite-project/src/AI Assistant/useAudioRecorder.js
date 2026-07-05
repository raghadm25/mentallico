import { useState, useRef, useEffect, useCallback } from 'react';
import fixWebmDuration from 'fix-webm-duration';

/**
 * Formats a whole number of seconds as "M:SS" (e.g. 7 -> "0:07", 125 -> "2:05").
 */
export function formatTime(totalSeconds) {
  const safe = Number.isFinite(totalSeconds) ? Math.max(0, totalSeconds) : 0;
  const minutes = Math.floor(safe / 60);
  const seconds = Math.floor(safe % 60);
  return `${minutes}:${String(seconds).padStart(2, '0')}`;
}

// Ask for the most broadly-playable codec MediaRecorder actually supports,
// instead of leaving the browser's own (unpredictable) default in place.
// MediaRecorder can NEVER produce real .wav data — only compressed formats
// like webm/opus or mp4/aac — so a "wav" fallback would just mislabel
// whatever bytes we actually got and make the file fail to play. If none of
// these are supported we fall back to no explicit mimeType at all and let
// the browser pick (still labeled correctly afterwards via recorder.mimeType).
const MIME_CANDIDATES = ['audio/webm;codecs=opus', 'audio/webm', 'audio/mp4'];

function pickSupportedMimeType() {
  if (typeof MediaRecorder === 'undefined' || !MediaRecorder.isTypeSupported) return undefined;
  return MIME_CANDIDATES.find((type) => MediaRecorder.isTypeSupported(type));
}

/**
 * Records microphone audio via MediaRecorder and exposes a live "M:SS" timer
 * and the active-recording state. The finished clip is handed to you via the
 * `onRecordingComplete(audioUrl, audioBlob)` callback — called synchronously
 * from inside `mediaRecorder.onstop`, only once the Blob (and its corrected
 * duration) fully exist. The "send to chat" (or wherever) action belongs
 * inside that callback, so it only ever runs after the Blob is completely
 * ready — nothing outside `onstop` ever sees the URL before then.
 *
 * THE "STUCK AT 0:00" TIMER BUG, AND WHY THIS FIXES IT
 * -----------------------------------------------------
 * The classic version of this bug looks like:
 *
 *   const [recordingTime, setRecordingTime] = useState(0);
 *   const startRecording = () => {
 *     ...
 *     setInterval(() => {
 *       setRecordingTime(recordingTime + 1);   // <-- BUG
 *     }, 1000);
 *   };
 *
 * `recordingTime` here is captured once, at the moment the interval callback
 * was created — a "stale closure". Every tick re-reads that same captured
 * value (0) and sets it back to 1, over and over, because the closure never
 * sees the state the previous tick actually produced. The UI looks frozen.
 *
 * Two things fix it:
 *   1. Use the FUNCTIONAL updater form, `setRecordingTime((t) => t + 1)`.
 *      This reads the latest state at the moment the update is applied,
 *      not whatever was captured when the interval was created — so it's
 *      immune to stale closures no matter how often the interval callback
 *      was defined.
 *   2. Drive the interval from a `useEffect` keyed on `isRecording`, so it
 *      is created exactly once when recording starts and torn down exactly
 *      once when it stops — instead of being created inline inside an event
 *      handler, which risks leaking a second interval on a double-click or
 *      re-render.
 *
 * @param {{ onRecordingComplete?: (audioUrl: string, audioBlob: Blob) => void }} [options]
 */
export function useAudioRecorder({ onRecordingComplete } = {}) {
  const [isRecording, setIsRecording] = useState(false);
  const [recordingTime, setRecordingTime] = useState(0); // elapsed seconds
  const [error, setError] = useState(null);

  const mediaRecorderRef = useRef(null);
  const audioChunksRef = useRef([]);
  const streamRef = useRef(null);
  const stopRequestedRef = useRef(false);
  const startedAtRef = useRef(0);

  // Keep a ref to the latest callback so `startRecording`'s identity below
  // doesn't need to change every time the caller's inline callback prop
  // does — `onstop` always calls whatever the current callback is, without
  // us having to re-create the recorder or add it as a dependency.
  const onRecordingCompleteRef = useRef(onRecordingComplete);
  useEffect(() => {
    onRecordingCompleteRef.current = onRecordingComplete;
  }, [onRecordingComplete]);

  // The live timer. Ticks once a second ONLY while isRecording is true,
  // and always cleans itself up — both when recording stops and when the
  // component unmounts mid-recording (see the cleanup return below).
  useEffect(() => {
    if (!isRecording) return undefined;

    const intervalId = setInterval(() => {
      // Functional updater — see the doc comment above for why this
      // specifically is what keeps the UI ticking instead of freezing.
      setRecordingTime((prev) => prev + 1);
    }, 1000);

    return () => clearInterval(intervalId);
  }, [isRecording]);

  // Unmount safety net: if the component unmounts while a recording is
  // still active (e.g. the user navigates away mid-recording), release the
  // microphone stream so the browser's "recording" indicator turns off and
  // no track is left open in the background.
  useEffect(() => {
    return () => {
      streamRef.current?.getTracks().forEach((t) => t.stop());
    };
  }, []);

  const startRecording = useCallback(async () => {
    if (isRecording) return;
    stopRequestedRef.current = false;
    setError(null);

    if (!navigator.mediaDevices?.getUserMedia) {
      setError("Voice recording isn't supported in this browser.");
      return;
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      // The user may have already tapped "stop" while the permission
      // prompt was still resolving — don't leave an orphaned stream open.
      if (stopRequestedRef.current) {
        stream.getTracks().forEach((t) => t.stop());
        return;
      }

      streamRef.current = stream;
      const supportedMimeType = pickSupportedMimeType();
      const recorder = new MediaRecorder(stream, supportedMimeType ? { mimeType: supportedMimeType } : undefined);
      mediaRecorderRef.current = recorder;
      audioChunksRef.current = [];

      // 1. ondataavailable — push every chunk MediaRecorder hands us.
      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) audioChunksRef.current.push(e.data);
      };

      // 2. onstop — the ENTIRE "build the file, fix its duration, then send
      //    it" sequence lives here, in order, each step awaited before the
      //    next runs. onRecordingComplete is only ever called at the very
      //    end, once finalBlob/audioUrl are fully real.
      recorder.onstop = async () => {
        streamRef.current?.getTracks().forEach((t) => t.stop());
        streamRef.current = null;

        if (audioChunksRef.current.length === 0) return;

        // Label the blob with the codec the browser actually recorded in —
        // hardcoding a MIME type here can produce files that won't play back.
        const rawBlob = new Blob(audioChunksRef.current, {
          type: recorder.mimeType || 'audio/webm',
        });
        const durationMs = Date.now() - startedAtRef.current;

        // Chrome/Edge's MediaRecorder writes webm files with no duration in
        // the header, so an <audio> element shows 0:00 no matter how long
        // the clip actually is. Patch the real duration back into the blob
        // BEFORE anyone downstream ever sees a URL for it.
        let finalBlob = rawBlob;
        if (rawBlob.type.includes('webm')) {
          try {
            finalBlob = await fixWebmDuration(rawBlob, durationMs, { logger: false });
          } catch {
            finalBlob = rawBlob;
          }
        }

        const audioUrl = URL.createObjectURL(finalBlob);

        // 3. "Send" happens here — inside onstop, after every async step
        // above has finished — never before, and never from anywhere else.
        onRecordingCompleteRef.current?.(audioUrl, finalBlob);
      };

      recorder.start();
      startedAtRef.current = Date.now();
      setRecordingTime(0);
      setIsRecording(true);
    } catch (err) {
      setIsRecording(false);
      switch (err?.name) {
        case 'NotAllowedError':
        case 'PermissionDeniedError':
          setError(
            "Microphone access was denied. Check your browser's site settings (and your OS's microphone privacy settings) and try again."
          );
          break;
        case 'NotFoundError':
        case 'DevicesNotFoundError':
          setError('No microphone was found. Connect one and try again.');
          break;
        case 'NotReadableError':
        case 'TrackStartError':
          setError('Your microphone is already in use by another application.');
          break;
        default:
          setError(`Could not start recording: ${err?.message || err?.name || 'unknown error'}`);
      }
    }
  }, [isRecording]);

  const stopRecording = useCallback(() => {
    stopRequestedRef.current = true;
    if (mediaRecorderRef.current && mediaRecorderRef.current.state !== 'inactive') {
      mediaRecorderRef.current.stop(); // triggers recorder.onstop above, asynchronously
    }
    setIsRecording(false);
    setRecordingTime(0);
  }, []);

  const toggleRecording = useCallback(() => {
    if (isRecording) stopRecording();
    else startRecording();
  }, [isRecording, startRecording, stopRecording]);

  return {
    isRecording,
    recordingTime,
    formattedTime: formatTime(recordingTime),
    error,
    startRecording,
    stopRecording,
    toggleRecording,
  };
}
