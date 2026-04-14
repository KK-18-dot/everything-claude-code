# Secrets, Input, SQL, and Data Exposure

## Secrets Management

### Never

```typescript
const apiKey = "sk-proj-xxxxx"
const dbPassword = "password123"
```

### Always

```typescript
const apiKey = process.env.OPENAI_API_KEY
const dbUrl = process.env.DATABASE_URL

if (!apiKey) {
  throw new Error("OPENAI_API_KEY not configured")
}
```

Checklist:

- no hardcoded API keys, tokens, or passwords
- secrets sourced from env/runtime config
- local env files are ignored
- secrets are not printed in logs or errors

## Input Validation

Use schema validation before processing user input.

```typescript
import { z } from "zod"

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})
```

Checklist:

- all user inputs validated with schemas
- whitelist validation, not blacklist filtering
- file uploads restricted by size, type, and extension
- errors do not leak internal details

## SQL Injection Prevention

Never concatenate SQL strings with user data.

```typescript
await db.query("SELECT * FROM users WHERE email = $1", [userEmail])
```

Checklist:

- parameterized queries everywhere
- safe ORM/query builder usage
- no raw string interpolation in SQL

## Sensitive Data Exposure

### Logging

Never log passwords, tokens, raw payment data, or secrets.

### Error Messages

Return generic errors to users and keep detailed errors server-side.

Checklist:

- no secrets in logs
- no stack traces exposed to clients
- internal errors recorded only on trusted surfaces
