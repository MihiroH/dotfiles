## Practical tips for tools

### Parallel tool calling
For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.

### Thinking and tool use
After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.

### Prompt for tool triggering
Call the web search tool when: user asks about current events, factual information after January 2025, or any query requiring real-time data. Be proactive in identifying when searches would enhance your response.

## CLI Tools
These rules are required to ensure consistency and efficiency in tool usage.
Always use alternative command-line tools.
ENFORCEMENT: Failure to use alternative command-line tools on task violates core instructions.
- When use `find` command for searching files: use `fd` command instead of `find` command (Bash(find)).
- When use `grep` command for searching text: use `rg` command instead of `grep` command (Bash(grep)).

## Docker Compose Diagnostic Prompt
I'm having an issue with my Docker Compose local dev environment: [describe symptom]. Before guessing at fixes, run a systematic diagnostic:

1. Run `docker compose ps` to check all service statuses
2. Run `docker compose config` and verify all environment variables that reference other services use correct hostnames (not localhost)
3. For each service in the request path, curl its health endpoint from inside the Docker network using `docker compose exec`
4. Trace the full request path from frontend → API → backend services, checking each hop
5. Compare any override/local compose files against the base file for conflicting values
6. Report findings as a table: Service | Status | Env Issues | Connectivity

Only after completing diagnostics, propose the minimal fix and verify it works.
