# Environment Selection Criteria

Use this guide to choose between ecc, orchestra, and hybrid modes.

## Quick Decision Tree

```
Is this a research-heavy or exploratory project?
├── Yes → orchestra
└── No
    ├── Is this a large, long-running project with mixed concerns?
    │   ├── Yes → hybrid
    │   └── No → ecc
```

## Mode Comparison

| Criterion | ecc | orchestra | hybrid |
|-----------|-----|-----------|--------|
| **External CLIs** | None | Codex + Gemini | Codex + Gemini |
| **Agent count** | 10+ specialized | 1 general | Both |
| **Workflow** | Structured (TDD, Plan) | Exploratory | Structured + Research |
| **Context mgmt** | Built-in | Subagent isolation | Both |
| **Best for** | Implementation | Design/Research | Large projects |

## Prefer ecc When

- **Frontend-heavy development**
  - React, Next.js, Vue, Svelte
  - UI components, styling
  - Client-side logic

- **Structured implementation**
  - TDD-focused development
  - Well-defined requirements
  - Refactoring existing code

- **Single-stream work**
  - One feature at a time
  - Clear acceptance criteria
  - Limited research needed

- **Examples**
  - "Build a user registration form"
  - "Refactor the payment module"
  - "Add unit tests for the API client"

## Prefer orchestra When

- **Backend architecture**
  - API design decisions
  - Database schema design
  - System integration

- **Research-intensive tasks**
  - Evaluating technologies
  - Multi-source analysis
  - Best practice research

- **Design exploration**
  - Early-stage ambiguity
  - Multiple viable approaches
  - Trade-off analysis needed

- **Multi-modal input**
  - Analyzing diagrams or images
  - Processing documents
  - Video/audio references

- **Examples**
  - "Design the authentication system architecture"
  - "Research caching strategies for our use case"
  - "Analyze this architecture diagram and suggest improvements"

## Prefer hybrid When

- **Large, long-running projects**
  - 3+ months duration
  - Multiple domains (frontend + backend + infra)
  - Team collaboration

- **Mixed requirements**
  - Some features need TDD
  - Some features need research
  - Evolving requirements

- **Phased development**
  - Research phase → Implementation phase
  - Design decisions needed mid-sprint

- **Examples**
  - "Building a new product from scratch"
  - "Major system rewrite"
  - "Platform migration project"

## Add perspective When (orchestra/hybrid + --perspective)

- **Multi-model differentiated coordination**
  - Different models for different roles (design vs implementation vs review)
  - Structured 2-Wave workflow (research/design then build/verify)
  - Budget-constrained tasks needing economic scheduling

- **Knowledge-intensive development**
  - Domain-specific knowledge bases per perspective
  - NotebookLM integration for deep expertise
  - Historical decision tracking and win-rate optimization

- **Quality-critical projects**
  - Mandatory multi-perspective verification gates
  - Formal merge verdicts (CRITICAL/HIGH risk tracking)
  - Structured debate for design bifurcations

- **Examples**
  - "Build a complex system with strict quality gates"
  - "Multi-model coordination for architecture + security + ops"
  - "Domain-heavy project needing curated knowledge per role"

## Default Rule

**When in doubt, choose ecc.**

Rationale:
- Lower complexity
- No external CLI dependencies
- Can always add orchestra tools later
- Can always add `--perspective` to orchestra/hybrid later

## Switching Modes

It's okay to switch modes mid-project:

```bash
# Started with ecc, now need research
claude-route . --mode hybrid --force

# Research complete, back to implementation
claude-route . --mode ecc --force

# Add perspective to existing orchestra project
claude-route . --perspective --force
```

The script preserves your work:
- `.codex/` and `.gemini/` are renamed (not deleted) when switching to ecc
- Perspective assets remain in place (perspective.yaml, knowledge/, mcp-servers/)
- Can be restored if you switch back
