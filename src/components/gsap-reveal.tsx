"use client";

import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";

gsap.registerPlugin(ScrollTrigger, useGSAP);

/**
 * Mount once near the top of a page. Animates:
 *  - elements marked [data-hero] in an entrance timeline on load
 *  - elements with class .reveal as they scroll into view (batched, staggered)
 * Uses gsap.from so content stays visible if JS is disabled, and honours
 * prefers-reduced-motion.
 */
export function GsapReveal() {
  useGSAP(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;

    // Hero entrance
    const hero = gsap.utils.toArray<HTMLElement>("[data-hero]");
    if (hero.length) {
      gsap.from(hero, {
        y: 26,
        opacity: 0,
        duration: 0.9,
        ease: "power3.out",
        stagger: 0.12,
      });
    }

    // Scroll-reveal: pre-hide (JS only, so no-JS keeps content visible),
    // then animate in as each group enters the viewport.
    gsap.set(".reveal", { opacity: 0, y: 28 });
    ScrollTrigger.batch(".reveal", {
      start: "top 90%",
      onEnter: (batch) =>
        gsap.to(batch, {
          y: 0,
          opacity: 1,
          duration: 0.7,
          ease: "power2.out",
          stagger: 0.08,
          overwrite: true,
        }),
    });

    ScrollTrigger.refresh();
  });

  return null;
}
