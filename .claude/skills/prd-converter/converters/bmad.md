# BMAD Method Conversion Rules

This document describes how to convert BMAD Method PRDs to Ralph's prd.json format.

## Input Detection

Detect BMAD format by looking for (in order of preference):

### 1. Modern BMAD (`_bmad-output/` directory)

Check for `_bmad-output/` directory containing:
- `planning-artifacts/epics.md` - **Primary source** for story definitions (REQUIRED)
- `planning-artifacts/prd.md` - Project context and requirements (for description)
- `implementation-artifacts/sprint-status.yaml` - Story status tracking (optional)

**This is the preferred BMAD format** - uses `epics.md` as the single source of truth for stories.

### 2. Legacy BMAD (Markdown with identifiers)

Look for these markers in markdown files:
- FR-XX, NFR-XX, US-XX identifiers
- `## Epics` or `### Epic:` headers
- Gherkin-style criteria (Given/When/Then)
- `## Functional Requirements` section

---

## Modern BMAD Structure

### Directory Layout

```
_bmad-output/
├── planning-artifacts/
│   ├── prd.md                    # Product requirements (for context)
│   ├── epics.md                  # Story definitions with acceptance criteria
│   ├── architecture.md           # Architecture decisions
│   └── ...
├── implementation-artifacts/
│   ├── sprint-status.yaml        # Status tracking (optional)
│   └── X-Y-story-name.md         # Individual story files (not used by converter)
└── project-context.md            # Project summary
```

### Epics.md Format

The `epics.md` file contains all story definitions:

```markdown
## Epic 1: Project Foundation & Developer Shell

Developers can run the project locally with Aspire dashboard...

### Story 1.1: Initialize Aspire Solution Structure

As a **developer**,
I want **a .NET Aspire solution with AppHost and ServiceDefaults projects**,
So that **I can orchestrate services locally and have standardized configuration**.

**Acceptance Criteria:**

**Given** a fresh development environment with .NET 10 SDK installed
**When** I clone the repository and open the solution
**Then** I see a solution file with AppHost and ServiceDefaults projects
**And** the AppHost project references ServiceDefaults
**And** `dotnet build` completes without errors

---

### Story 1.2: Add Blazor Web Application Projects
...
```

### Sprint Status YAML (Optional)

If `sprint-status.yaml` exists, use it to filter stories by status:

```yaml
development_status:
  epic-1: in-progress
  1-1-initialize-aspire-solution-structure: ready-for-dev
  1-2-add-blazor-web-application-projects: backlog
  epic-2: backlog
  2-1-implement-landing-page-layout: backlog
```

**Status filtering rules:**
- `backlog` - Include in prd.json
- `ready-for-dev` - Include in prd.json
- `in-progress` - Include in prd.json (agent decides to continue or skip)
- `review` - Optionally include (in review, may be done)
- `done` - Exclude from prd.json (already completed)

**Default behavior**: If no sprint-status.yaml exists, include ALL stories from epics.md.

---

## Parsing Rules

### Extracting Stories from epics.md

1. **Find Epic Headers**: Look for `## Epic X:` or `### Epic X:` patterns
2. **Find Story Headers**: Look for `### Story X.Y:` or `#### Story X.Y:` patterns
3. **Extract Story Content**:
   - **Title**: Text after `Story X.Y:`
   - **Description**: "As a..., I want..., So that..." section
   - **Acceptance Criteria**: Gherkin blocks (Given/When/Then/And)

### Story ID Format

Modern BMAD uses `X-Y` format (epic-story number):

| Input | prd.json ID |
|-------|-------------|
| `Story 1.1:` | `1-1` |
| `Story 2.3:` | `2-3` |
| `Story 10.5:` | `10-5` |

### Gherkin to Acceptance Criteria

Convert Gherkin syntax to imperative statements:

**Input:**
```markdown
**Given** a fresh development environment with .NET 10 SDK installed
**When** I clone the repository and open the solution
**Then** I see a solution file with AppHost and ServiceDefaults projects
**And** the AppHost project references ServiceDefaults
**And** `dotnet build` completes without errors
```

**Output:**
```json
{
  "acceptanceCriteria": [
    "Solution with AppHost and ServiceDefaults projects created",
    "AppHost references ServiceDefaults",
    "dotnet build completes without errors"
  ]
}
```

**Conversion patterns:**
- Combine Given/When into context, Then becomes the assertion
- **And** items become separate criteria
- Remove markdown formatting (`**`, backticks)
- Make statements imperative and concise

---

## Priority Assignment

Map epic number to priority ranges:

