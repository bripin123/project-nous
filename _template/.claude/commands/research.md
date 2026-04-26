# /research — AI Research Automation

> Receives a topic, determines the research type, executes automatable steps directly,
> and guides the user to wait for manual steps (Deep Research via Gemini/Claude/ChatGPT app).
> Detailed workflow: Refer to `.claude/skills/research.md`

User's requested topic: $ARGUMENTS

## Execution Procedure

1. Read the `.claude/skills/research.md` skill file
2. Execute sequentially from Phase 0 to the Completion Report in the skill
3. Since the user's topic is passed as $ARGUMENTS, start from the type determination in Phase 0
