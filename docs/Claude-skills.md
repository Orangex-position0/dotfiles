# Claude Skills Documentation

This directory contains custom skills I've developed for Claude Code to enhance AI-assisted development efficiency and quality.

[English](Claude-skills.md) | [简体中文](Claude-skills.zh-CN.md)

## Skills Overview

### 1. PPP Generator - Work Report Generator

**Path:** `dot_claude/skills/ppp-generator/`

**Purpose:** Generate structured PPP (Progress-Plans-Problems) work reports

**Key Features:**
- Result-oriented expression optimization (transforms "what I did" into "what I accomplished")
- Concise and focused (1-3 sentences per section)
- Three-part structure: Progress → Plans → Problems
- Outputs standard Markdown format with YAML frontmatter

**Use Cases:**
- Daily work reports
- Stand-up meeting records
- Project progress sync
- Weekly/daily reports

**Trigger Conditions:**
- User requests "generate PPP", "write daily report", "work report", "stand-up record", etc.
- Explicitly mentions Progress/Plans/Problems structure

**Example Output:**
```markdown
---
date: 2026-03-28
author: Zhang San
week: 2026-W13
---

# Work Report - PPP

## ✅ Progress
- Fixed user login token expiration handling bug
- Completed new feature requirement discussion meeting

## 📋 Plans
- Complete login feature test cases
- Optimize database query performance

## ⚠️ Problems/Risks
- Third-party API response unstable, needs monitoring and optimization
```

**Detailed Documentation:** [ppp-generator/SKILL.md](../dot_claude/skills/ppp-generator/SKILL.md)

---

### 2. Tech Blog Coach - Technical Writing Coach

**Path:** `dot_claude/skills/tech-blog-coach/`

**Purpose:** Technical blog writing coach based on the Feynman Learning Method, helping developers transform "knowledge you've mastered" into "articles others can understand"

**Core Philosophy:**
- **Feynman Learning Method:** If you can't explain it simply, you don't understand it well enough
- **Notes vs Articles:** Notes are for yourself, articles are for readers (to test if you truly understand)

**Four Core Capabilities:**

1. **Technical Article Creation**
   - Supports three creation modes:
     - Mode 1: Modify article draft based on notes (Logseq workflow - recommended)
     - Mode 2: Create new articles based on notes
     - Mode 3: Independent creation with AI guidance
   - Uses a fixed 5-part article structure

2. **Article Polishing & Optimization**
   - Analyze strengths and weaknesses of existing articles
   - Ensure coherent content without skipping steps
   - Verify code can run

3. **Writing Strategy Planning**
   - Extract topics from daily development
   - Create topic pool
   - Evaluate feasibility and value

4. **Publication Format Preparation**
   - Optimize titles and descriptions
   - SEO optimization
   - Final quality check

**Fixed Technical Article Template (5 Parts):**
1. **Background & Problem** - Introduce background, let readers understand article positioning
2. **Solution or Principle** - Explain core concepts with bullet points, use code, diagrams, lists
3. **Implementation Steps** - Step-by-step explanation, complete runnable code examples
4. **Examples / Pitfalls** - Common errors and solutions
5. **Summary** - Quick summary, propose extension ideas

**Quality Checklist (Core):**
- Skip too many steps? (Content must be coherent)
- Assume too much prior knowledge? (Necessary concepts need supplement)
- Can code run? (Verify in IDE first)

**Resource Files:**
- `templates/blog-post-template.md` - Article template based on 5-part structure
- `templates/blog-outline-template.md` - Outline planning template
- `templates/writing-checklist.md` - Quality checklist
- `templates/note-to-article-guide.md` - Note to article transformation guide
- `templates/logseq-workflow-guide.md` - Logseq workflow guide (recommended)
- `references/writing-workflows.md` - Detailed workflow

**Use Cases:**
- Transform learning notes into technical blogs
- Polish and optimize existing articles
- Create technical tutorials from scratch
- Prepare publication format

