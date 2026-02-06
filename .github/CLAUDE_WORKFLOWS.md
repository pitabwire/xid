# Claude GitHub Actions Workflows

This repository uses three Claude-powered workflows for fully automated AI-assisted development with intelligent model selection.

## Workflows Overview

### 1. `claude.yml` - Interactive Development Assistant
**Purpose**: Human-triggered AI assistant for feature development, bug fixes, and code changes.
**Model**: Dynamic (Sonnet/Opus based on complexity)

### 2. `claude-code-review.yml` - Automated Code Reviewer
**Purpose**: Automatic PR reviews with intelligent depth control.
**Model**: Dynamic (Sonnet/Opus based on PR complexity)

### 3. `claude-continuous.yml` - Continuous Issue Worker
**Purpose**: Autonomous background worker that continuously processes open issues.
**Model**: Dynamic (Sonnet/Opus based on issue complexity)

---

## 🚀 Key Features

### ✅ Permission-Based Access (No Hardcoded Users)
- Anyone with **write permissions** to the repository can trigger Claude
- Uses GitHub's native permission system (OWNER, MEMBER, COLLABORATOR)
- No manual user list maintenance required

### 🧠 Intelligent Model Selection
- **Sonnet 4.5** for simple tasks: bugs, hotfixes, small features, standard reviews
- **Opus 4.6** for complex tasks: architecture, refactoring, security audits, large PRs
- Automatic detection based on:
  - Labels (`complex`, `security`, `architecture` → Opus)
  - Issue/PR size (>500 lines, >1000 chars → Opus)
  - File count (>20 files → Opus)
  - Content analysis

### 🔄 Continuous Automation
- Scheduled workflow runs every 2 hours
- Automatically picks up open `claude`-labeled issues
- Works iteratively until completion (creates PR)
- Processes up to 3 issues per run
- Labels issues as `in-progress` while working
- Handles blocked states and missing information

### 💰 Cost Optimization
- **Sonnet runs**: ~$0.10-0.50 per task
- **Opus runs**: ~$1-5 per task
- Estimated monthly: $50-200 (based on activity level)
- Automatic timeouts prevent runaway costs
- Concurrent execution limits

---

## Workflow Details

## 1. Interactive Assistant (`claude.yml`)

### Triggers

| Trigger | Permission Required | Description |
|---------|-------------------|-------------|
| Issue labeled `claude` | Write access | Label triggers immediate work |
| Issue opened with `claude` label | Write access | Auto-start on issue creation |
| `@claude` in issue comment | OWNER/MEMBER/COLLABORATOR | Interactive help |
| `@claude` in PR review | OWNER/MEMBER/COLLABORATOR | Code assistance |
| `@claude` in PR comment | OWNER/MEMBER/COLLABORATOR | Quick fixes |
| Schedule (every 30 min) | N/A | Continue incomplete work |
| Manual dispatch | Write access | Force run on specific issue |

### Model Selection Logic

```yaml
Uses Opus if:
  - Labels contain: complex, architecture, refactor, performance, claude-opus
  - Issue body > 1000 characters
  - PR changes > 500 lines
  - Explicitly forced via workflow_dispatch

Uses Sonnet otherwise:
  - Labels contain: bug, hotfix, simple, documentation
  - Standard issues and PRs
  - Quick fixes and reviews
```

### Configuration

```yaml
Sonnet Mode:
  - Max turns: 100
  - Timeout: 30 minutes
  - Estimated cost: $0.20-1.00

Opus Mode:
  - Max turns: 150
  - Timeout: 45 minutes
  - Estimated cost: $1-5
```

### Allowed Tools

- **Git**: All operations (commit, branch, push, etc.)
- **GitHub CLI**: Issues, PRs, API access
- **Package managers**: npm, npx, flutter, dart, pytest, go test
- **File operations**: Read, Write, Edit, Glob, Grep, LS
- **Web access**: WebSearch, WebFetch
- **Delegation**: Task (spawn sub-agents)

---

## 2. Code Review (`claude-code-review.yml`)

### Triggers

- PR opened, synchronized, or marked ready for review
- Only on code file changes (excludes docs, configs)
- Works for ALL PRs (not just external contributors)

### File Filters

**✅ Reviewed**:
- `.dart`, `.ts`, `.tsx`, `.js`, `.jsx`
- `.go`, `.py`, `.java`, `.kt`, `.swift`, `.rs`
- `.c`, `.cpp`, `.h`
- `pubspec.yaml`, `package.json`, `go.mod`, `Cargo.toml`, `requirements.txt`

