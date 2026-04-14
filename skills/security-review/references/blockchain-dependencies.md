# Blockchain-Specific and Dependency Checks

## Solana / Wallet Flows

Checklist:

- wallet signatures are verified
- transaction recipient and amount are validated
- balances and limits are checked before submission
- there is no blind signing path

## Dependency Hygiene

Checklist:

- lockfiles are committed
- `npm audit` or equivalent is reviewed
- vulnerable dependencies are not ignored silently
- reproducible install command is used in CI

## Deployment Readiness

- HTTPS enforced in production
- security headers configured where relevant
- production secrets live in the hosting platform, not in source control
