# Ralph - Claude Code Configuration

This file contains project instructions and patterns for Claude Code when working with Ralph.

## Overview

Ralph is an autonomous AI agent loop that implements features from a PRD iteratively. Each iteration spawns a fresh subagent with clean context.

## Commands

```bash
# Convert PRD to prd.json (auto-detects format)
/prd-converter                     # Auto-detect PRD in current directory
/prd-converter path/to/prd.md      # Convert specific file
/prd-converter .speckit/           # Convert Spec Kit output

# Run Ralph to implement PRD stories
/ralph                    # Run with default 10 iterations
/ralph 20                 # Run with 20 max iterations
```

## Supported PRD Sources

- **BMAD Method**: Epics with FR-XX, US-XX identifiers
- **GitHub Spec Kit**: `.speckit/` directory with spec.md, plan.md, tasks.md
- **Plain Markdown**: PRD with `## User Stories` section

## .NET Quality Gates

All Ralph commits must pass these quality checks:

```bash
dotnet build              # Compilation succeeds
dotnet test               # All tests pass (including YOUR new tests!)
dotnet format --verify-no-changes  # Code formatting correct
```

If analyzers are configured, they run as part of build.

## State Files

| File | Purpose |
|------|---------|
| `prd.json` | User stories with completion status |
| `progress.txt` | Append-only learnings log |
| `CLAUDE.md` | This file - patterns and conventions |

## Browser Testing

For UI stories, use Playwright MCP:
- `mcp__playwright__browser_navigate` - Navigate to URLs
- `mcp__playwright__browser_click` - Click elements
- `mcp__playwright__browser_type` - Fill form fields
- `mcp__playwright__browser_take_screenshot` - Capture screenshots

## Microsoft Learn MCP

When encountering issues or unfamiliar APIs, use the Microsoft Learn MCP server:

```
# Search documentation
mcp__microsoft_docs_mcp__microsoft_docs_search
  query: "EF Core migrations add column"

# Fetch specific page
mcp__microsoft_docs_mcp__microsoft_docs_fetch
  url: "https://learn.microsoft.com/en-us/ef/core/..."
```

Use this for EF Core issues, ASP.NET Core patterns, Blazor questions, and .NET 8+ best practices.

---

## Architectural Patterns

**IMPORTANT:** Ralph follows the architectural patterns documented in your PRD source (BMAD Method or Spec Kit), NOT global patterns.

### How Patterns Are Discovered

1. **Read PRD documentation** for explicit architecture guidance:
   - Vertical Slice Architecture, Clean Architecture, etc.
   - Coding style (functional C#, OOP, etc.)
   - Technology decisions

2. **Check existing codebase** for implicit patterns:
   - How similar features are structured
   - Naming conventions in use
   - Common abstractions (Result types, repositories)

3. **Follow, don't invent** - New code should look like it belongs in the codebase

### Pattern Conformance Rules

1. If the PRD specifies an architecture, use it exactly
2. Match the style and structure of existing code
3. Don't introduce new patterns without PRD guidance
4. When uncertain, document questions in progress.txt

---

## Codebase Patterns

_This section is updated by Ralph as patterns are discovered during implementation._

_Add reusable patterns here during Ralph iterations. Only add patterns that are **general and reusable**, not story-specific details._

<!-- Examples of good patterns to add:
- Use repository pattern for all data access (e.g., IUserRepository)
- All API responses use ApiResponse<T> wrapper
- Run `dotnet ef migrations add` after modifying entities
- Tests use xUnit with Moq for mocking
- Error handling uses Result<T> pattern, not exceptions
- All endpoints return ActionResult<ApiResponse<T>>
-->

---

## Unit Testing Requirements

Every story implementation MUST include unit tests:

- **Happy path** - At least one success case
- **Edge case** - At least one failure/error case
- Validation failures if applicable

### Test Patterns

```csharp
public class CreateUserHandlerTests
{
    [Fact]
    public async Task Handle_ValidRequest_CreatesUser()
    {
        // Arrange
        var handler = new CreateUserHandler(mockRepo.Object);
        var command = new CreateUserCommand("test@example.com", "Test User");

        // Act
        var result = await handler.Handle(command);

        // Assert
        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task Handle_DuplicateEmail_ReturnsFailure()
    {
        // Arrange - setup duplicate scenario
        // Act
        // Assert - verify failure result
    }
}
```

`dotnet test` must pass with new tests before commit. **No tests = story not complete.**

---

## Project-Specific Notes

_Add project-specific conventions, dependencies, and important context here._

<!-- Examples:
- Database: PostgreSQL via EF Core
- Authentication: ASP.NET Core Identity
- Frontend: Blazor Server
- API: Minimal APIs with Carter
-->
