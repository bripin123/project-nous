---
name: deploy
description: Use when deploying to production. Runs merge, CI wait, production verification, and post-deploy monitoring pipeline.
---

# /deploy — Deployment Pipeline

> Batch execution of merge → CI wait → production verification → post-deploy monitoring.
> Use during actual deployment after a PR is approved.

## Usage
```
/deploy                          # Deploy current branch
/deploy --dry-run                # Check only, no actual deployment
/deploy --canary                 # Include post-deploy monitoring
```

## Protocol

### Phase 1: Pre-Deploy Check
1. **Verify Branch Status**
   - Verify current branch is not a base branch (prevent direct deploy from main/master)
   - Verify sync status with remote (`git status`, `git fetch`)
   - Verify no merge conflicts

2. **Testing Gate**
   - Run all tests
   - If failed → Abort immediately, requires fix
   - Verify type check + lint passes

3. **Verify tasks.md Completion**
   - If incomplete tasks exist → Report to user
   - Options: Implement / Defer to next / Remove

### Phase 2: Merge
1. Create PR (if none exists)
   - Title: Change summary (under 70 chars)
   - Body: Summary + Test Plan
2. Execute merge (after user confirmation)
3. Wait for CI status (if applicable)

### Phase 3: Deployment Execution
1. Detect project deployment method:
   - `vercel.json` → Vercel deploy
   - `Dockerfile` → Docker build
   - `fly.toml` → Fly.io deploy
   - `package.json` scripts → npm run deploy
   - If detection fails → Ask user for deployment command
2. Execute deployment command (after user confirmation)
3. Verify deployment success

### Phase 4: Canary Monitoring (If --canary option)
1. Check status immediately after deployment:
   - Call healthcheck endpoint (if applicable)
   - Check error logs
   - Verify major functionality operates
2. If anomalies detected → Suggest rollback

### Phase 5: Deployment Completion Report
```markdown
## Deploy Report

### Pre-Deploy
- Tests: ✅ All passed
- Type Check: ✅ Clean
- tasks.md: ✅ All completed

### Merge
- PR: #[N] merged
- CI: ✅ passed

### Deploy
- Platform: [Vercel/Docker/etc]
- Status: ✅ Success
- URL: [Deployment URL]

### Canary (If applicable)
- Healthcheck: ✅
- Errors: 0 items
```

## Notes
- Deployment commands are always executed after user confirmation (no auto-execution)
- --dry-run mode: Performs only Phase 1 checks, no actual deployment/merge
- If rollback is required, suggest it along with specific commands
