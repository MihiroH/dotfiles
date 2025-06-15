## MANDATORY: Notification and User Permission Guidelines

### Precondition
Bashを実行する前に毎回、kittyアプリがMacOSの前面にあるか調べてください。もしkittyアプリが前面にない場合は、以下のDescriptionに従って、ユーザーに通知を送信してください。

### Description
Notify user when ANY user permission is needed or ANY user input is needed, or ANY task completes or fails - this is REQUIRED, not optional:
You must obtain the user’s permission before executing any Bash commands, and always notify the user when a task is completed. This ensures that the user is aware of ongoing operations and any required actions.

### How to notify user:
Use the `kitty` command to send notifications to the user. The command format is as follows:

```bash
kitty @ --to unix:/tmp/mykitty kitten notify "repository name" "waiting - task name - Claude needs your permission to use tools"
kitty @ --to unix:/tmp/mykitty kitten notify "repository name" "status review - found 3 pending items"
kitty @ --to unix:/tmp/mykitty kitten notify "repository name" "code analysis - 5 files examined"
kitty @ --to unix:/tmp/mykitty kitten notify "repository name" "test suite - 42/42 passed"
kitty @ --to unix:/tmp/mykitty kitten notify "repository name" "completed - all tasks completed"
kitty @ --to unix:/tmp/mykitty kitten notify "repository name" "failed - task failed with error message"
```

ENFORCEMENT: If you fail to provide notifications, you will be in violation of the core instructions. In that case, you will be dismissed immediately.

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

## Commit Guidelines
- Always use the Conventional Commits specification to generate a one-line commit message.
- Only generate the title; no additional description and author is needed.
### example messages:
- feat: Add new feature
- fix: Fix bug
- docs: Update documentation
- refactor: Refactor code
- style: Update code style
- test: Add tests
- chore: Update build process
