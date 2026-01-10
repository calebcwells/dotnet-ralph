# Installing Ralph in Your Project

This guide explains how to add Ralph to your .NET project for autonomous AI-driven development.

## Quick Start

```bash
# From your project root
cp -r /path/to/ralph/.claude .
cp /path/to/ralph/CLAUDE.md .
```

That's it! Ralph is now available in your project via `/ralph`.

---

## Detailed Installation

### Required Files

Copy these files to your project root:

```
your-project/
├── .claude/
│   ├── agents/
│   │   └── ralph-worker.md           # Worker subagent (required)
│   └── skills/
│       ├── ralph/
│       │   ├── SKILL.md              # Orchestrator skill (required)
│       │   └── scripts/
│       │       └── validate-quality.ps1  # .NET quality gates
│       ├── prd-converter/
│       │   ├── SKILL.md              # PRD converter (required)
│       │   └── converters/
│       │       ├── bmad.md           # BMAD conversion rules
│       │       └── spec-kit.md       # Spec Kit conversion rules
│       └── compound-engineering/     # Optional: systematic development
│           └── SKILL.md
├── CLAUDE.md                         # Project patterns (required)
└── prd.json                          # Created when you run /prd-converter
```

### Step-by-Step

1. **Copy the .claude directory:**
   ```bash
   cp -r /path/to/ralph/.claude .
   ```

2. **Copy CLAUDE.md template:**
   ```bash
   cp /path/to/ralph/CLAUDE.md .
   ```

3. **Customize CLAUDE.md for your project:**
   Edit `CLAUDE.md` to add your project-specific patterns and conventions.

4. **Verify installation:**
   ```bash
   ls -la .claude/skills/ralph/
   ls -la .claude/agents/
   ```

---

## File Locations Reference

### Core Ralph Files

| Source | Destination | Purpose |
|--------|-------------|---------|
| `.claude/agents/ralph-worker.md` | `.claude/agents/ralph-worker.md` | Subagent that implements stories |
| `.claude/skills/ralph/SKILL.md` | `.claude/skills/ralph/SKILL.md` | Orchestrator skill |
| `.claude/skills/ralph/scripts/validate-quality.ps1` | `.claude/skills/ralph/scripts/validate-quality.ps1` | .NET quality gate script |
| `.claude/skills/prd-converter/` | `.claude/skills/prd-converter/` | PRD conversion (BMAD, Spec Kit, markdown) |
| `CLAUDE.md` | `CLAUDE.md` | Project patterns template |

### Optional Skills

These skills enhance the Ralph workflow but are not required:

| Source | Destination | Purpose |
|--------|-------------|---------|
| `skills/compound-engineering/SKILL.md` | `.claude/skills/compound-engineering/SKILL.md` | Systematic development methodology |
| `skills/frontend-design/SKILL.md` | `.claude/skills/frontend-design/SKILL.md` | UI/UX design guidelines |
| `skills/pdf/SKILL.md` | `.claude/skills/pdf/SKILL.md` | PDF processing capabilities |
| `skills/docx/SKILL.md` | `.claude/skills/docx/SKILL.md` | Word document handling |

To install optional skills:
```bash
# Copy individual skills you want
cp -r /path/to/ralph/skills/compound-engineering .claude/skills/
cp -r /path/to/ralph/skills/frontend-design .claude/skills/
```

---

## Usage

### Step 1: Create a PRD

Use your preferred PRD generation tool:

**BMAD Method:**
```bash
npx bmad-method@alpha install
# Use BMAD agents to create epics and user stories
```

**GitHub Spec Kit:**
```bash
uvx --from git+https://github.com/github/spec-kit.git specify init my-feature
# Use /speckit.specify, /speckit.plan, /speckit.tasks
```

### Step 2: Convert PRD to prd.json

Ralph works with `prd.json` - a structured list of user stories. Use `/prd-converter` to create it:

```
/prd-converter                        # Auto-detect PRD in current directory
/prd-converter path/to/bmad-output.md # Convert BMAD output
/prd-converter .speckit/              # Convert Spec Kit output
/prd-converter docs/requirements.md   # Convert plain markdown PRD
```

