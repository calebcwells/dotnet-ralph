---
name: prd-converter
description: "Converts PRDs to prd.json format for Ralph execution. Supports BMAD Method, GitHub Spec Kit, and plain markdown formats. Use when asked to 'convert prd', 'create prd.json', 'run ralph on this', or 'prepare for ralph'. This is the primary entry point before running /ralph."
---

# PRD Converter

Converts Product Requirements Documents from various formats into Ralph's `prd.json` format. This is the **primary entry point** before running Ralph.

## Supported Formats

| Format | Detection | Example |
|--------|-----------|---------|
| **BMAD Method** | FR-XX, US-XX, NFR-XX identifiers, Gherkin syntax | Output from BMAD agents |
| **GitHub Spec Kit** | `.speckit/` directory structure | Output from `/speckit.specify` |
| **Plain Markdown** | `## User Stories` section | Manual PRD documents |

## Usage

```
/prd-converter                                   # Auto-detect PRD in current directory
/prd-converter path/to/prd.md                    # Convert specific file
/prd-converter .speckit/                         # Convert Spec Kit specs
/prd-converter docs/requirements/                # Convert from directory
```

## Auto-Detection

When invoked without arguments, the converter will search for PRDs in this order:

1. `.speckit/` directory (Spec Kit format)
2. `*.prd.md` files in current directory
3. `PRD.md` or `prd.md` in current directory
4. `tasks/prd-*.md` files
5. `docs/` or `requirements/` directories

## Workflow

### 1. Detect Format

First, identify the input format:

- **BMAD**: Look for FR-XX, NFR-XX, US-XX identifiers, "## Epics" headers, Gherkin syntax (Given/When/Then)
- **Spec Kit**: Look for `.speckit/` directory with spec.md, plan.md, tasks.md
- **Plain Markdown**: Standard PRD with "## User Stories" or "## Requirements" sections

### 2. Parse Input

Read the input file(s) and extract:
- Project name and description
- Branch name (or generate one)
- User stories with acceptance criteria

### 3. Apply Conversion Rules

Use the appropriate converter rules:
- BMAD: See `converters/bmad.md`
- Spec Kit: See `converters/spec-kit.md`
- Plain Markdown: Direct mapping with story sizing validation

### 4. Add Standard Acceptance Criteria

Append these acceptance criteria to every story:
- `Unit tests written (happy path + edge case)`
- `Follows project architecture patterns from PRD/CLAUDE.md`
- `dotnet build passes`
- `dotnet test passes`
- `dotnet format --verify-no-changes passes`

For UI stories, also add:
- `Verify in browser using Playwright MCP`

### 5. Story Sizing Analysis & Automatic Breakdown

Before outputting prd.json, analyze each story for size. **Stories that are too large will be automatically split.**

#### Size Indicators (Too Large)

A story is **TOO LARGE** if it has ANY of these:
- More than 5 feature-specific acceptance criteria
- Contains "and" connecting distinct features
- Mentions multiple entities/tables
- Includes both backend AND frontend work
- Contains full CRUD (Create, Read, Update, Delete)
- Estimated to touch more than 3-4 files

#### Automatic Breakdown Rules

**CRUD Operations → Split into individual operations:**
```
"User management CRUD" →
  - US-001a: Create User (backend)
  - US-001b: Get User by ID (backend)
  - US-001c: Update User (backend)
  - US-001d: Delete User (backend)
  - US-001e: List Users with pagination (backend)
```

**Backend + Frontend → Split by layer:**
```
"Add priority field to tasks" →
  - US-001a: Add Priority entity/migration (backend)
  - US-001b: Add Priority API endpoint (backend)
  - US-001c: Display Priority in UI (frontend)
  - US-001d: Add Priority selector component (frontend)
```

**Multiple Entities → Split by entity:**
```
"Order system with products and customers" →
  - US-001a: Product entity and repository
  - US-001b: Customer entity and repository
  - US-001c: Order entity with relationships
  - US-001d: Order creation endpoint
```

#### Output Format for Split Stories

When breaking down, maintain traceability:
```json
{
  "id": "US-001a",
  "title": "Create User - Backend",
  "description": "...",
  "notes": "Split from original US-001: User Management",
  "originalStoryId": "US-001"
}
```

#### User Confirmation

After analysis, report the breakdown:
```
Story Analysis Complete:
- 3 stories are right-sized
- 2 stories were split:
  - "User CRUD" → 5 stories (US-002a through US-002e)
  - "Order flow" → 4 stories (US-005a through US-005d)

Total: 12 stories ready for Ralph execution.
Proceed with conversion? [Y/n]
```

### 6. Output prd.json

Generate the final prd.json with this structure:

```json
{
  "project": "ProjectName",
  "branchName": "ralph/feature-name",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Story Title",
      "description": "As a user, I want X so that Y",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "dotnet build passes",
        "dotnet test passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Priority Assignment

Stories should be ordered by dependency:

| Priority Range | Story Type |
|---------------|------------|
| 1-10 | Infrastructure/Schema (database, models) |
| 11-50 | Backend Logic (services, APIs) |
| 51-100 | UI/Integration (components, pages) |
| 101+ | Polish/Optimization |

## Validation Checklist

Before outputting prd.json, verify:

- [ ] Each story has a unique ID
- [ ] Priorities are in dependency order (schema before UI)
- [ ] All stories have .NET quality criteria
- [ ] UI stories have browser verification criterion
- [ ] No story is too large (recommend splits if needed)
- [ ] Branch name follows `ralph/feature-name` convention
- [ ] All `passes` fields are set to `false`

## Example Conversion

**Input (Plain Markdown):**
```markdown
# User Authentication Feature

## User Stories

### US-001: User Login
As a user, I want to log in with email and password.

**Acceptance Criteria:**
- Email and password form displayed
- Successful login redirects to dashboard
- Invalid credentials show error message
```

**Output (prd.json):**
```json
{
  "project": "MyApp",
  "branchName": "ralph/user-authentication",
  "description": "User Authentication Feature",
  "userStories": [
    {
      "id": "US-001",
      "title": "User Login",
      "description": "As a user, I want to log in with email and password.",
      "acceptanceCriteria": [
        "Email and password form displayed",
        "Successful login redirects to dashboard",
        "Invalid credentials show error message",
        "Unit tests written (happy path + edge case)",
        "Follows project architecture patterns from PRD/CLAUDE.md",
        "dotnet build passes",
        "dotnet test passes",
        "dotnet format --verify-no-changes passes",
        "Verify in browser using Playwright MCP"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```
