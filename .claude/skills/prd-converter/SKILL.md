---
name: prd-converter
description: "Converts PRDs to prd.json format for Ralph execution. Supports BMAD Method, GitHub Spec Kit, and plain markdown formats. Use when asked to 'convert prd', 'create prd.json', 'run ralph on this', or 'prepare for ralph'. This is the primary entry point before running /ralph."
---

# PRD Converter

Converts Product Requirements Documents from various formats into Ralph's `prd.json` format. This is the **primary entry point** before running Ralph.

## Supported Formats

| Format | Detection | Example |
|--------|-----------|---------|
| **BMAD Method** | `_bmad-output/` directory with epics.md, or FR-XX/US-XX identifiers | Output from BMAD agents |
| **GitHub Spec Kit** | `specs/` or `.speckit/` directory structure | Output from `/speckit.specify` |
| **Plain Markdown** | `## User Stories` section | Manual PRD documents |

## Usage

```
/prd-converter                                   # Auto-detect PRD in current directory
/prd-converter path/to/prd.md                    # Convert specific file
/prd-converter specs/                            # Convert Spec Kit specs
/prd-converter specs/001-feature/                # Convert single spec
/prd-converter docs/requirements/                # Convert from directory
```

## Auto-Detection

When invoked without arguments, the converter will search for PRDs in this order:

1. `_bmad-output/` directory with `planning-artifacts/epics.md` (BMAD Method - preferred)
2. `specs/` directory with numbered subdirs (Spec Kit format)
3. `.speckit/` directory (Spec Kit format - legacy)
4. `*.prd.md` files in current directory (BMAD legacy or plain)
5. `PRD.md` or `prd.md` in current directory
6. `tasks/prd-*.md` files
7. `docs/` or `requirements/` directories

## Workflow

### 1. Detect Format

First, identify the input format:

- **BMAD (Modern)**: Look for `_bmad-output/` directory containing:
  - `planning-artifacts/epics.md` - Story definitions with Gherkin acceptance criteria
  - `planning-artifacts/prd.md` - Product requirements (optional, for project context)
  - `implementation-artifacts/sprint-status.yaml` - Story statuses (optional)
- **BMAD (Legacy)**: Look for FR-XX, NFR-XX, US-XX identifiers, "## Epics" headers, Gherkin syntax in markdown files
- **Spec Kit**: Look for `specs/` or `.speckit/` directory with spec.md, plan.md, tasks.md in numbered subdirs
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

### 4. Detect Story Type

Before adding acceptance criteria, detect the story type to apply appropriate verification requirements.

#### Story Types

| Type | Description | Test Requirement |
|------|-------------|------------------|
| **Infrastructure** | Project setup, scaffolding, tooling config | Setup verified (no unit tests) |
| **Backend Logic** | Services, handlers, business logic, APIs | Unit tests required |
| **UI Component** | Blazor components, pages, forms | Component tests + Playwright |
| **Integration** | External service config, legal pages | Integration verified |
| **Non-Code** | Documentation, audits, reports | Deliverables verified |

#### Infrastructure Story Indicators

A story is **infrastructure** if it has ANY of these:
- Title contains: "Initialize", "Configure", "Add...Project", "Setup", "Create solution"
- Creates project structure (*.csproj, solution files)
- Configures build tools (Tailwind, MSBuild, NuGet packages)
- Sets up development environment (Aspire, Docker, CI/CD)
- First stories in a new project (typically Epic 1, stories 1-3)
- No business logic, just wiring/plumbing

#### Backend Logic Story Indicators

A story is **backend logic** if it has ANY of these:
- Creates services, handlers, repositories, clients
- Implements business rules or validation
- Processes data or transforms state
- Title contains: "Build...Service", "Implement...Logic", "Create...Handler"
- Has testable behavior with inputs/outputs

#### UI Component Story Indicators

A story is **UI component** if it has ANY of these:
- Creates Blazor components or pages
- Implements user interactions (click, type, navigate)
- Title contains: "Display", "Create...Component", "Build...UI", "Implement...Page"
- Acceptance criteria mention visual elements or user actions

#### Integration Story Indicators

A story is **integration** if it has ANY of these:
- Configures external services (Azure, Cloudflare, APIs)
- Creates static pages (Privacy Policy, Terms of Service)
- Sets up monitoring, analytics, health checks
- Title contains: "Integrate", "Add...Monitoring", "Create...Page" (for static content)

#### Non-Code Story Indicators

A story is **non-code** if it has ALL of these:
- Output is documentation only (markdown files, reports)
- No src/ modifications mentioned
- Words like "documentation", "audit", "review", "inventory"

### 5. Add Type-Specific Acceptance Criteria

Based on the detected story type, append appropriate criteria:

**Infrastructure Stories:**
```
- Setup verified (solution builds and runs)
- Follows project architecture patterns from CLAUDE.md
- dotnet build passes
- dotnet format --verify-no-changes passes
```

**Backend Logic Stories:**
```
- Unit tests written (happy path + edge case)
- Follows project architecture patterns from CLAUDE.md
- dotnet build passes
- dotnet test passes
- dotnet format --verify-no-changes passes
```

**UI Component Stories:**
```
- Component tests written (bUnit)
- Follows project architecture patterns from CLAUDE.md
- dotnet build passes
- dotnet test passes
- dotnet format --verify-no-changes passes
- Verify in browser using Playwright MCP
```

**Integration Stories:**
```
- Integration verified (external service connected/configured)
- Follows project architecture patterns from CLAUDE.md
- dotnet build passes
- dotnet format --verify-no-changes passes
```

**Non-Code Stories:**
```
- Deliverables verified (all specified outputs created)
- Follows documentation standards from CLAUDE.md
```

### 6. Story Sizing Analysis & Automatic Breakdown

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

### 7. Output prd.json

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
