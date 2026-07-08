"use client";

import { useEffect, useRef, useState } from "react";

const SPLASH_MS = 7000; // splash lasts at most 7 seconds
const CLIP_SECONDS = 8; // source clip length

/**
 * Full-screen white splash that plays the BFT logo video centered, once per
 * browser session, then fades out to reveal the app. The clip is sped up so it
 * completes within SPLASH_MS, and a hard timer guarantees it never hangs.
 */
export function SplashScreen() {
  const [visible, setVisible] = useState(true);
  const [fading, setFading] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (sessionStorage.getItem("bft_splash_seen")) {
      setVisible(false);
      return;
    }

    let done = false;
    const finish = () => {
      if (done) return;
      done = true;
      sessionStorage.setItem("bft_splash_seen", "1");
      setFading(true); // start the fade
      setTimeout(() => setVisible(false), 500); // unmount after the fade
    };

    const v = videoRef.current;
    if (v) {
      // Speed the clip up so its animation finishes right at the 7s mark.
      v.playbackRate = CLIP_SECONDS / (SPLASH_MS / 1000);
      v.play().catch(() => {}); // muted autoplay; ignore rejection
      v.onended = finish; // dismiss as soon as it finishes
      v.onerror = finish; // never get stuck if the video can't load
    }

    // Hard cap: the splash is gone by 7s no matter what.
    const cap = setTimeout(finish, SPLASH_MS);
    return () => clearTimeout(cap);
  }, []);

  if (!visible) return null;

  return (
    <div
      aria-hidden
      className={`fixed inset-0 z-[9999] overflow-hidden transition-opacity duration-500 ease-out ${
        fading ? "pointer-events-none opacity-0" : "opacity-100"
      }`}
      // Match the video's own edge grey (#e0e0e0) so the thin letterbox bars
      // blend into the video — no visible rectangular border on any screen.
      style={{ backgroundColor: "#e2e2e2" }}
    >
      {/* object-contain keeps the whole logo visible on every aspect ratio
          (never cropped); the background matches the video edge so the small
          letterbox area is invisible. */}
      <video
        ref={videoRef}
        src="/splash.mp4"
        muted
        autoPlay
        playsInline
        preload="auto"
        className="absolute inset-0 h-full w-full object-contain"
      />
    </div>
  );
}
