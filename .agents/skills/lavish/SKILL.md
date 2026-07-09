# Lavish Skill

Interactive HTML planning artifacts for complex feature design and design discussions.

## When to Load
- Complex feature planning (load before `/plan`)
- Design discussions with multiple stakeholders
- Architecture decisions with trade-off visualizations
- Multi-option decision trees

## How to Invoke
- `skill({ name: "lavish" })` loads the skill
- Once loaded, run `lavish-axi` to generate an interactive HTML artifact
- The artifact opens in your browser for annotation and review
- Human annotates feedback in the browser; the agent incorporates it

## When NOT to Use
- Simple, straightforward tasks (use plain-text plans instead)
- Changes that don't need visualization
- When speed is more important than collaborative design
