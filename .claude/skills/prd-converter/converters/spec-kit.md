# GitHub Spec Kit Conversion Rules

This document describes how to convert GitHub Spec Kit specifications to Ralph's prd.json format.

## Input Detection

Detect Spec Kit format by looking for (in order of preference):

1. **`specs/` directory** (preferred) with numbered subdirectories
2. **`.speckit/` directory** (legacy/alternative)

Within either directory, look for:
- Numbered directories (001-xxx/, 002-xxx/, etc.)
- `spec.md`, `plan.md`, `tasks.md` files in each numbered directory
- `[NEEDS CLARIFICATION:]` markers in spec.md
- `FR-X:` functional requirements markers

## Spec Kit Structure

Typical Spec Kit project structure:
```
specs/                        # Preferred location
├── .registry/                # Spec Kit metadata
├── .backups/                 # Backup files
├── 001-feature-one/
│   ├── spec.md              # What to build (user stories)
│   ├── plan.md              # How to build it (technical)
│   ├── tasks.md             # Breakdown of work
│   ├── research.md          # Research notes (optional)
│   ├── quickstart.md        # Execution guide (optional)
│   └── checklists/          # Feature-specific checklists
│       └── requirements.md
├── 002-feature-two/
│   ├── spec.md
│   ├── plan.md
│   └── tasks.md
└── ...
```

Alternative (legacy) structure:
```
.speckit/
├── constitution.md         # Project guidelines
├── 001-feature-one/
│   └── ...
└── checklists/
    └── quality.md
```

## File Parsing

### spec.md (User Stories)

Real Spec Kit format uses priority markers and Gherkin-style scenarios:

```markdown
# Feature Specification: Feature Name

**Feature Branch**: `001-feature-name`
**Created**: 2025-12-11
**Status**: Draft

## Clarifications
- Q: Question asked → A: Answer received

## User Scenarios & Testing

### User Story 1 - Story Title (Priority: P1)

As a [user type], I want [goal] so that [benefit].

**Why this priority**: Explanation of priority choice.

**Independent Test**: How this story can be tested standalone.

**Acceptance Scenarios**:

1. **Given** precondition, **When** action, **Then** expected result.
2. **Given** another precondition, **When** action, **Then** result.

---

### User Story 2 - Another Story (Priority: P2)
...

### Edge Cases
- Edge case 1: How to handle
- Edge case 2: How to handle

## Requirements

### Functional Requirements
- **FR-001**: System MUST do something
- **FR-002**: System MUST do something else

### Key Entities
- **Entity Name**: Description

### Definitions
- **Term**: Definition
```

### plan.md (Technical Plan)

```markdown
# Implementation Plan: Feature Name

**Branch**: `001-feature-name` | **Date**: 2025-12-11

## Summary
Brief description of what will be built.

## Technical Context
**Language/Version**: .NET 8 / C# 12  (or "N/A" for non-code features)
**Primary Dependencies**: List of dependencies
**Testing**: Test approach
**Constraints**: Any constraints

## Constitution Check
| Principle | Status | Notes |
|-----------|--------|-------|
| P1: ... | ✅ PASS | ... |

## Project Structure
Where files will be created/modified.

## Complexity
| Component | Complexity | Notes |
|-----------|------------|-------|
| Backend   | Medium     | ...   |
| Frontend  | High       | ...   |
```

### tasks.md (Task Breakdown)

```markdown
# Tasks: Feature Name

**Tests**: Required / Not required
**Organization**: How tasks are organized

## Phase 1: Setup
- [X] T001 Completed task
- [ ] T002 [P] Parallel task (can run with others)
- [ ] T003 [US1] Task for User Story 1

**Checkpoint**: What should be true after this phase

## Phase 2: Implementation
- [ ] T004 [P] [US1] Parallel task for US1
- [ ] T005 [US2] Task for User Story 2

## Dependencies & Execution Order
- Phase 1 must complete before Phase 2
- Tasks marked [P] can run in parallel
```

## Mapping Rules

### From spec.md

1. Extract `## User Scenarios & Testing` section
2. Each `### User Story X - Title (Priority: PX)` becomes a user story
3. Parse priority from `(Priority: P1)` marker:
   - P1 → priority 1-10
   - P2 → priority 11-20
   - P3 → priority 21-30
   - P4 → priority 31-40
4. Convert Gherkin scenarios to acceptance criteria
5. Include edge cases in notes
6. Extract functional requirements as additional validation

### From plan.md

1. Use branch name from header or `## Branch` section
2. Check `## Technical Context` for feature type:
   - If "Language/Version: N/A" → non-code feature
   - If mentions .NET/C# → code feature
3. Use complexity table for story sizing validation
4. Check constitution status for any concerns

### From tasks.md

1. If tasks.md exists, use it to validate story breakdown
2. Map `[USX]` markers to corresponding user stories
3. Tasks marked `[P]` indicate parallelizable work
4. Checkpoints define natural story boundaries
5. Count unchecked tasks per story for sizing