| Epic | Priority Range | Description |
|------|----------------|-------------|
| Epic 1 | 1-10 | Foundation, infrastructure |
| Epic 2 | 11-20 | Landing experience, trust signals |
| Epic 3 | 21-40 | Core user input/entry |
| Epic 4 | 41-60 | Backend analysis, APIs |
| Epic 5 | 61-80 | Results display, output |
| Epic 6 | 81-90 | Session management |
| Epic 7 | 91-100 | Error handling |
| Epic 8 | 101-110 | Legal, onboarding |
| Epic 9+ | 111+ | Analytics, polish |

Within each epic, stories are prioritized by their story number:
- Story 1.1 = priority 1
- Story 1.2 = priority 2
- Story 2.1 = priority 11
- Story 2.2 = priority 12

**Formula**: `priority = (epic - 1) * 10 + story_number`

(Adjust ranges if epic has many stories)

---

## Example Transformation

### Modern BMAD Input

**`_bmad-output/planning-artifacts/epics.md`:**
```markdown
# TooManyMeds - Epic Breakdown

## Epic 1: Project Foundation & Developer Shell

Developers can run the project locally with Aspire dashboard...

### Story 1.1: Initialize Aspire Solution Structure

As a **developer**,
I want **a .NET Aspire solution with AppHost and ServiceDefaults projects**,
So that **I can orchestrate services locally and have standardized configuration**.

**Acceptance Criteria:**

**Given** a fresh development environment with .NET 10 SDK installed
**When** I clone the repository and open the solution
**Then** I see a solution file with AppHost and ServiceDefaults projects
**And** the AppHost project references ServiceDefaults
**And** `dotnet build` completes without errors
**And** `dotnet run --project src/TooManyMeds.AppHost` launches the Aspire dashboard

---

### Story 1.2: Add Blazor Web Application Projects

As a **developer**,
I want **Blazor Web App with Server and Client projects configured for InteractiveAuto**,
So that **the app renders server-side first then transitions to WebAssembly**.

**Acceptance Criteria:**

**Given** the Aspire solution from Story 1.1
**When** I add the Web and Web.Client projects
**Then** TooManyMeds.Web is a Blazor Web App with InteractiveAuto render mode
**And** both projects target .NET 10 with nullable reference types enabled
**And** the AppHost orchestrates the Web project
```

### prd.json Output

```json
{
  "project": "TooManyMeds",
  "branchName": "ralph/too-many-meds-foundation",
  "description": "TooManyMeds - Patient medication interaction checker. Epic 1: Project Foundation & Developer Shell",
  "userStories": [
    {
      "id": "1-1",
      "title": "Initialize Aspire Solution Structure",
      "description": "As a developer, I want a .NET Aspire solution with AppHost and ServiceDefaults projects, so that I can orchestrate services locally and have standardized configuration.",
      "acceptanceCriteria": [
        "Solution with AppHost and ServiceDefaults projects created",
        "AppHost references ServiceDefaults",
        "dotnet run --project src/TooManyMeds.AppHost launches Aspire dashboard",
        "Setup verified (solution builds and runs)",
        "Follows project architecture patterns from CLAUDE.md",
        "dotnet build passes",
        "dotnet format --verify-no-changes passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": "Part of Epic 1: Project Foundation & Developer Shell. Type: Infrastructure"
    },
    {
      "id": "1-2",
      "title": "Add Blazor Web Application Projects",
      "description": "As a developer, I want Blazor Web App with Server and Client projects configured for InteractiveAuto, so that the app renders server-side first then transitions to WebAssembly.",
      "acceptanceCriteria": [
        "TooManyMeds.Web is Blazor Web App with InteractiveAuto render mode",
        "Both projects target .NET 10 with nullable reference types enabled",
        "AppHost orchestrates the Web project",
        "Setup verified (solution builds and runs)",
        "Follows project architecture patterns from CLAUDE.md",
        "dotnet build passes",
        "dotnet format --verify-no-changes passes"
      ],
      "priority": 2,
      "passes": false,
      "notes": "Part of Epic 1: Project Foundation & Developer Shell. Depends on 1-1."
    }
  ]
}
```

---

## Story Sizing & Automatic Breakdown

Stories in BMAD epics.md are often already well-sized since BMAD's story creation process is iterative. However, **stories may still need splitting** based on these rules.

### Size Indicators (Too Large)

A story is **TOO LARGE** if it has ANY of these:
- More than 5 feature-specific acceptance criteria (excluding standard .NET criteria)
- Contains "and" connecting distinct features
- Mentions multiple entities/tables
- Includes both backend AND frontend work
- Contains full CRUD (Create, Read, Update, Delete)
- Estimated to touch more than 3-4 files

### Automatic Breakdown Rules

#### CRUD Operations → Split by Operation

**Input:**
```markdown
### Story 3.4: Medication List Management
- User can add medications
- User can view medication list
- User can edit medication details
- User can remove medications
```

