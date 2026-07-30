# Hallmark Quick Reference

**Full skill**: `vendor/hallmark/skills/hallmark/SKILL.md`
**Reference directory**: `vendor/hallmark/skills/hallmark/references/`

## What it is

An anti-AI-slop design skill focused on **structural variety**, not just visual variety. Ships 21 named page macrostructures, 50 component archetypes, 20 OKLCH color themes, and 58 automated quality gates (slop tests). Two pages by Hallmark for different briefs should feel like different sites, not color-swaps of the same template.

## When to use

- Static HTML/CSS, vanilla web projects, or Astro sites
- Greenfield builds where you need structural variety across pages
- Audits of existing UIs (`hallmark audit`)
- Redesigns that preserve content/IA but change visual structure (`hallmark redesign`)
- Component-level design (single button, input, card — uses component-scope flow)
- Design DNA extraction from admired screenshots (`hallmark study`)

## Not for

- React/Next.js projects needing heavy animation (GSAP, Motion) — use taste-skill for that
- Dashboard-style data-heavy apps

## Key architecture

### The 7-step design flow
1. **Pre-flight scan** — read existing tokens, fonts, framework, motion stance
2. **Design-context gate** — ask audience / use case / tone; infer if user opts out
3. **Genre detection** — editorial (default), modern-minimal, atmospheric, or playful
4. **Macrostructure pick** — 1 of 21 page-shapes (Bento Grid, Long Document, Marquee Hero, Stat-Led, Workbench, etc.)
5. **Theme route** — 20 catalog themes or custom OKLCH palette
6. **Nav & footer archetype pick** — 14 nav + 8 footer archetypes
7. **Build + slop-test** — emit HTML/CSS, run 58 quality gates

### Three explicit verbs
| Verb | Purpose |
|------|---------|
| `hallmark audit <target>` | Score existing code against anti-patterns. No edits. |
| `hallmark redesign <target>` | Rebuild visual structure; keep copy/IA/brand. |
| `hallmark study <screenshot\|URL>` | Extract DNA from a design. Never copies pixels. |

### Component-scope flow
For single UI elements (button, input, card), skips page-level apparatus and emits the component + an 8-state demo wrapper (default/hover/focus/active/disabled/loading/error/success).

## The 21 macrostructures (index)

**Pick one name, then load only that file** from `references/macrostructures/`.

01 Bento Grid · 02 Long Document · 03 Marquee Hero · 04 Stat-Led · 05 Workbench · 06 Conversational FAQ · 07 Manifesto · 08 Photographic · 09 Quote-Led · 10 Specimen · 11 Catalogue · 12 Letter · 13 Index-First · 14 Narrative Workflow · 15 Split Studio · 16 Feature Stack · 17 Type Specimen · 18 Portfolio Grid · 19 Map/Diagram · 20 Ecosystem Index · 21 Component Playground

## The 20 themes

Specimen · Atelier · Brutal · Newsprint · Studio · Manifesto · Terminal · Midnight · Almanac · Garden · Riso · Sport · Bloom · Coral · Cobalt · Aurora · Editorial · Carnival · Lumen · Hum

Each theme is a distinct point in OKLCH color space + display font category.

## Key conventions

- **Color**: OKLCH exclusively. No hex/rgb/hsl. Custom properties for all tokens.
- **Typography**: 2+1 discipline (display + body + mono). Roman headers only — italic headers are banned.
- **Layout**: 4pt spacing scale. Section gaps 5.5-7rem. Grid-breaks encouraged in editorial.
- **Motion**: Custom cubic-beziers. Motion-cut if no animation library; motion-on if framer-motion/GSAP.
- **Tokens**: Once locked, all colors/fonts reference named CSS custom properties. No inline values.
- **Diversification**: Consecutive runs rotate macrostructure + theme automatically via `.hallmark/log.json`.

## Key banned patterns (58 slop-test gates)

- Italic headers, invented metrics, fake browser chrome, AI silhouettes
- Glassmorphism, too many gradient layers, overly rounded corners
- Em-dashes, section-numbering eyebrows, decorative status dots
- Mid-render token improvisation, warm-craft defaults
- Inter font as default, AI-purple/blue gradients

## Loading protocol (follow this)

1. Read `vendor/hallmark/skills/hallmark/SKILL.md` in full
2. The skill will tell you which reference files to load — use the **index-then-pick** pattern. Read `references/macrostructures.md` (slim index), then load only the one macrostructure file you picked. Same for genre files, theme files, component archetypes.
3. Never load all reference files at once (~100 files / ~37 KB) — that's token waste.
