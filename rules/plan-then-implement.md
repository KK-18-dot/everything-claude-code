# Plan Then Implement

## Rule

For multi-file, high-risk, or ambiguous work, follow:

1. **Explore** (read-only understanding)
2. **Plan** (step-by-step implementation and verification)
3. **Implement** (execute in small checkpoints)
4. **Review** (validate against plan and constraints)

## When Planning Is Mandatory

- Cross-cutting changes across multiple directories
- Security, auth, payments, migrations, or infra changes
- Unknown codebase area or unclear requirement
- Work that depends on external tool output (Codex/Gemini/MCP)

## Plan Quality Criteria

- Steps are independently testable
- File targets are explicit
- Risks and rollback path are explicit
- Verification command is attached to each major step
