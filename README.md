# Ralph for Claude Code

![Ralph](ralph.webp)

Ralph is an autonomous AI agent loop that uses Claude Code subagents to iteratively implement features from a PRD. Each iteration spawns a fresh subagent with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

**This is a Claude Code adaptation** - for the original Amp version, see the [upstream repository](https://github.com/snarktank/ralph).

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed and authenticated
- .NET SDK 8.0+ installed
- A git repository for your project

## Setup

### Option 1: Copy to your project

Copy the Ralph files into your .NET project:

```bash
# From your project root
cp -r /path/to/ralph/.claude .
cp /path/to/ralph/CLAUDE.md .
```

### Option 2: Install skills globally

Copy the skills to your Claude Code config for use across all projects:

```bash
cp -r .claude/skills/* ~/.claude/skills/
```

## Workflow

### 1. Create a PRD

Use your preferred PRD generation method:

**Option A: BMAD Method**
```bash
npx bmad-method@alpha install
# Then use BMAD agents to create epics and user stories
```

**Option B: GitHub Spec Kit**
```bash
uvx --from git+https://github.com/github/spec-kit.git specify init my-feature
# Then use /speckit.specify, /speckit.plan, /speckit.tasks
```

**Option C: Manual PRD**
Create a markdown file with `## User Stories` section containing your requirements.

### 2. Convert PRD to Ralph format

Use the converter skill to convert your PRD to prd.json:

```
/prd-converter                    # Auto-detect PRD in current directory
/prd-converter path/to/prd.md     # Convert specific file
/prd-converter .speckit/          # Convert Spec Kit output
```

The converter will:
- Detect the PRD format automatically (BMAD, Spec Kit, or plain markdown)
- Extract user stories with acceptance criteria
- Add .NET quality gate criteria
- Order stories by dependency
- Output `prd.json` ready for Ralph

### 3. Run Ralph

```
/ralph
```

Or with a custom iteration limit:

```
/ralph 20
```

Default is 10 iterations.

Ralph will:
1. Create a feature branch (from PRD `branchName`)
2. Pick the highest priority story where `passes: false`
3. Spawn a fresh subagent to implement that story
4. Run quality checks (`dotnet build`, `dotnet test`, `dotnet format`)
5. Commit if checks pass
6. Update `prd.json` to mark story as `passes: true`
7. Append learnings to `progress.txt`
8. Repeat until all stories pass or max iterations reached

## Key Files

| File | Purpose |
|------|---------|
| `.claude/skills/ralph/` | Main orchestrator skill |
| `.claude/agents/ralph-worker.md` | Worker subagent that implements stories |
| `.claude/skills/prd-converter/` | Converts PRDs to prd.json (supports BMAD, Spec Kit, markdown) |
| `prd.json` | User stories with `passes` status |
| `progress.txt` | Append-only learnings for future iterations |
| `CLAUDE.md` | Project patterns and conventions |
| `INSTALLATION.md` | Detailed setup instructions |

## .NET Quality Gates

All commits must pass:
- `dotnet build` - Compilation succeeds
- `dotnet test` - All tests pass
- `dotnet format --verify-no-changes` - Code formatting correct

Run the quality gate script manually:
```powershell
.\.claude\skills\ralph\scripts\validate-quality.ps1
```

## Flowchart

[![Ralph Flowchart](ralph-flowchart.png)](https://snarktank.github.io/ralph/)

**[View Interactive Flowchart](https://snarktank.github.io/ralph/)** - Click through to see each step with animations.

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new subagent** with clean context. The only memory between iterations is:
- Git history (commits from previous iterations)
- `progress.txt` (learnings and context)
- `prd.json` (which stories are done)
- `CLAUDE.md` (project patterns)

### Small Tasks

Each PRD item should be small enough to complete in one context window. If a task is too big, the LLM runs out of context before finishing.

**Right-sized stories:**
- Add an EF Core entity and migration
- Add a Blazor component to an existing page
- Create a single API endpoint
- Add a filter dropdown to a list

**Too big (split these):**
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### CLAUDE.md Updates Are Critical

After each iteration, Ralph updates `CLAUDE.md` with learnings. Claude Code automatically reads this file, so future iterations (and human developers) benefit from discovered patterns, gotchas, and conventions.

Examples of what to add to CLAUDE.md:
- Patterns discovered ("use repository pattern for data access")
- Gotchas ("run `dotnet ef migrations add` after modifying entities")
- Useful context ("the settings panel is in Components/Settings/")

### Feedback Loops

Ralph only works if there are feedback loops:
- `dotnet build` catches compilation errors
- `dotnet test` verifies behavior
- Quality gates must stay green (broken code compounds across iterations)

### Browser Verification for UI Stories

Frontend stories must include "Verify in browser using Playwright MCP" in acceptance criteria. Ralph uses Playwright MCP to navigate to the page, interact with the UI, and confirm changes work.

## Debugging

Check current state:

```bash
# See which stories are done
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings from previous iterations
cat progress.txt

# Check git history
git log --oneline -10
```

## Supported PRD Sources

### Plain Markdown PRD
Standard requirements document with user stories section.

### BMAD Method
The [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) produces structured epics with FR-XX, US-XX identifiers and Gherkin-style acceptance criteria.

```
/prd-converter path/to/bmad-prd.md --format bmad
```

### GitHub Spec Kit
[GitHub Spec Kit](https://github.com/github/spec-kit) produces `.speckit/` directories with spec.md, plan.md, and tasks.md files.

```
/prd-converter .speckit/
```

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD)
- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Spec-Driven Development Blog Post](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
