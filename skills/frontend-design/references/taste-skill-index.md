# Taste-Skill Quick Reference

**Full skill**: `vendor/taste-skill/skills/taste-skill/SKILL.md`

## What it is

An anti-AI-slop frontend design skill for landing pages, portfolios, and redesigns. Dial-driven (VARIANCE / MOTION / DENSITY). Makes AI-generated UIs look designed, not templated.

## When to use

- React/Next.js projects with Tailwind CSS
- Landing pages, portfolios, marketing sites
- Projects that need scroll-driven animation (GSAP ScrollTrigger) or UI motion (Motion/Framer Motion)
- The brief asks for "cinematic", "animated", "Awwwards-level", or names a specific aesthetic profile

## Not for

- Dashboards, data tables, complex multi-step product UI
- Static HTML/CSS without a React framework
- Component-level work (a single button, input, or card) — use hallmark for that

## The three dials

Every design starts by setting these based on the brief:

| Dial | Range | Baseline |
|------|-------|----------|
| **DESIGN_VARIANCE** | 1 (symmetric) — 10 (artsy chaos) | 8 |
| **MOTION_INTENSITY** | 1 (static) — 10 (cinematic) | 6 |
| **VISUAL_DENSITY** | 1 (airy/gallery) — 10 (cockpit/packed) | 4 |

Quick inference: minimalist/calm → 5-6/3-4/2-3 · premium/Apple-y → 7-8/5-7/3-4 · playful/wild → 9-10/8-10/3-4 · trust-first/public-sector → 3-4/2-3/4-5.

## Default tech stack

- **Framework**: React/Next.js (RSC by default), `'use client'` only for motion/interactive components
- **Styling**: Tailwind CSS v4 (`v3` only if existing project demands it)
- **Animation**: Motion (`motion/react`) for UI; GSAP + ScrollTrigger for scroll-driven
- **Fonts**: `next/font` or self-hosted with `font-display: swap`
- **Icons**: Phosphor > HugeIcons > Radix > Tabler; Lucide discouraged

## Structural conventions

- Breakpoints: `sm(640)`, `md(768)`, `lg(1024)`, `xl(1280)`, `2xl(1536)`
- Page containment: `max-w-[1400px] mx-auto` or `max-w-7xl`
- Viewport: `min-h-[100dvh]` (never `h-screen`)
- Layout: CSS Grid always, never flexbox percentage math
- Dependency check: verify `package.json` before importing anything

## Key banned patterns (v2)

- Inter as default font / Fraunces & Instrument_Serif as default serifs
- AI-purple/blue gradients and neon glows
- Em-dashes (`—`) anywhere
- Section-numbering eyebrows ("00 / INDEX")
- Centered hero over dark mesh with three equal feature cards
- Warm-craft palette (beige+brass+clay+oxblood+espresso) as default
- Decorative status dots, scroll cues, version footers
- Div-based fake screenshots, custom mouse cursors
- `window.addEventListener('scroll')` — use Motion or GSAP

## Flow

1. Read the brief → output one-line "Design Read"
2. Set the three dials based on the design read
3. Map brief to a design system (Fluent, Material, shadcn, etc.) or web standards
4. Write code following the skill's detailed rules
5. Run the pre-flight checklist before shipping

## Variety profiles (included in the core skill)

If the brief calls for a specific aesthetic, the core skill has built-in profiles: minimalist (Notion/Linear), brutalist (Swiss terminal), soft (Awwwards agency), image-to-code pipeline, and redesign protocol. These are part of the v2 skill — no separate skill loading needed.