**❌ Skipped**:
- `.md`, `docs/**`, `.github/**`
- `.yml`, `.yaml`, `LICENSE`, `.gitignore`

### Review Depth Modes

| Mode | Trigger | Model | Focus |
|------|---------|-------|-------|
| **Thorough** | Labels: `security`, `critical`, `architecture`<br>OR >500 lines changed<br>OR >20 files | Opus | Deep security audit, architecture review, comprehensive analysis |
| **Standard** | Normal PRs | Sonnet | Security, bugs, performance, quality |
| **Focused** | Labels: `hotfix`, `bug`, `simple` | Sonnet | Critical issues only, quick scan |

### Labels for Control

- `skip-review` / `no-review`: Skip automated review
- `security` / `critical` / `architecture`: Force thorough Opus review
- `hotfix` / `bug` / `simple`: Use focused Sonnet review

### Configuration

```yaml
Sonnet (Standard/Focused):
  - Max turns: 50
  - Timeout: 15 minutes
  - Estimated cost: $0.10-0.30

Opus (Thorough):
  - Max turns: 75
  - Timeout: 20 minutes
  - Estimated cost: $0.50-2.00
```

---

## 3. Continuous Worker (`claude-continuous.yml`)

### Triggers

- **Scheduled**: Every 2 hours (configurable via cron)
- **Manual**: Workflow dispatch with issue count parameter

### How It Works

```
1. Find open issues with 'claude' label
   ↓
2. Filter out issues already with PRs
   ↓
3. Filter out issues labeled 'in-progress' or 'blocked'
   ↓
4. Process up to 3 issues (one at a time)
   ↓
5. For each issue:
   - Mark as 'in-progress'
   - Determine complexity → select model
   - Work iteratively until complete
   - Create PR when done
   - Remove 'in-progress' label
```

### Issue Labels

| Label | Meaning |
|-------|---------|
| `claude` | Issue ready for Claude to work on |
| `in-progress` | Currently being worked on (auto-added) |
| `blocked` | Cannot proceed (needs manual intervention) |
| `needs-info` | Requires clarification from human |
| `complex`, `architecture` | Will use Opus |
| `simple`, `bug` | Will use Sonnet |

### Workflow Behavior

**Success Path**:
```
Issue created with 'claude' label
  → Next scheduled run picks it up
  → Marks 'in-progress'
  → Analyzes and implements
  → Runs tests
  → Creates PR with "Closes #123"
  → Removes 'in-progress'
  → Issue auto-closes when PR merges
```

**Blocked Path**:
```
Issue being worked on
  → Encounters missing info or blocker
  → Adds 'blocked' or 'needs-info' label
  → Posts comment explaining issue
  → Removes 'in-progress'
  → Human addresses concerns
  → Removes 'blocked' label
  → Next run retries
```

### Configuration

```yaml
Schedule: Every 2 hours (0 */2 * * *)
Max parallel: 1 issue at a time
Max issues per run: 3
Process timeout: 45 minutes per issue
```

---

## Setup Instructions

### 1. Configure Secrets

**Required secrets** (Settings → Secrets → Actions):

```
CLAUDE_CODE_OAUTH_TOKEN
  - Get from: https://claude.ai/settings/oauth
  - Permissions: Full access to Claude Code Action
  - Scope: Repository access

GH_PAT (GitHub Personal Access Token)
  - Get from: https://github.com/settings/tokens
  - Scope: repo (full control)
  - Needed for: Comment cleanup in claude.yml
```

### 2. Enable Workflows

No additional configuration needed! Workflows are permission-based:

- ✅ Any user with **write access** can use Claude
- ✅ Labels can only be added by users with write access (GitHub enforces this)
- ✅ No hardcoded usernames to maintain

### 3. Optional: Customize Behavior

**Adjust scheduling** (claude-continuous.yml):
```yaml
schedule:
  - cron: '0 */1 * * *'  # Every 1 hour (more frequent)
  - cron: '0 8-18 * * 1-5'  # Work hours only (M-F 8am-6pm UTC)
```

**Force model selection** (add labels to issues/PRs):
```
- claude-opus: Force Opus for any task
- simple: Force Sonnet even if large
- skip-review: Skip automated PR review
```

**Change continuous worker limits**:
```yaml
inputs:
  max_issues:
    default: '5'  # Process 5 issues per run instead of 3
```

---

## Usage Examples

### Example 1: Quick Bug Fix (Sonnet)

```
1. Create issue: "Fix null pointer in login handler"
2. Add label: 'claude' + 'bug'
3. Within 30 minutes, Claude:
   - Analyzes the code
   - Identifies the bug
   - Fixes it
   - Tests it
   - Creates PR
4. Review and merge PR
5. Issue auto-closes
```

