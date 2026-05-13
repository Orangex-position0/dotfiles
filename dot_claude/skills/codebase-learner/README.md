# Codebase Learner

A Claude Code skill that helps developers learn any codebase through structured, progressive exploration.

Point it at a repository. Get back a guided learning experience — either an interactive HTML course or a set of Markdown study notes — that teaches you how the code works, why it's designed that way, and what you can learn from it.

## Who is this for?

**Developers with CS background** who want to learn from open-source projects. You know programming fundamentals — you want to level up your architecture understanding, design pattern recognition, and codebase navigation skills.

**Your goals:**
- Quickly build a mental model of an unfamiliar project
- Understand *why* architectural decisions were made (not just *what* was built)
- Learn reusable patterns and practices from real production code
- Develop enough understanding to contribute to the project
- Build architectural intuition for your own projects

## How it works

### Progressive exploration — not one-shot generation

Instead of dumping everything at once, the skill guides you through the codebase step by step:

1. **Project snapshot** — Quick overview: what it does, tech stack, repo structure, how to run it
2. **Choose your path** — Pick what to explore: request flow, architecture layers, domain model, data access, design decisions, etc.
3. **Deep dive** — Each topic is a focused learning unit with real code, design intent explanations, and interactive elements
4. **Assemble** — Everything you've explored is assembled into your chosen output format

### Dual output formats

- **Interactive HTML** — Beautiful single-page course with scroll-based navigation, animated diagrams, and quizzes. Works offline, zero setup.
- **Markdown notes** — Structured study notes you can read in VS Code, Obsidian, or any editor. Easy to search, annotate, and extend.

## How to use

### As a Claude Code skill

1. Copy the `codebase-to-course` folder into `~/.claude/skills/`
2. Open any project in Claude Code
3. Say: *"Help me learn this project"* or *"Generate learning notes for this repo"*

### Trigger phrases

- "Help me learn this project"
- "Analyze this codebase"
- "Generate learning notes for this repo"
- "Explain this project's architecture"
- "Codebase walkthrough"
- "Turn this into a course"
- "Project study guide"
- "Interactive tutorial from this code"

### Output format selection

- Include "HTML" or "course" in your request → interactive HTML output
- Include "Markdown" or "notes" in your request → Markdown study notes
- Don't specify → ask which format you prefer

## What the learning materials include

- **Project snapshot** — What it does, tech stack, repo structure, how to build and run
- **Code with design intent** — Real code snippets annotated with *why* it's designed that way, not just *what* it does
- **Architecture diagrams** — Interactive diagrams showing how components connect
- **Request flow traces** — Step-by-step animations of how data moves through the system
- **Design decision analysis** — What alternatives were considered and why this approach was chosen
- **Quizzes** — Questions testing architectural judgment, not memory
- **Call chain tracers** — Visual call chains from entry point to database
- **Comparison views** — Side-by-side analysis of design approaches

## Skill structure

```
codebase-to-course/
├── SKILL.md                          # Main skill instructions
└── references/
    ├── design-system.md              # CSS tokens, typography, colors, layout
    ├── interactive-elements.md       # Quiz, animation, and visualization patterns
    ├── content-philosophy.md         # Content rules and teaching principles
    ├── gotchas.md                    # Common failure points
    ├── module-brief-template.md      # Template for pre-extracting code snippets
    ├── markdown-template.md          # Template for Markdown output
    ├── styles.css                    # Pre-built CSS
    ├── main.js                       # Pre-built JS engine
    ├── _base.html                    # HTML shell template
    ├── _footer.html                  # HTML footer
    └── build.sh                      # Assembly script
```

---

Built by [Zara](https://x.com/zarazhangrui) with Claude Code. Modified for developer-focused learning.
