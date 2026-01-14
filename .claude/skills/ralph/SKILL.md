---
name: ralph
description: "Autonomous AI agent loop that implements PRD stories iteratively. Use when asked to 'run ralph', 'start ralph', 'implement the PRD', or 'execute prd.json'. Spawns fresh subagents for each story until all are complete."
---

# Ralph Orchestrator

You orchestrate the Ralph autonomous implementation loop using Claude Code's Task tool to spawn fresh subagents for each user story.

## Execution Flow

When invoked:

### 1. Initialization

Read and validate state using the **Read tool** (not bash):

1. **Read prd.json** - Use the Read tool to get the full JSON content
2. **Check current branch** - Use `git branch --show-current`
3. **Read progress.txt** - Use the Read tool to check the Codebase Patterns section

**IMPORTANT**: Always use the Read tool to read prd.json and progress.txt. Do NOT use bash commands like `cat` or `jq` as they have cross-platform escaping issues.

### 2. Branch Setup

Ensure you're on the correct branch from prd.json `branchName`:

```bash
# Check if branch exists and checkout, or create from main
git checkout <branchName> 2>/dev/null || git checkout -b <branchName> main
```

### 3. Iteration Loop

For each iteration (default max 10):

**Step 1: Check completion status**

Use the **Read tool** to read prd.json, then parse the JSON to:
1. Count stories where `passes: false`
2. Find the next incomplete story (lowest priority number where `passes: false`)

Example parsing logic:
- Read the `userStories` array from the JSON
- Filter to stories where `passes` is `false`
- Sort by `priority` (ascending)
- The first one is the next story to implement

**Step 2: If all complete, announce success and exit**

If all stories have `passes: true`:
```
Ralph completed all user stories successfully!

Summary:
- Project: [project name]
- Branch: [branch name]
- Stories completed: [count]

All stories have been implemented, tested, and committed.
```

**Step 3: Otherwise, spawn worker subagent**

Use the Task tool with `subagent_type: general-purpose` and include the ralph-worker instructions from `.claude/agents/ralph-worker.md` in the prompt.

First, read `.claude/agents/ralph-worker.md` to get the full worker instructions, then spawn with:

```
Task tool parameters:
- subagent_type: general-purpose
- description: "Implement [Story ID] [Story Title]"
- prompt: [Include full content of ralph-worker.md, plus:]

---
## Current Task Context

Implement the next incomplete user story from prd.json.

**Story to implement:** [Story ID] - [Story Title]
**Acceptance Criteria:** [List from prd.json]

Read the following files to understand the current state:
- prd.json - Find the story details
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

Use the **Read tool** to re-read prd.json and check if more stories remain:
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

Use the Read tool to check status:
- **prd.json** - Parse to see story completion status
- **progress.txt** - Read to see recent learnings

Git commands for history:
```bash
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

## Cross-Platform Notes

**CRITICAL**: This skill must work on Windows, macOS, and Linux.

- **DO NOT** use `jq` - it's not installed by default on Windows
- **DO NOT** pipe JSON through bash - escaping issues between shells
- **DO** use the Read tool to read JSON files directly
- **DO** parse JSON content natively (Claude can parse JSON)
- **DO** use simple git commands that work cross-platform