**Model**: Sonnet (simple task)
**Time**: ~5-10 minutes
**Cost**: ~$0.30

### Example 2: Feature Implementation (Sonnet)

```
1. Create issue: "Add user profile picture upload"
2. Add label: 'claude'
3. Wait for continuous worker (max 2 hours)
4. Claude implements:
   - Upload component
   - Backend API integration
   - Image validation
   - Tests
5. Claude creates PR
6. Review, request changes if needed
7. @claude in PR: "Add image compression"
8. Claude updates PR
9. Merge
```

**Model**: Sonnet (standard feature)
**Time**: ~20-30 minutes
**Cost**: ~$0.80

### Example 3: Architecture Refactor (Opus)

```
1. Create issue: "Refactor authentication to use JWT with refresh tokens"
2. Add labels: 'claude' + 'architecture'
3. Wait for continuous worker
4. Claude (using Opus):
   - Analyzes current auth system
   - Designs new architecture
   - Implements JWT infrastructure
   - Updates all auth endpoints
   - Migrates existing sessions
   - Comprehensive tests
5. Creates detailed PR with architecture docs
6. Team reviews thoroughly
7. Merge after approval
```

**Model**: Opus (complex architecture)
**Time**: ~45-60 minutes
**Cost**: ~$3-5

### Example 4: PR Review (Dynamic)

```
Developer creates PR:

Small PR (100 lines, bug fix):
  → Sonnet review (focused mode)
  → Cost: ~$0.15
  → Time: ~2 minutes

Medium PR (300 lines, feature):
  → Sonnet review (standard mode)
  → Cost: ~$0.30
  → Time: ~5 minutes

Large PR (800 lines, refactor):
  → Opus review (thorough mode)
  → Cost: ~$1.50
  → Time: ~10 minutes

Security PR (any size with 'security' label):
  → Opus review (thorough mode)
  → Deep security analysis
  → Cost: ~$2.00
  → Time: ~15 minutes
```

### Example 5: Continuous Automation

```
Developer's workflow:
1. Create 5 issues, all labeled 'claude'
2. Go to lunch
3. Return to find:
   - 3 issues with PRs ready for review
   - 1 issue labeled 'needs-info' (Claude asked questions)
   - 1 issue still 'in-progress' (large feature)
4. Answer the question on needs-info issue
5. Remove 'needs-info' label
6. Next run (2 hours): Claude completes it
```

---

## Cost Analysis

### Monthly Cost Estimates

**Light usage** (10 issues, 20 reviews/month):
```
Issues:
  - 7 simple (Sonnet): 7 × $0.50 = $3.50
  - 3 complex (Opus): 3 × $3.00 = $9.00

Reviews:
  - 15 standard (Sonnet): 15 × $0.20 = $3.00
  - 5 thorough (Opus): 5 × $1.50 = $7.50

Total: ~$23/month
```

**Medium usage** (30 issues, 50 reviews/month):
```
Issues:
  - 20 simple (Sonnet): 20 × $0.50 = $10.00
  - 10 complex (Opus): 10 × $3.00 = $30.00

Reviews:
  - 40 standard (Sonnet): 40 × $0.20 = $8.00
  - 10 thorough (Opus): 10 × $1.50 = $15.00

Total: ~$63/month
```

**Heavy usage** (100 issues, 150 reviews/month):
```
Issues:
  - 70 simple (Sonnet): 70 × $0.50 = $35.00
  - 30 complex (Opus): 30 × $3.00 = $90.00

Reviews:
  - 120 standard (Sonnet): 120 × $0.20 = $24.00
  - 30 thorough (Opus): 30 × $1.50 = $45.00

Total: ~$194/month
```

### Cost Optimization Tips

1. **Use labels to control model selection**
   - Add `simple` label to force Sonnet for straightforward tasks
   - Reserve Opus for truly complex work

2. **Skip unnecessary reviews**
   - Add `skip-review` label to docs-only PRs
   - Set up branch protection to require reviews only for critical paths

3. **Adjust continuous worker frequency**
   - Change from every 2 hours to every 4 hours
   - Run only during work hours

4. **Break large tasks into smaller issues**
   - Smaller issues run faster and cheaper
   - Better for tracking progress

---

## Advanced Configuration

### Custom Model Selection Rules

Edit `claude.yml` and `claude-code-review.yml`:

```yaml
# Force Opus for specific file patterns
if [[ -f "src/security/*" || -f "src/auth/*" ]]; then
  MODEL="claude-opus-4-6"
fi

# Force Sonnet for test files
if [[ "$FILES" == *"test"* ]]; then
  MODEL="claude-sonnet-4-5"
fi
```

