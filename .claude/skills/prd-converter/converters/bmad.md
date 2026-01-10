# BMAD Method Conversion Rules

This document describes how to convert BMAD Method PRDs to Ralph's prd.json format.

## Input Detection

Detect BMAD format by looking for:
- `## Epics` or `### Epic:` headers
- FR-XX, NFR-XX, US-XX identifiers (Functional Requirements, Non-Functional Requirements, User Stories)
- Gherkin-style criteria (Given/When/Then)
- `## Functional Requirements` section
- `## Non-Functional Requirements` section

## BMAD Structure

Typical BMAD PRD structure:
```markdown
# Feature Name

## Introduction
...

## Goals
...

## Epics

### Epic 1: Core Functionality
#### US-001: First Story
**Description:** As a user, I want...

**Acceptance Criteria:**
- Given X, When Y, Then Z
- Given A, When B, Then C

#### US-002: Second Story
...

## Functional Requirements
- FR-01: The system shall...
- FR-02: The system shall...

## Non-Functional Requirements
- NFR-01: Performance requirement...
```

## Mapping Rules

### From Epic to User Stories

1. Each `#### US-XXX:` section maps to one user story
2. Epic context becomes part of story description if helpful
3. Dependencies between epics determine story priority

### From Acceptance Criteria

Convert Gherkin syntax to imperative statements:

| Gherkin | Imperative |
|---------|------------|
| Given X, When Y, Then Z | When Y with X, Z occurs |
| Given logged in user, When submitting form, Then data is saved | Logged-in user can submit form and data is saved |
| Given invalid input, When submitting, Then error shown | Invalid input displays error message |

### From Functional Requirements

FR-XX items that aren't covered by user stories become additional stories:

```markdown
FR-03: The system shall validate email format
```

Becomes:
```json
{
  "id": "FR-003",
  "title": "Email Format Validation",
  "description": "The system shall validate email format",
  "acceptanceCriteria": [
    "Valid email formats are accepted",
    "Invalid email formats show validation error",
    "dotnet build passes",
    "dotnet test passes"
  ]
}
```

### From Non-Functional Requirements

NFR-XX items become acceptance criteria on relevant stories, or separate stories if testable:

- Performance requirements → Add to relevant story criteria
- Security requirements → Separate story if substantial
- Accessibility requirements → Add to UI story criteria

## Priority Assignment

| Priority | Story Type | Examples |
|----------|-----------|----------|
| 1-10 | Infrastructure | Database schema, EF Core models, migrations |
| 11-30 | Core Backend | Services, repositories, business logic |
| 31-50 | API Layer | Controllers, endpoints, middleware |
| 51-80 | UI Components | Blazor components, Razor pages |
| 81-100 | Integration | End-to-end flows, auth integration |
| 101+ | Polish | Performance optimization, edge cases |

## ID Mapping

Preserve original IDs where possible:

| BMAD ID | prd.json ID |
|---------|-------------|
| US-001 | US-001 |
| FR-03 | FR-003 |
| NFR-01 | NFR-001 |

## Example Transformation

**BMAD Input:**
```markdown
### Epic 1: User Authentication

#### US-001: User Registration
**Description:** As a new user, I want to register so I can access the system.

**Acceptance Criteria:**
- Given a valid email, When registering, Then account is created
- Given an existing email, When registering, Then error is shown
- Given weak password, When registering, Then validation error shown

#### US-002: User Login
**Description:** As a registered user, I want to log in to access my account.

**Acceptance Criteria:**
- Given valid credentials, When logging in, Then user is authenticated
- Given invalid credentials, When logging in, Then error is shown
```

**prd.json Output:**
```json
{
  "project": "MyApp",
  "branchName": "ralph/user-authentication",
  "description": "User Authentication - Epic 1",
  "userStories": [
    {
      "id": "US-001",
      "title": "User Registration",
      "description": "As a new user, I want to register so I can access the system.",
      "acceptanceCriteria": [
        "Valid email creates new account",
        "Existing email shows registration error",
        "Weak password shows validation error",
        "dotnet build passes",
        "dotnet test passes",
        "dotnet format --verify-no-changes passes",
        "Verify in browser using Playwright MCP"
      ],
      "priority": 51,
      "passes": false,
      "notes": "Part of Epic 1: User Authentication"
    },
    {
      "id": "US-002",
      "title": "User Login",
      "description": "As a registered user, I want to log in to access my account.",
      "acceptanceCriteria": [
        "Valid credentials authenticate user successfully",
        "Invalid credentials show login error",
        "dotnet build passes",
        "dotnet test passes",
        "dotnet format --verify-no-changes passes",
        "Verify in browser using Playwright MCP"
      ],
      "priority": 52,
      "passes": false,
      "notes": "Part of Epic 1: User Authentication. Depends on US-001."
    }
  ]
}
```

## Story Sizing & Automatic Breakdown