The converter will:
1. Detect the PRD format automatically (BMAD, Spec Kit, or markdown)
2. Extract user stories with acceptance criteria
3. Add .NET quality gate criteria (`dotnet build`, `dotnet test`, `dotnet format`)
4. Order stories by dependency (schema → backend → UI)
5. Output `prd.json` ready for Ralph execution

### Step 3: Run Ralph

Once you have `prd.json`, run Ralph:

```
/ralph
```

Or with a custom iteration limit:
```
/ralph 20
```

Ralph will:
1. Read `prd.json` and find incomplete stories
2. Spawn a fresh subagent for each story
3. Run quality gates after implementation
4. Commit on success and update `prd.json`
5. Continue until all stories have `passes: true`

### Monitoring Progress

```bash
# See story status
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings
cat progress.txt

# Check commits
git log --oneline -10
```

---

## Optional Skills Documentation

### Compound Engineering (`/compound-engineering`)

A systematic development methodology that makes each unit of work improve future work.

**When to use:**
- Planning complex features
- Reviewing code systematically
- Capturing learnings for future reference

**The Loop:**
```
Plan (40%) → Work (20%) → Review (20%) → Compound (20%)
```

**Installation:**
```bash
cp -r /path/to/ralph/skills/compound-engineering .claude/skills/
```

**Usage:**
```
/compound-engineering plan this feature: [description]
/compound-engineering review this code
/compound-engineering compound learnings from [work completed]
```

### Frontend Design (`/frontend-design`)

Guidelines for creating distinctive, production-grade UI that avoids generic "AI slop" aesthetics.

**When to use:**
- Building new UI components
- Designing user interfaces
- Establishing visual identity

**Installation:**
```bash
cp -r /path/to/ralph/skills/frontend-design .claude/skills/
```

**Key Concepts:**
- Commit to a bold aesthetic direction before coding
- Focus on typography, color, motion, and spatial composition
- Avoid overused patterns (purple gradients, generic fonts)

### PDF Processing (`/pdf`)

Comprehensive PDF manipulation capabilities.

**When to use:**
- Extracting text or tables from PDFs
- Merging or splitting PDF documents
- Filling PDF forms
- Generating PDF reports

**Installation:**
```bash
cp -r /path/to/ralph/skills/pdf .claude/skills/
```

**Dependencies:**
- Python with pypdf, pdfplumber, reportlab
- Optional: pytesseract for OCR

### DOCX Processing (`/docx`)

Word document creation, editing, and analysis.

**When to use:**
- Generating documentation
- Editing existing Word documents
- Adding tracked changes
- Converting between formats

**Installation:**
```bash
cp -r /path/to/ralph/skills/docx .claude/skills/
```

**Dependencies:**
- Python with docx package
- Pandoc for format conversion
- Optional: LibreOffice for complex operations

---

## Workflow Examples

### Example 1: Using BMAD Method

```bash
# 1. Install and run BMAD
npx bmad-method@alpha install

# 2. Use BMAD agents to create your PRD
# (This creates structured epics with FR-XX, US-XX identifiers)

# 3. Convert to Ralph format
/prd-converter path/to/bmad-output.md

# 4. Run Ralph
/ralph
```

### Example 2: Using GitHub Spec Kit

```bash
# 1. Initialize Spec Kit
uvx --from git+https://github.com/github/spec-kit.git specify init my-feature

# 2. Create specification (in Claude Code)
/speckit.specify
/speckit.plan
/speckit.tasks

# 3. Convert to Ralph format
/prd-converter .speckit/

# 4. Run Ralph
/ralph
```

### Example 3: With Compound Engineering

```bash
# 1. Plan the feature systematically
/compound-engineering plan: Add user authentication

# 2. Export plan as PRD (if compound-engineering creates a structured plan)
# Or manually create PRD from the plan output

# 3. Convert to Ralph format
/prd-converter tasks/auth-plan.md

# 4. Execute with Ralph
/ralph

# 5. After completion, compound the learnings
/compound-engineering compound learnings from user authentication
```

