---
name: ralph
description: "Autonomous AI agent loop that implements PRD stories iteratively. Use when asked to 'run ralph', 'start ralph', 'implement the PRD', or 'execute prd.json'. Spawns fresh subagents for each story until all are complete."
---

# Ralph Orchestrator

You orchestrate the Ralph autonomous implementation loop using Claude Code's Task tool to spawn fresh subagents for each user story.

## Execution Flow

When invoked:

### 1. Initialization

Read and validate state:

```bash
# Check prd.json exists
cat prd.json

# Check current branch
git branch --show-current

# Read progress.txt patterns section (if exists)
head -50 progress.txt
```

### 2. Branch Setup

Ensure you're on the correct branch from prd.json `branchName`:

```bash
# Get branch name from PRD
BRANCH=$(cat prd.json | jq -r '.branchName')

# Check if branch exists and checkout, or create from main
git checkout $BRANCH 2>/dev/null || git checkout -b $BRANCH main
```

### 3. Iteration Loop

For each iteration (default max 10):

**Step 1: Check completion status**

Read prd.json and count incomplete stories:
```bash
cat prd.json | jq '[.userStories[] | select(.passes == false)] | length'
```

**Step 2: If all complete, announce success and exit**

If the count is 0 (all stories have `passes: true`):
```
Ralph completed all user stories successfully!

Summary:
- Project: [project name]
- Branch: [branch name]
- Stories completed: [count]

All stories have been implemented, tested, and committed.
```

**Step 3: Otherwise, spawn worker subagent**

Use the Task tool to spawn a ralph-worker subagent:

```
Implement the next incomplete user story from prd.json.

Read the following files to understand the current state:
- prd.json - Find the highest priority story where passes: false
- progress.txt - Check Codebase Patterns section for learnings
- CLAUDE.md - Project conventions and patterns

After implementing:
1. Run quality gates (dotnet build, dotnet test, dotnet format --verify-no-changes)
2. If gates pass, commit the changes
3. Update prd.json to set passes: true for the completed story
4. Append learnings to progress.txt

Current iteration: [N] of [max]
```

**Step 4: After subagent completes**

Re-read prd.json to check if more stories remain:
- If incomplete stories remain, continue to next iteration
- If all complete, announce success and exit

### 4. Max Iterations

If max iterations reached without completion:
```
Ralph reached max iterations ([N]) without completing all stories.

Check progress.txt for status and learnings.

Remaining stories:
[List stories where passes: false with their IDs and titles]

You can run /ralph again to continue from where it left off.
```

## Arguments

- First argument (optional): Maximum iterations, default 10

Usage:
```
/ralph           # Run with default 10 iterations
/ralph 20        # Run with 20 max iterations
```

## State Files

| File | Purpose |
|------|---------|
| `prd.json` | User stories with `passes` status |
| `progress.txt` | Append-only learnings between iterations |
| `CLAUDE.md` | Discovered patterns and conventions |
| Git commits | Code changes with history |

## Monitoring Progress

During execution, you can check:
```bash
# See story status
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See recent progress
tail -50 progress.txt

# Check git history
git log --oneline -10
```

## Error Recovery

If a subagent fails or a story remains incomplete:
1. The story stays `passes: false`
2. Any partial learnings should be in progress.txt
3. Next iteration will retry the same story
4. Consider splitting large stories if repeated failures occur

## Quality Gates

The worker subagent runs these .NET quality checks:
- `dotnet build` - Compilation succeeds
- `dotnet test` - All tests pass
- `dotnet format --verify-no-changes` - Code formatting correct

Stories are only marked complete after all gates pass.

## Browser Testing

For UI stories, the worker subagent uses Playwright MCP:
- `mcp__playwright__browser_navigate` - Navigate to URLs
- `mcp__playwright__browser_click` - Click elements
- `mcp__playwright__browser_type` - Fill form fields
- `mcp__playwright__browser_take_screenshot` - Capture screenshots

No additional setup required - Playwright MCP is built into Claude Code.
