---
name: security-review
description: Use when adding authentication, handling user input, creating API endpoints, working with secrets, processing payments, or implementing sensitive features. Performs a structured security review with severity-tagged findings and directs deeper checks through references.
triggers:
  - "review this for security"
  - "add auth"
  - "handle secrets"
  - "new api endpoint"
  - "payment flow"
  - "file upload"
---

# Security Review

Use this skill when the change could introduce security risk. The goal is to surface concrete vulnerabilities, not to provide generic reassurance.

## Working Model

1. Identify the risk surface.
2. Open only the relevant reference file.
3. Review implementation against the matching checklist.
4. Report findings with severity, file references, and remediation.

## Risk Surface Map

- Secrets, input validation, SQL access, logging:
  - `references/secrets-input-data.md`
- Auth, sessions, XSS, CSRF, headers, rate limits, API exposure:
  - `references/auth-web-api.md`
- Solana/blockchain flows and dependency hygiene:
  - `references/blockchain-dependencies.md`

## Core Review Checklist

- Secrets are not hardcoded and are loaded from env/runtime config.
- User input is schema-validated before use.
- Database access uses parameterized queries or safe ORM patterns.
- Sensitive actions have authentication and authorization checks.
- User-controlled HTML/content is sanitized or safely escaped.
- State-changing requests have CSRF/session protections where relevant.
- Rate limits exist on expensive or abuse-prone endpoints.
- Logs and error messages do not leak secrets or internal details.
- Dependencies and lockfiles are maintained.

## Output Contract

Return findings first, ordered by severity.

For each finding include:

- severity
- affected file/path
- concrete risk
- why the current implementation is unsafe
- the smallest safe remediation

If no findings are present, say that explicitly and list residual risks or unverified areas.

## Troubleshooting

### Unsure which reference to open

Open the one matching the highest-risk surface first. Do not load all references by default.

### The change spans multiple surfaces

Review by surface in this order:

1. auth/secrets
2. input/database
3. browser/runtime exposure
4. dependencies/blockchain specifics

### Security is implied but not obvious in code

Check configuration files, env usage, middleware, cookies, headers, and deployment assumptions before concluding.

## Validation

- Trigger test:
  - activates on auth, secrets, API, uploads, payment, or security-review requests
- Function test:
  - returns concrete findings instead of generic best practices
- Performance test:
  - opens only relevant references instead of loading the full corpus

## References

- `references/secrets-input-data.md`
- `references/auth-web-api.md`
- `references/blockchain-dependencies.md`
