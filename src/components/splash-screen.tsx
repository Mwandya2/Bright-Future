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

  // Splash background mimics the video's grey vignette (light centre → grey
  // edges), so the video's rectangle blends in instead of showing a hard box.
  const bg =
    "radial-gradient(circle at 50% 47%, #f2f2f2 0%, #e6e6e6 24%, #d2d2d2 58%, #bfbfbf 100%)";

  return (
    <div
      aria-hidden
      className={`fixed inset-0 z-[9999] flex items-center justify-center transition-opacity duration-500 ease-out ${
        fading ? "pointer-events-none opacity-0" : "opacity-100"
      }`}
      style={{ background: bg }}
    >
      <video
        ref={videoRef}
        src="/splash.mp4"
        muted
        autoPlay
        playsInline
        preload="auto"
        className="h-auto w-[min(82vw,520px)]"
        style={{
          // Feather the video's edges into the matching background so no
          // rectangular border is visible.
          WebkitMaskImage:
            "radial-gradient(ellipse 92% 92% at 50% 50%, #000 62%, transparent 100%)",
          maskImage:
            "radial-gradient(ellipse 92% 92% at 50% 50%, #000 62%, transparent 100%)",
        }}
      />
    </div>
  );
}