BMAD epics often contain stories that are too large for a single Ralph iteration. **Stories will be automatically split** based on the following rules.

### Size Indicators (Too Large)

A story is **TOO LARGE** if it has ANY of these:
- More than 5 feature-specific acceptance criteria
- Contains "and" connecting distinct features
- Mentions multiple entities/tables
- Includes both backend AND frontend work
- Contains full CRUD (Create, Read, Update, Delete)
- Estimated to touch more than 3-4 files

### Automatic Breakdown Rules

#### CRUD Operations → Split by Operation

**Input:**
```markdown
#### US-010: User Management
**Acceptance Criteria:**
- Admin can create new users
- Admin can view user list
- Admin can update user details
- Admin can delete users
- Users can be filtered by role
```

**Output:**
```json
[
  {
    "id": "US-010a",
    "title": "Create User (Backend)",
    "description": "Admin can create new users in the system",
    "notes": "Split from US-010: User Management",
    "originalStoryId": "US-010",
    "priority": 11
  },
  {
    "id": "US-010b",
    "title": "Get User by ID (Backend)",
    "notes": "Split from US-010: User Management",
    "priority": 12
  },
  {
    "id": "US-010c",
    "title": "Update User (Backend)",
    "notes": "Split from US-010: User Management",
    "priority": 13
  },
  {
    "id": "US-010d",
    "title": "Delete User (Backend)",
    "notes": "Split from US-010: User Management",
    "priority": 14
  },
  {
    "id": "US-010e",
    "title": "List Users with Filtering (Backend)",
    "notes": "Split from US-010: User Management",
    "priority": 15
  }
]
```

#### Backend + Frontend → Split by Layer

**Input:**
```markdown
#### US-005: Task Priority Feature
**Acceptance Criteria:**
- Add Priority field to Task entity
- Create API endpoint for priority updates
- Display priority badge on task cards
- Add priority selector in edit modal
```

**Output:**
```json
[
  {
    "id": "US-005a",
    "title": "Add Priority Entity and Migration",
    "acceptanceCriteria": [
      "Priority enum added to Task entity (High, Medium, Low)",
      "EF Core migration created and applied",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes"
    ],
    "priority": 1,
    "notes": "Split from US-005: Task Priority Feature - Backend/Schema"
  },
  {
    "id": "US-005b",
    "title": "Priority API Endpoint",
    "acceptanceCriteria": [
      "PUT /api/tasks/{id}/priority endpoint created",
      "Endpoint validates priority value",
      "Returns updated task on success",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes"
    ],
    "priority": 11,
    "notes": "Split from US-005: Task Priority Feature - Backend/API"
  },
  {
    "id": "US-005c",
    "title": "Display Priority Badge on Task Cards",
    "acceptanceCriteria": [
      "Priority badge shows on each task card",
      "Colors: red=high, yellow=medium, gray=low",
      "Badge visible without interaction",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes",
      "Verify in browser using Playwright MCP"
    ],
    "priority": 51,
    "notes": "Split from US-005: Task Priority Feature - Frontend/Display"
  },
  {
    "id": "US-005d",
    "title": "Priority Selector in Edit Modal",
    "acceptanceCriteria": [
      "Priority dropdown in task edit modal",
      "Shows current priority as selected",
      "Saves on selection change",
      "Unit tests written (happy path + edge case)",
      "dotnet build passes",
      "dotnet test passes",
      "Verify in browser using Playwright MCP"
    ],
    "priority": 52,
    "notes": "Split from US-005: Task Priority Feature - Frontend/Interaction"
  }
]
```

#### Multiple Entities → Split by Entity

**Input:**
```markdown
#### US-020: Order System
**Acceptance Criteria:**
- Products can be added to orders
- Customers are linked to orders
- Order totals are calculated
- Orders can be submitted
```

**Output:**
```json
[
  {"id": "US-020a", "title": "Product Entity and Repository", "priority": 1},
  {"id": "US-020b", "title": "Customer Entity and Repository", "priority": 2},
  {"id": "US-020c", "title": "Order Entity with Relationships", "priority": 3},
  {"id": "US-020d", "title": "Order Total Calculation Service", "priority": 11},
  {"id": "US-020e", "title": "Order Submission Endpoint", "priority": 21}
]
```

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

All split stories must maintain traceability to the original:

```json
{
  "id": "US-010a",
  "title": "Create User (Backend)",
  "notes": "Split from US-010: User Management",
  "originalStoryId": "US-010"
}
```

### User Confirmation

After breakdown analysis, report:
```
BMAD Story Breakdown Complete:
- 5 stories are right-sized ✓
- 3 stories were split:
  - US-010 "User Management" → 5 stories (US-010a through US-010e)
  - US-005 "Task Priority" → 4 stories (US-005a through US-005d)
  - US-020 "Order System" → 5 stories (US-020a through US-020e)

Total: 19 stories ready for Ralph execution.
Proceed with conversion? [Y/n]
```
