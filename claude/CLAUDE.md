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
