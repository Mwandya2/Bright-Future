"use client";

import { useEffect, useRef, useState } from "react";

/**
 * Full-screen white splash that plays the BFT logo video centered, once per
 * browser session, then fades out to reveal the app. The video is muted and
 * has no audio track. Rendered in the initial HTML (visible by default) so
 * there's no flash of page content before it appears.
 */
export function SplashScreen() {
  const [visible, setVisible] = useState(true);
  const [fading, setFading] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    // Only show once per session.
    if (sessionStorage.getItem("bft_splash_seen")) {
      setVisible(false);
      return;
    }

    let done = false;
    const finish = () => {
      if (done) return;
      done = true;
      sessionStorage.setItem("bft_splash_seen", "1");
      setFading(true);
      setTimeout(() => setVisible(false), 600);
    };

    const fallback = setTimeout(finish, 9000); // safety if 'ended' never fires
    const v = videoRef.current;
    if (v) {
      v.play().catch(() => {}); // some browsers need an explicit play()
      v.onended = finish;
    }
    return () => clearTimeout(fallback);
  }, []);

  if (!visible) return null;

  return (
    <div
      aria-hidden
      className="fixed inset-0 z-[9999] flex items-center justify-center bg-white transition-opacity duration-500"
      style={{ opacity: fading ? 0 : 1 }}
    >
      <video
        ref={videoRef}
        src="/splash.mp4"
        muted
        autoPlay
        playsInline
        preload="auto"
        className="h-auto w-[min(82vw,520px)]"
      />
    </div>
  );
}
