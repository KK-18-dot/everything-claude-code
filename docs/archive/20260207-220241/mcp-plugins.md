# MCP and Plugins (Solo)

Keep external integrations minimal and intentional.

## MCP Policy
- Prefer CLI tools and local scripts over MCP when possible.
- Use the smallest scope that works (project > user > local).
- Add MCP servers only when they provide ongoing value.

## Scoping Guidelines
- user: shared across all projects (avoid unless truly global).
- project: tied to a single repository (preferred).
- local: temporary experiments only.

## Evaluation Criteria
- Clear benefit over CLI or scripts.
- Low maintenance and low risk.
- Easy to remove without breaking workflows.

## Plugins
- Treat plugins as bundles: commands, skills, agents, MCP.
- Install only if you will use them weekly.
- Remove when unused or redundant.