## Priority from Directory Numbering

Spec Kit uses numbered directories for ordering:

| Directory | Priority Range |
|-----------|---------------|
| 001-xxx | 1-10 |
| 002-xxx | 11-20 |
| 003-xxx | 21-30 |
| etc. | +10 per directory |

Within a directory, use story priority markers (P1, P2, P3, P4) to order:
- P1 stories get lowest priority numbers (most important)
- P4 stories get highest priority numbers (least important)

## Handling Special Markers

### [NEEDS CLARIFICATION:]

When you encounter:
```markdown
- [NEEDS CLARIFICATION:] What should happen on timeout?
```

1. Add to story notes, not acceptance criteria
2. Flag for user review before execution
3. Do not mark as blocking unless critical

### [OPTIONAL:] or [NICE-TO-HAVE:]

```markdown
- [OPTIONAL:] Dark mode support
```

1. Create separate lower-priority story
2. Or add to notes for future consideration

## Branch Name Mapping

| Spec Kit Convention | prd.json Convention |
|--------------------|---------------------|
| `feature/auth` | `ralph/auth` |
| `feat/user-login` | `ralph/user-login` |
| No branch specified | `ralph/[directory-name]` |

## Example Transformation

**Spec Kit Input:**

`.speckit/001-auth/spec.md`:
```markdown
# User Authentication

## Overview
Implement user authentication for the application.

## User Stories

### User Login
As a user, I want to log in with my credentials so I can access my account.

**Acceptance Criteria:**
- Valid credentials grant access
- Invalid credentials show error message
- Session persists for 24 hours
- [NEEDS CLARIFICATION:] Should we support "remember me"?

### User Logout
As a logged-in user, I want to log out to secure my session.

**Acceptance Criteria:**
- Logout button visible when authenticated
- Clicking logout clears session
- User redirected to login page
```

`.speckit/001-auth/plan.md`:
```markdown
# Implementation Plan

## Branch
`feature/user-auth`

## Dependencies
- Requires database setup (000-setup)
```

**prd.json Output:**
```json
{
  "project": "MyApp",
  "branchName": "ralph/user-auth",
  "description": "User Authentication",
  "userStories": [
    {
      "id": "US-001-001",
      "title": "User Login",
      "description": "As a user, I want to log in with my credentials so I can access my account.",
      "acceptanceCriteria": [
        "Valid credentials grant access",
        "Invalid credentials show error message",
        "Session persists for 24 hours",
        "dotnet build passes",
        "dotnet test passes",
        "dotnet format --verify-no-changes passes",
        "Verify in browser using Playwright MCP"
      ],
      "priority": 1,
      "passes": false,
      "notes": "NEEDS CLARIFICATION: Should we support 'remember me'?"
    },
    {
      "id": "US-001-002",
      "title": "User Logout",
      "description": "As a logged-in user, I want to log out to secure my session.",
      "acceptanceCriteria": [
        "Logout button visible when authenticated",
        "Clicking logout clears session",
        "User redirected to login page",
        "dotnet build passes",
        "dotnet test passes",
        "dotnet format --verify-no-changes passes",
        "Verify in browser using Playwright MCP"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Multi-Spec Conversion

When converting an entire `.speckit/` directory with multiple specs:

1. Process specs in directory number order
2. Generate one prd.json per spec directory
3. Or optionally combine into single prd.json with scoped priorities

### Combined Example

```json
{
  "project": "MyApp",
  "branchName": "ralph/full-feature-set",
  "description": "Combined specs 001-003",
  "userStories": [
    {"id": "US-001-001", "priority": 1, "...": "from 001-auth"},
    {"id": "US-001-002", "priority": 2, "...": "from 001-auth"},
    {"id": "US-002-001", "priority": 11, "...": "from 002-dashboard"},
    {"id": "US-002-002", "priority": 12, "...": "from 002-dashboard"},
    {"id": "US-003-001", "priority": 21, "...": "from 003-settings"}
  ]
}
```

## Story ID Convention

For Spec Kit conversions, use compound IDs:

```
US-[directory-number]-[story-number]
```

Examples:
- `US-001-001` - First story in 001-xxx directory
- `US-001-002` - Second story in 001-xxx directory
- `US-002-001` - First story in 002-xxx directory

This preserves traceability back to the original spec.

## Story Sizing & Automatic Breakdown

Spec Kit tasks can be too large for a single Ralph iteration. **Stories will be automatically split** based on the following rules.

### Size Indicators (Too Large)

A story is **TOO LARGE** if it has ANY of these:
- More than 5 feature-specific acceptance criteria
- Contains "and" connecting distinct features
- Mentions multiple entities/tables
- Includes both backend AND frontend work
- Contains full CRUD (Create, Read, Update, Delete)
- Estimated to touch more than 3-4 files
- tasks.md shows more than 4-5 checkbox items for a single story

### Using Complexity Table

The plan.md complexity table helps identify stories needing breakdown:

```markdown
## Complexity
| Component | Complexity | Notes |
|-----------|------------|-------|
| Backend   | High       | Multiple entities, complex logic |
| Frontend  | Medium     | Several components |
```

If a single story has both Backend: High and Frontend: Medium+, split it.

### Automatic Breakdown Rules

#### CRUD Operations → Split by Operation

**Input (spec.md):**
```markdown
### User Profile Management
As a user, I want to manage my profile information.

