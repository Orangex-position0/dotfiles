---
name: codebase-learner
description: "Turn any codebase into a progressive learning experience for developers. Analyzes open-source projects and generates structured learning materials — either interactive HTML courses or Markdown study notes. Use this skill when someone wants to learn, understand, or explore a codebase, open-source project, or unfamiliar repository. Triggers: 'help me learn this project', 'analyze this codebase', 'generate learning notes for this repo', 'turn this into a course', 'explain this project architecture', 'codebase walkthrough', 'project study guide'."
---

# Codebase Learner

Turn any codebase into a structured learning experience. Analyze an open-source project, trace its architecture, understand its design decisions, and generate either an interactive HTML course or a set of Markdown study notes.

## First-Run Welcome

When the skill is first triggered and the user hasn't specified a codebase yet:

> **I can help you learn any codebase by turning it into structured learning materials.**
>
> Give me a project to analyze:
> - **A local folder** — e.g., "help me learn ./my-project"
> - **A GitHub link** — e.g., "analyze https://github.com/user/repo"
> - **The current project** — if you're already in a codebase, just say "help me learn this"
>
> I'll read through the code, map the architecture, trace key request flows, and generate either:
> - **Interactive HTML course** — beautiful, scroll-based course with animations and quizzes
> - **Markdown study notes** — structured notes you can read in VS Code, Obsidian, or any editor
>
> We'll go step by step — first I'll give you a project overview, then you choose what to dive into.

If the user provides a GitHub link, clone the repo first (`git clone <url> /tmp/<repo-name>`) before starting. If they say "this project" or similar, use the current working directory.

## Who This Is For

The learner is a **developer with CS background** (typically a junior backend developer) who wants to learn from open-source projects. They know programming fundamentals — variables, functions, classes, basic data structures, HTTP, databases. What they need is:

- **Rapid codebase navigation** — build a mental model of an unfamiliar project quickly
- **Architecture comprehension** — understand why the project is structured this way
- **Design pattern recognition** — learn reusable patterns from real production code
- **Code reading skills** — develop the ability to independently explore large codebases

**What they already know:** Basic programming, OOP, HTTP, SQL, common frameworks. Don't explain what a function is, what REST means, or what a database does.

**What they need to learn:** Domain-specific concepts, project-specific abstractions, design decisions and their trade-offs, the "why" behind architectural choices.

**Their goals are practical:**
- Apply patterns and techniques they learn to their own projects
- Understand enough to contribute to the project if they want
- Develop architectural intuition for making better design decisions
- Build the vocabulary to discuss design trade-offs with senior engineers

## Why This Approach Works

Learning a new codebase is a **cognitive overload problem**. A medium-sized project has hundreds of files, dozens of abstractions, and layers of indirection. Reading code top-to-bottom is like reading a dictionary — you see all the words but none of the story.

This skill reduces cognitive load through **progressive disclosure**:

1. **Start with the big picture** — what does this project do, what's the tech stack, how's the repo organized
2. **Trace a concrete flow** — follow one request from entry point to database and back
3. **Explore by layer** — go deeper into the layers that interest you
4. **Analyze design decisions** — understand the "why" behind key choices

Each step builds on the previous one. The learner always has context for what they're looking at.

---

## The Process

### Phase 1: Quick Recon

Quickly understand the project. Read the README, entry points, build config, and directory structure. The goal is to produce a **project snapshot** — enough context for the learner to decide what to explore next.

**What to extract:**
- What the project does and why it exists
- Tech stack with versions
- Directory structure with one-line descriptions
- How to build and run locally
- Entry points (main class, router file, etc.)
- Core domain concepts (from README, domain models, or config)

**Output the project snapshot to the learner** — a structured summary covering all the above. Then ask:

> "Here's what this project looks like at a glance. What would you like to dive into first?"
>
> Some directions:
> 1. **Trace a request flow** — follow a real request end-to-end
> 2. **Explore the architecture** — understand the layers and how they connect
> 3. **Understand the domain model** — learn the core business concepts
> 4. **Look at data access** — how the project talks to databases/caches
> 5. **Study design decisions** — why the project chose X over Y

### Phase 2: Progressive Deep-Dive

Based on the learner's choice, generate one **learning unit** at a time. Each unit is a focused exploration of one aspect of the project.

