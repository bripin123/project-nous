---
name: cso
description: Use for security audits on authentication, payment, sensitive data, or API code. Runs OWASP Top 10 + STRIDE threat modeling checks.
---

# /cso — Security Audit

> Code security inspection based on OWASP Top 10 + STRIDE threat modeling.
> Use when working on authentication, payment, sensitive data, and API endpoints.

## Usage
```
/cso                          # Target currently modified files
/cso src/auth/                # Target specific directory
/cso --full                   # Scan entire project
```

## Inspection Items

### OWASP Top 10 Checklist
1. **Injection** — SQL injection, command injection, LDAP injection
   - Query creation via string interpolation? → parameterized query mandatory
   - `shell=True` + user input? → Fix immediately
2. **Broken Authentication** — Session management, password policies
   - Hardcoded secrets/tokens?
   - Session TTL configured?
3. **Sensitive Data Exposure** — Encryption, logging
   - Passwords/tokens printed in logs?
   - HTTPS forced?
4. **XXE** — XML External Entities
5. **Broken Access Control** — Missing authorization checks
   - Authentication middleware on all endpoints?
   - IDOR (accessing other users' data)?
6. **Security Misconfiguration** — Defaults, debug modes
   - debug=True in production?
   - CORS wildcards?
7. **XSS** — Escaping user input
   - `dangerouslySetInnerHTML`?
   - User input → HTML rendering?
8. **Insecure Deserialization** — pickle, eval
9. **Known Vulnerabilities** — Dependency versions
   - `npm audit` / `pip audit` results?
10. **Insufficient Logging** — Security event tracking

### STRIDE Threat Modeling
| Threat | Question |
|------|------|
| **S**poofing | Can authentication be bypassed? |
| **T**ampering | Can data be modified? |
| **R**epudiation | Can actions be repudiated? (audit logs) |
| **I**nformation Disclosure | Sensitive info exposed? |
| **D**enial of Service | Resource exhaustion attack possible? |
| **E**levation of Privilege | Privilege escalation possible? |

## Output Format
```markdown
## Security Audit Report

### CRITICAL (Fix Immediately)
- [C1] SQL Injection in src/db/query.ts:42 — Uses string interpolation
  → Fix: Change to parameterized query

### HIGH (Fix Recommended Before PR)
- [H1] Hardcoded API key in src/config.ts:15
  → Fix: Move to environment variables

### MEDIUM (Improve Later)
- [M1] CORS wildcard allowed

### INFO
- [I1] npm audit: 0 vulnerabilities
```

## Auto-Fix
- CRITICAL: Suggest code for immediate fix
- HIGH: Suggest fix then wait for user confirmation
- MEDIUM/INFO: Report only
