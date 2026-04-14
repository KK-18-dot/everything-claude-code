# Auth, Web Security, and API Hardening

## Authentication and Authorization

### Token Storage

- avoid `localStorage` for session tokens when httpOnly cookies are possible
- use `HttpOnly`, `Secure`, and `SameSite=Strict` where appropriate

### Authorization

Always verify permission before sensitive operations.

Checklist:

- auth required on protected routes
- authorization checked before mutation
- role/ownership verification present
- RLS enabled where the datastore supports it

## XSS Prevention

- sanitize user-provided HTML before rendering
- prefer framework escaping by default
- configure CSP for browser apps

Checklist:

- dangerous HTML flows are sanitized
- no unvalidated dynamic HTML rendering
- CSP or equivalent hardening exists where relevant

## CSRF Protection

- state-changing operations use CSRF protections when session cookies are involved
- same-site cookie policy is explicit

Checklist:

- CSRF tokens or equivalent protection exist
- same-site cookies are configured intentionally

## Rate Limiting

- apply rate limits to all public API endpoints
- use stricter limits on expensive operations such as search, auth, or billing

Checklist:

- abuse-prone endpoints have rate limits
- authenticated and unauthenticated cases are considered

## API and Browser Surface

- security headers set where relevant
- CORS scoped to known origins
- file uploads validated
- error bodies do not leak internals

## Minimal Security Tests

- unauthenticated access fails where expected
- unauthorized role access returns 403
- invalid input returns 400
- rate limits return 429 under load