**Each learning unit should include:**
- Connection to what was covered before (1-2 sentences)
- The "what" — what this layer/module/component does
- The "why" — design decisions and their reasoning
- Code snippets with design intent annotations (see `references/content-philosophy.md`)
- At least one interactive element or visual (diagram, flow animation, call chain)
- A quiz question testing architectural judgment
- Link/connection to the next logical topic

**Available topics** (pick what's relevant for the project — not all projects need all of these):

| Topic | What it covers |
|-------|---------------|
| Request flow | Trace a request from entry to response — controllers, middleware, services |
| Domain model | Core business entities, value objects, relationships |
| Architecture layers | How the project separates concerns, dependency flow |
| Module communication | How modules/services talk (sync, async, events) |
| Data access | Repository/DAO layer, ORM usage, query patterns, caching |
| API design | Endpoint structure, auth, validation, error handling |
| Design decisions | Key architectural choices, alternatives considered, trade-offs |
| Error handling | Strategy for failures, retries, circuit breakers |
| Configuration | Environment management, secrets, feature flags |
| Testing | Test strategy, coverage, mocking approach |
| Build & deploy | CI/CD, containerization, environment setup |

After each learning unit, present the learner with options for what to explore next. Continue until they've covered what they need.

### Phase 3: Assemble Output

After the learner is satisfied with the coverage, assemble the final output.

#### HTML output

The course output is a **directory** with pre-built CSS/JS. All styles and interactivity come from reference files — never regenerate them.

**Output structure:**
```
project-name-course/
  styles.css       ← copied from references/styles.css
  main.js          ← copied from references/main.js
  _base.html       ← customized (title, accent color, nav dots)
  _footer.html     ← copied from references/_footer.html
  build.sh         ← copied from references/build.sh
  modules/
    00-overview.html
    01-domain.html
    ...
  index.html       ← assembled by build.sh
```

**Step 1:** Copy verbatim using Read + Write:
- `references/styles.css` → output dir
- `references/main.js` → output dir
- `references/_footer.html` → output dir
- `references/build.sh` → output dir

**Step 2:** Customize `_base.html` — three substitutions:
- `COURSE_TITLE` → project name
- `ACCENT_*` → chosen accent palette
- `NAV_DOTS` → one `<button>` per module

**Step 3:** Write module HTML files. Each contains only the `<section class="module">` block. Read `references/interactive-elements.md` for HTML patterns. Read `references/design-system.md` for visual conventions.

**Step 4:** Run `build.sh`:
```bash
cd project-name-course && bash build.sh
```

#### Markdown output

**Output structure:**
```
project-name-notes/
  README.md              ← project snapshot + learning path index
  01-domain-model.md     ← learning units
  02-architecture.md
  ...
  glossary.md            ← project-specific terms (if needed)
```

Read `references/markdown-template.md` for the template structure. Each learning unit becomes a separate Markdown file with the same content structure as the HTML modules.

### Phase 4: Review and Extend

After generating the output:
1. Open the output (HTML in browser, Markdown in editor)
2. Walk the learner through what was generated
3. Suggest extensions:
   - Related projects or repositories worth studying
   - Advanced topics to explore in this codebase
   - Practical exercises (e.g., "try adding X feature to practice what you learned")

---

## Design Identity

The visual design is a **warm, readable developer notebook** — not a flashy marketing page, not a dry textbook. Read `references/design-system.md` for the full token system.

Key principles:
- Warm palette with one confident accent color
- Distinctive typography (Bricolage Grotesque headings, DM Sans body, JetBrains Mono code)
- Code blocks with syntax highlighting on dark backgrounds
- Generous whitespace but higher information density than the original skill
- Interactive elements serve understanding, not decoration

---

## Reference Files

The `references/` directory contains detailed specs. **Read them only when you reach the relevant phase.**

- **`references/content-philosophy.md`** — Information density rules, design intent annotation format, quiz design, glossary rules. Read during Phase 2 (writing learning units).
- **`references/gotchas.md`** — Common failure points. Read during Phase 2 and Phase 3.
- **`references/module-brief-template.md`** — Template for pre-extracting code snippets before writing. Read during Phase 2 for complex codebases.
- **`references/markdown-template.md`** — Template for Markdown output. Read during Phase 3 when assembling Markdown.
- **`references/design-system.md`** — CSS tokens, typography, colors, layout. Read during Phase 3 when writing module HTML.
- **`references/interactive-elements.md`** — Implementation patterns for every interactive element. Read during Phase 3.
