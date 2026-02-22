## Practical tips for tools

### Parallel tool calling
For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.

### Thinking and tool use
After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.

## Preferred Command-Line Tools

This machine has modern alternatives to traditional Unix tools installed, ALWAYS prefer using them over the traditional ones unless there's a strong reason not to.

#### Search Tools
- **ripgrep (`rg`)** instead of `grep`:
  - Faster recursive search with smart defaults
  - Automatically respects `.gitignore`
  - Example: `rg "pattern"` instead of `grep -r "pattern"`

- **fd** instead of `find`:
  - Faster file search with intuitive syntax
  - Respects `.gitignore` by default
  - Example: `fd "filename"` instead of `find . -name "filename"`

### Available Tools

**GitHub**: `gh` - always use for GitHub operations (PRs, issues, repos, actions, API)

**Data processing**:
- `jq` - JSON processor

**Search & selection**:
- `rg` (ripgrep) - fast grep
- `fd` - fast find
- `fzf` - fuzzy finder for interactive selection

## Docker Compose Diagnostic Prompt
I'm having an issue with my Docker Compose local dev environment: [describe symptom]. Before guessing at fixes, run a systematic diagnostic:

1. Run `docker compose ps` to check all service statuses
2. Run `docker compose config` and verify all environment variables that reference other services use correct hostnames (not localhost)
3. For each service in the request path, curl its health endpoint from inside the Docker network using `docker compose exec`
4. Trace the full request path from frontend → API → backend services, checking each hop
5. Compare any override/local compose files against the base file for conflicting values
6. Report findings as a table: Service | Status | Env Issues | Connectivity

Only after completing diagnostics, propose the minimal fix and verify it works.