**Acceptance Criteria:**
- User can view profile
- User can update profile fields
- User can upload avatar
- User can delete account
```

**Output:**
```json
[
  {
    "id": "US-001-001a",
    "title": "View User Profile",
    "notes": "Split from User Profile Management",
    "originalStoryId": "US-001-001",
    "priority": 1
  },
  {
    "id": "US-001-001b",
    "title": "Update Profile Fields",
    "notes": "Split from User Profile Management",
    "priority": 2
  },
  {
    "id": "US-001-001c",
    "title": "Upload Profile Avatar",
    "notes": "Split from User Profile Management",
    "priority": 3
  },
  {
    "id": "US-001-001d",
    "title": "Delete User Account",
    "notes": "Split from User Profile Management",
    "priority": 4
  }
]
```

#### Backend + Frontend → Split by Layer

**Input (spec.md):**
```markdown
### Task Filtering
As a user, I want to filter tasks by status so I can focus on relevant items.

**Acceptance Criteria:**
- Add Status field to Task entity
- Create filter API endpoint
- Display filter dropdown in UI
- Show filtered results
```

**Output:**
```json
[
  {
    "id": "US-002-001a",
    "title": "Add Status Entity and Migration",
    "acceptanceCriteria": [
      "Status enum added to Task entity",
      "EF Core migration created",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes"
    ],
    "priority": 1,
    "notes": "Split from Task Filtering - Backend/Schema"
  },
  {
    "id": "US-002-001b",
    "title": "Task Filter API Endpoint",
    "acceptanceCriteria": [
      "GET /api/tasks?status={status} endpoint created",
      "Returns filtered task list",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes"
    ],
    "priority": 11,
    "notes": "Split from Task Filtering - Backend/API"
  },
  {
    "id": "US-002-001c",
    "title": "Filter Dropdown Component",
    "acceptanceCriteria": [
      "Filter dropdown displays status options",
      "Selection triggers API call",
      "Results update without page refresh",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes",
      "Verify in browser using Playwright MCP"
    ],
    "priority": 51,
    "notes": "Split from Task Filtering - Frontend"
  }
]
```

#### Using tasks.md for Breakdown Hints

If tasks.md exists, use it to validate breakdown:

**tasks.md:**
```markdown
## Phase 1: Database
- [ ] Add Status enum
- [ ] Create migration
- [ ] Update Task entity

## Phase 2: API
- [ ] Add filter endpoint
- [ ] Add tests

## Phase 3: UI
- [ ] Create dropdown component
- [ ] Wire up to API
```

This suggests three natural split points matching the phases.

### Standard Acceptance Criteria

Every story output must include these standard criteria:
```json
{
  "acceptanceCriteria": [
    "Feature-specific criterion 1",
    "Feature-specific criterion 2",
    "Unit tests written (happy path + edge case)",
    "Follows project architecture patterns from PRD/CLAUDE.md",
    "dotnet build passes",
    "dotnet test passes",
    "dotnet format --verify-no-changes passes"
  ]
}
```

For UI stories, also add:
```json
"Verify in browser using Playwright MCP"
```

### Traceability

All split stories maintain compound IDs:

```json
{
  "id": "US-001-001a",
  "title": "View User Profile",
  "notes": "Split from US-001-001: User Profile Management",
  "originalStoryId": "US-001-001"
}
```

The ID format is: `US-[directory]-[story][split-letter]`

### User Confirmation

After breakdown analysis, report:
```
Spec Kit Story Breakdown Complete:
- 001-auth/: 2 stories (right-sized)
- 002-dashboard/:
  - "Task Filtering" → 3 stories (US-002-001a through US-002-001c)
  - "Dashboard Layout" → 2 stories (US-002-002a through US-002-002b)
- 003-settings/: 4 stories (right-sized)

Total: 13 stories ready for Ralph execution.
Proceed with conversion? [Y/n]
```

## Validation

Before outputting prd.json:

- [ ] All spec.md files have been parsed
- [ ] Dependencies from plan.md inform priority ordering
- [ ] Complexity table used to identify stories needing breakdown
- [ ] [NEEDS CLARIFICATION:] items are in notes, not criteria
- [ ] Large stories split according to breakdown rules
- [ ] .NET quality criteria added to all stories
- [ ] Unit test criterion added to all stories
- [ ] UI stories have Playwright verification criterion
- [ ] Story IDs include directory number prefix
- [ ] Split stories include originalStoryId for traceability
- [ ] Branch name follows ralph/ convention