**Detailed Documentation:** [tech-blog-coach/SKILL.md](../dot_claude/skills/tech-blog-coach/SKILL.md)

---

### 3. Skill Creator - Skill Creation Guide

**Path:** `dot_claude/skills/skill-creator/`

**Purpose:** Guide for creating effective Claude Code skills

**About Skills:**

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks—transforming Claude from a general-purpose agent into a specialized agent equipped with procedural knowledge.

**What Skills Provide:**
1. **Specialized workflows** - Multi-step procedures for specific domains
2. **Tool integrations** - Instructions for working with specific file formats or APIs
3. **Domain expertise** - Company-specific knowledge, schemas, business logic
4. **Bundled resources** - Scripts, references, and assets for complex and repetitive tasks

**Core Principles:**

1. **Concise is Key**
   - Default assumption: Claude is already very smart
   - Only add context Claude doesn't already have
   - Prefer concise examples over verbose explanations

2. **Set Appropriate Degrees of Freedom**
   - **High freedom** (text-based instructions): Multiple approaches are valid
   - **Medium freedom** (pseudocode or scripts with parameters): Preferred pattern exists
   - **Low freedom** (specific scripts, few parameters): Operations are fragile and error-prone

3. **Progressive Disclosure**
   - Metadata (name + description) - Always in context (~100 words)
   - SKILL.md body - When skill triggers (<5k words)
   - Bundled resources - As needed by Claude (Unlimited)

**Skill Structure:**
```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/       - Executable code
    ├── references/    - Documentation reference material
    └── assets/        - Files used in output
```

**Skill Creation Process (6 Steps):**

1. **Understand the Skill** - Understand skill usage patterns through concrete examples
2. **Plan Reusable Contents** - Determine required scripts, references, assets
3. **Initialize the Skill** - Run `init_skill.py` to generate template
4. **Edit the Skill** - Implement resources and write SKILL.md
5. **Package the Skill** - Run `package_skill.py` to create distributable .skill file
6. **Iterate** - Optimize based on actual usage

**Resource Files:**
- `references/workflows.md` - Patterns for multi-step processes and conditional logic
- `references/output-patterns.md` - Template and example patterns

**Use Cases:**
- Create new custom skills
- Update existing skills
- Learn skill design best practices
- Understand how to organize skill resource structure

**Detailed Documentation:** [skill-creator/SKILL.md](../dot_claude/skills/skill-creator/SKILL.md)

---

## Installation and Usage

### Installing Skills

These skills are located in the `dot_claude/skills/` directory and will be automatically synced to `~/.claude/skills/` by chezmoi.

### Using Skills

Skills activate automatically based on trigger conditions defined in their description. For example:

- **PPP Generator**: Triggers when you say "generate PPP" or "write daily report"
- **Tech Blog Coach**: Triggers when you mention "technical blog", "writing", "Feynman Learning Method"
- **Skill Creator**: Triggers when you say "create skill" or "write new skill"

### Developing New Skills

Use the Skill Creator skill to create new custom skills:

```bash
# 1. Use skill-creator as a template
cd dot_claude/skills/skill-creator

# 2. Run initialization script
python scripts/init_skill.py my-new-skill --path ../

# 3. Edit SKILL.md and add resources

# 4. Package the skill
python scripts/package_skill.py ../my-new-skill
```

## Skills Relationship

These three skills complement each other, forming a complete toolchain:

1. **Skill Creator** - Used to create new skills (including the other two)
2. **Tech Blog Coach** - Improve technical writing quality and efficiency
3. **PPP Generator** - Optimize work reporting and team communication

## Contributing

These skills are customized for my personal workflow. If you have improvement suggestions or find issues, feel free to submit an Issue or Pull Request.

## License

These skills are licensed under the MIT License. You are free to use, modify, and distribute them.

---

**Last Updated:** 2026-03-28
**Maintainer:** Orangex-position0