**Output:**
```json
[
  {"id": "3-4a", "title": "Add Medication to List", "priority": 31},
  {"id": "3-4b", "title": "View Medication List", "priority": 32},
  {"id": "3-4c", "title": "Edit Medication Details", "priority": 33},
  {"id": "3-4d", "title": "Remove Medication from List", "priority": 34}
]
```

#### Backend + Frontend → Split by Layer

**Input:**
```markdown
### Story 4.1: RxNorm Integration
- Create RxNorm API client
- Add medication search endpoint
- Build autocomplete component
- Display search results
```

**Output:**
```json
[
  {"id": "4-1a", "title": "RxNorm API Client", "priority": 41, "notes": "Backend"},
  {"id": "4-1b", "title": "Medication Search Endpoint", "priority": 42, "notes": "Backend"},
  {"id": "4-1c", "title": "Autocomplete Component", "priority": 43, "notes": "Frontend"},
  {"id": "4-1d", "title": "Display Search Results", "priority": 44, "notes": "Frontend"}
]
```

### Story Type Detection

Before adding acceptance criteria, detect the story type:

| Type | Indicators | Example Stories |
|------|------------|-----------------|
| **Infrastructure** | "Initialize", "Configure", "Add...Project", creates *.csproj | 1-1, 1-2, 1-3, 1-5 |
| **Backend Logic** | "Build...Client", "Implement...Service", creates services/handlers | 1-4, 3-1, 4-2, 4-3, 4-4 |
| **UI Component** | "Display", "Create...Component", Blazor pages | 2-1, 2-2, 3-2, 3-3, 5-1 |
| **Integration** | "Integrate", "Add...Monitoring", external service config | 4-1, 4-10, 9-1 |

### Type-Specific Acceptance Criteria

**Infrastructure Stories** (setup, scaffolding, tooling):
```json
{
  "acceptanceCriteria": [
    "Feature-specific criterion 1",
    "Setup verified (solution builds and runs)",
    "Follows project architecture patterns from CLAUDE.md",
    "dotnet build passes",
    "dotnet format --verify-no-changes passes"
  ]
}
```

**Backend Logic Stories** (services, handlers, business logic):
```json
{
  "acceptanceCriteria": [
    "Feature-specific criterion 1",
    "Unit tests written (happy path + edge case)",
    "Follows project architecture patterns from CLAUDE.md",
    "dotnet build passes",
    "dotnet test passes",
    "dotnet format --verify-no-changes passes"
  ]
}
```

**UI Component Stories** (Blazor components, pages):
```json
{
  "acceptanceCriteria": [
    "Feature-specific criterion 1",
    "Component tests written (bUnit)",
    "Follows project architecture patterns from CLAUDE.md",
    "dotnet build passes",
    "dotnet test passes",
    "dotnet format --verify-no-changes passes",
    "Verify in browser using Playwright MCP"
  ]
}
```

**Integration Stories** (external services, static pages):
```json
{
  "acceptanceCriteria": [
    "Feature-specific criterion 1",
    "Integration verified (external service connected/configured)",
    "Follows project architecture patterns from CLAUDE.md",
    "dotnet build passes",
    "dotnet format --verify-no-changes passes"
  ]
}
```

### Traceability

All split stories must maintain traceability to the original:

```json
{
  "id": "3-4a",
  "title": "Add Medication to List",
  "notes": "Split from 3-4: Medication List Management",
  "originalStoryId": "3-4"
}
```

---

## User Confirmation

After analysis, report the breakdown:

```
BMAD Story Conversion Complete:
- Source: _bmad-output/planning-artifacts/epics.md
- Project: TooManyMeds
- Branch: ralph/toomanyeds-foundation

Stories extracted:
- Epic 1: 6 stories (1-1 through 1-6)
- Epic 2: 4 stories (2-1 through 2-4)
- Epic 3: 9 stories (3-1 through 3-9)
...

Sizing analysis:
- 35 stories are right-sized
- 3 stories were split:
  - 3-4 "Medication Management" → 4 stories (3-4a through 3-4d)
  - 4-1 "RxNorm Integration" → 4 stories (4-1a through 4-1d)
  - 5-7 "PDF Report" → 3 stories (5-7a through 5-7c)

Total: 46 stories ready for Ralph execution.
Proceed with conversion? [Y/n]
```

---

## Legacy BMAD Format (for reference)

If `_bmad-output/` is not found, fall back to legacy detection:

### Legacy Structure

```markdown
# Feature Name

## Epics

### Epic 1: Core Functionality
#### US-001: First Story
**Description:** As a user, I want...

**Acceptance Criteria:**
- Given X, When Y, Then Z

## Functional Requirements
- FR-01: The system shall...

## Non-Functional Requirements
- NFR-01: Performance requirement...
```

### Legacy ID Mapping

| BMAD ID | prd.json ID |
|---------|-------------|
| US-001 | US-001 |
| FR-03 | FR-003 |
| NFR-01 | NFR-001 |
