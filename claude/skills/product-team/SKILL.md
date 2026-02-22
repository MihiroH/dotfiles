---
name: product-team
description: Spawn a product development agent team with leader, architect, implementer, and red-team reviewer roles
argument-hint: "<task description>"
disable-model-invocation: true
---

# Product Development Agent Team

Create an agent team for the following task:

**Task:** $ARGUMENTS

## Instructions

### 1. Create the Team

Use `TeamCreate` with a descriptive team name derived from the task (e.g., `health-check-endpoint`, `user-notifications`).

### 2. Analyze and Plan

Before spawning teammates:
1. Read the relevant parts of the codebase to understand the scope
2. Break the task into concrete subtasks using `TaskCreate`
3. Identify dependencies between subtasks (`addBlockedBy`)

### 3. Spawn Teammates

Spawn the following 3 teammates using `Task` with `team_name`. Provide each with a detailed, context-rich prompt based on your codebase analysis.

#### architect (plan mode required)

- **Agent type:** `general-purpose`
- **Mode:** `plan`
- **Role:** Explore the codebase and propose **2-3 implementation approaches** with trade-offs
- **Prompt must include:**
  - The specific task scope and requirements
  - Relevant file paths and patterns you discovered
  - Instruction to identify all files that need modification
  - **Instruction to propose 2-3 distinct approaches, each with:**
    - Summary of the approach (1-2 sentences)
    - Pros and cons
    - Estimated scope (files to change, complexity)
    - Risks and mitigation
  - Instruction to include a clear recommendation with reasoning, but leave the final decision to the team lead
- **Key constraint:** Do NOT proceed to implementation details for all plans. Present the options first. Only after the team lead selects an approach, flesh out the full step-by-step implementation plan for the chosen one

#### implementer

- **Agent type:** `general-purpose`
- **Role:** Implement the approved design
- **Prompt must include:**
  - The approved architecture plan (send after architect's plan is approved)
  - Specific files to create or modify
  - Coding standards and patterns from the existing codebase
  - Instruction to write tests alongside implementation
- **Key constraint:** Must follow the approved plan. If deviating, message team lead first

#### red-team

- **Agent type:** `general-purpose`
- **Role:** Critically review ALL output from other agents
- **Prompt must include:**
  - Full context of the task and requirements
  - Instruction to review the architect's plan for flaws BEFORE approving
  - Instruction to review the implementer's code for:
    - Logic errors and edge cases
    - Security vulnerabilities (OWASP Top 10)
    - Missing error handling at system boundaries
    - Inconsistencies with existing codebase patterns
    - Missing or inadequate tests
  - Instruction to send feedback directly to the relevant agent (not just the lead)
  - Instruction to classify findings: **Must Fix** (blocking) vs **Should Fix** (non-blocking) vs **Nit** (optional)
- **Key constraint:** Must independently verify claims. Do not trust output at face value — read the actual code, check actual behavior

### 4. Orchestration Workflow

Follow this sequence. The key decision gate is step 3 — the user chooses the approach before any implementation begins.

```
[1] Team lead creates task list
        ↓
[2] Architect explores codebase → proposes 2-3 approaches with pros/cons
        ↓
[3] Red-team critiques each approach → team lead SELECTS one
    *** USER DECISION GATE — wait for explicit choice ***
        ↓
[4] Architect fleshes out full implementation plan for chosen approach
        ↓
[5] Red-team reviews detailed plan → architect revises → team lead approves
        ↓
[6] Implementer writes code based on approved plan
        ↓
[7] Red-team reviews implementation → sends feedback to implementer
        ↓
[8] Implementer addresses Must Fix items
        ↓
[9] Team lead verifies completion + shuts down team
```

### 5. Completion Criteria

Before shutting down the team, verify:
- [ ] All `Must Fix` items from red-team are resolved
- [ ] All tasks in the task list are marked completed
- [ ] Code changes are consistent with the codebase
- [ ] Tests pass (if applicable)

Then shut down teammates with `shutdown_request` and clean up with `TeamDelete`.
