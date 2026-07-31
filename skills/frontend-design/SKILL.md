---
name: frontend-design
description: Design router for frontend tasks. Detects project context (React/Next.js vs static HTML) and routes to the correct design skill - taste-skill for animated UIs or hallmark for structured HTML/CSS. Use when the user asks to design or build a landing page, frontend UI, portfolio, or redesign.
---

# Frontend Design Router

You are a design router. Your job is to detect the project context and route to the right frontend design skill. Do not design or code directly - load the appropriate skill instead.

## Detection

Read these signals before routing:

1. **Framework** - check `package.json` for React, Next.js, Vue, Svelte, Astro, or absence (vanilla HTML)
2. **Motion** - check for `framer-motion`, `gsap`, `motion`, or `lenis` in dependencies
3. **Task type** - is this a landing page? portfolio? dashboard? audit? redesign? component-level?
4. **User intent** - vibe words matter: "animated", "cinematic", "scroll-driven" vs "structured", "static", "typographic"

## Where the design skills live

These two skills are deliberately not registered as skills - they are large, and this router loads
them on demand. `$SUITE` below is the suite root, `~/.config/opencode` unless it was installed
elsewhere. Resolve it once, then use the full paths:

- taste-skill: `$SUITE/vendor/taste-skill/skills/taste-skill/SKILL.md`
- hallmark: `$SUITE/vendor/hallmark/skills/hallmark/SKILL.md`

Never use paths relative to the current project - this skill is loaded from a global skills
directory and the working directory is the user's project, not the suite.

## Routing table

| Signal | Route to | Load this SKILL.md |
|--------|----------|-------------------|
| React/Next.js + animation deps present | **design-taste-frontend** | taste-skill |
| React/Next.js + no animations → landing page/portfolio | **design-taste-frontend** | taste-skill |
| Static HTML, vanilla CSS, Astro, or no framework | **hallmark** | hallmark |
| Audit/redesign of *existing* project UI | **hallmark** | hallmark (use `hallmark audit` or `hallmark redesign` verb) |
| Component-level (single button, input, card) | **hallmark** | hallmark (component-scope flow) |
| Needs both: structure + animation | **hallmark first, then taste-skill** | hallmark for page structure/macrostructure, then taste-skill for motion/animation layer |
| Dashboard, data tables, complex product UI | **Neither** | These are out of scope for both skills. Tell the user and suggest a system-design approach. |
| Ambiguous | **Ask the user** | "Should this be a structured, typographic page (hallmark) or an animated, cinematic one (taste-skill)?" |

## Before loading the full skill

Always read the quick-reference index first to orient yourself:

1. Load `references/taste-skill-index.md` (next to this file) if routing to taste-skill
2. Load `references/hallmark-index.md` (next to this file) if routing to hallmark
3. Load both if routing to both

The index tells you the skill's key concepts, so you don't need to scan the full file blindly.

## When loading the full skill

- **taste-skill**: Read `$SUITE/vendor/taste-skill/skills/taste-skill/SKILL.md` (~1200 lines). It's self-contained - no sub-references needed.
- **hallmark**: Read `$SUITE/vendor/hallmark/skills/hallmark/SKILL.md` (~558 lines). It will tell you to load specific reference files from `$SUITE/vendor/hallmark/skills/hallmark/references/` on demand (index-then-pick pattern - follow it).

## Key principle

The two skills are complementary, not competing. taste-skill excels at animated, cinematic React/Next.js pages (GSAP, Motion, scroll-driven). hallmark excels at structured, varied, typographic HTML/CSS pages (21 macrostructures, 20 themes, 58 quality gates). Pick the right tool for the job - don't force one to do the other's work.