### Project-Specific Instructions

Create `.claude/` directory with instructions:

```markdown
# .claude/instructions.md

## Code Style
- Use TypeScript strict mode
- Follow Airbnb style guide
- 100% test coverage required

## Testing
- Run: npm test
- Add integration tests for API changes

## Security
- Never commit API keys
- Sanitize all user inputs
- Use parameterized queries

## Deployment
- Always update CHANGELOG.md
- Tag releases with semantic versioning
```

Claude will automatically read and follow these instructions.

### Conditional Workflows

```yaml
# Only run for specific branches
on:
  pull_request:
    branches:
      - main
      - develop
      - 'release/**'

# Only run for specific paths
paths:
  - 'src/**'
  - 'lib/**'
  - '!**/*.md'
```

---

## Troubleshooting

### Claude not responding to triggers

**Check**:
1. User has write permissions (Settings → Collaborators)
2. `CLAUDE_CODE_OAUTH_TOKEN` is configured
3. Workflow is enabled (Actions tab → select workflow → Enable)
4. Check workflow run logs for errors

### Continuous worker not picking up issues

**Check**:
1. Issue has `claude` label
2. Issue is open (not closed)
3. Issue doesn't already have a PR linked
4. Issue isn't labeled `in-progress` or `blocked`
5. Wait for next scheduled run (every 2 hours)

**Force immediate run**:
```
Actions → Claude Continuous Work → Run workflow → Manual dispatch
```

### Wrong model selected

**Override**:
- For Opus: Add `claude-opus` or `complex` label
- For Sonnet: Add `simple` or `bug` label
- For manual: Use workflow_dispatch with `force_model` input

### Workflow timeout

**Solutions**:
1. Break task into smaller issues
2. Add `complex` label to get Opus with longer timeout
3. Increase timeout in workflow file:
   ```yaml
   timeout-minutes: 60  # Increase from 45
   ```

### Costs too high

**Actions**:
1. Review model selection rules (check if Opus overused)
2. Add `skip-review` to docs/config PRs
3. Reduce continuous worker frequency
4. Set max issues per run to 1-2
5. Use labels to force Sonnet more often

---

## Security Best Practices

### What Claude Can Do ✅

- Read all repository files
- Create branches and commits
- Create and update issues/PRs
- Run tests and builds
- Search the web
- Use package managers

### What Claude Cannot Do ❌

- Modify repository settings
- Add/remove collaborators
- Delete branches (protected by GitHub)
- Access secrets (except provided ones)
- Publish packages (no publish permissions)
- Modify workflows (on main branch)

### Recommendations

1. **Use branch protection**
   - Require PR reviews before merge
   - Require status checks
   - Restrict direct pushes to main

2. **Monitor activity**
   - Check Actions tab regularly
   - Review all Claude PRs before merge
   - Audit monthly costs

3. **Rotate secrets**
   - Rotate `CLAUDE_CODE_OAUTH_TOKEN` quarterly
   - Rotate `GH_PAT` quarterly
   - Use fine-grained PATs when available

4. **Review permissions**
   - Regularly audit collaborators
   - Remove access for inactive users
   - Use teams for group permissions

---

## Migration Guide

### From Old Workflows

If updating from previous version:

1. **Remove hardcoded users**
   ```yaml
   # Old (remove this)
   contains(fromJson('["user1", "user2"]'), github.event.sender.login)

   # New (already implemented)
   # Uses GitHub's native permission system
   ```

2. **Update secrets**
   - Same secrets work: `CLAUDE_CODE_OAUTH_TOKEN` and `GH_PAT`

3. **Add continuous workflow**
   ```bash
   # Copy claude-continuous.yml to .github/workflows/
   ```

4. **Update documentation**
   - Replace user lists with "anyone with write access"
   - Add continuous automation info

---

## Support & Resources

- **Claude Code Documentation**: https://code.claude.com/docs
- **GitHub Actions**: https://docs.github.com/actions
- **Issues**: Report problems in this repository
- **Feature Requests**: Open an issue with `enhancement` label

---

## Changelog

### Version 2.0 (Current)

- ✅ Permission-based access (no hardcoded users)
- ✅ Intelligent model selection (Sonnet/Opus)
- ✅ Continuous automation workflow
- ✅ Label-based complexity control
- ✅ Dynamic review depth modes
- ✅ Cost optimization measures

### Version 1.0 (Previous)

- Basic Claude integration
- Fixed Opus model
- Manual triggers only
- Hardcoded user access