### Example 4: Quick Start (Auto-Detection)

```bash
# If you already have a PRD in the current directory
/prd-converter    # Auto-detects .speckit/, *.prd.md, PRD.md, etc.
/ralph            # Implements all stories
```

---

## Customizing for Your Project

### CLAUDE.md

Edit `CLAUDE.md` to add your project-specific information:

```markdown
## Project-Specific Notes

- Database: PostgreSQL via EF Core
- Authentication: ASP.NET Core Identity
- Frontend: Blazor Server
- API: Minimal APIs

## Codebase Patterns

- Use repository pattern for data access
- All API responses use ApiResponse<T> wrapper
- Tests use xUnit with Moq
```

### Quality Gates

Edit `.claude/skills/ralph/scripts/validate-quality.ps1` to customize quality checks:

```powershell
# Add custom checks
dotnet build
dotnet test
dotnet format --verify-no-changes

# Add your project-specific checks
# dotnet run --project tools/CustomAnalyzer
```

### Acceptance Criteria

The prd-converter automatically adds these criteria to every story:
- `Unit tests written (happy path + edge case)`
- `Follows project architecture patterns from PRD/CLAUDE.md`
- `dotnet build passes`
- `dotnet test passes`
- `dotnet format --verify-no-changes passes`

For UI stories, it also adds:
- `Verify in browser using Playwright MCP`

---

## MCP Server Setup

Ralph works best with these MCP servers configured in Claude Code.

### Required: Playwright MCP

For browser testing of UI stories. Usually pre-configured in Claude Code.

Verify it's available:
```bash
# Should list playwright tools
claude mcp list | grep playwright
```

### Recommended: Microsoft Learn MCP

Ralph uses this for .NET documentation lookup when encountering issues or unfamiliar APIs.

**Installation:**
```bash
# Add the Microsoft Docs MCP server
claude mcp add microsoft-docs-mcp -- npx -y @anthropic/microsoft-docs-mcp
```

Or add to your Claude Code settings manually:
```json
{
  "mcpServers": {
    "microsoft-docs-mcp": {
      "command": "npx",
      "args": ["-y", "@anthropic/microsoft-docs-mcp"]
    }
  }
}
```

**Usage in Ralph:**
When the worker agent encounters issues, it will use:
- `mcp__microsoft_docs_mcp__microsoft_docs_search` - Search .NET documentation
- `mcp__microsoft_docs_mcp__microsoft_docs_fetch` - Fetch specific doc pages

This helps with EF Core migrations, ASP.NET Core patterns, Blazor components, and .NET 8+ best practices.

---

## Troubleshooting

### Ralph doesn't find stories

Check that `prd.json` exists and has stories with `passes: false`:
```bash
cat prd.json | jq '.userStories[] | select(.passes == false)'
```

### Quality gates fail

Run the quality gate script manually to see errors:
```powershell
.\.claude\skills\ralph\scripts\validate-quality.ps1
```

### Subagent runs out of context

Your stories are too large. The prd-converter should automatically split large stories, but if you're writing prd.json manually, ensure each story:
- Has no more than 5 feature-specific acceptance criteria
- Focuses on either backend OR frontend (not both)
- Handles one entity/feature at a time
- Can be completed by touching 3-4 files max

### Browser testing fails

Ensure Playwright MCP is configured in Claude Code. Check that the application is running locally before browser verification.

### Microsoft Learn MCP not working

If the worker can't search documentation:
1. Verify the MCP server is installed: `claude mcp list`
2. Reinstall if needed: `claude mcp add microsoft-docs-mcp -- npx -y @anthropic/microsoft-docs-mcp`
3. Restart Claude Code after installation

### Unit tests not being written

Every story MUST include tests. If a worker completes without tests:
1. The story should fail quality gates
2. Check that "Unit tests written (happy path + edge case)" is in acceptance criteria
3. Review progress.txt for worker notes on test challenges
