---
name: local-knowledge
description: Query local knowledge capsules via gemma4:e2b (offline, secrets-safe). Use to deepen understanding of a perspective domain without sending data to external APIs. Replaces NotebookLM dependency.
user-invocable: true
---

# /ask-local

Query the local gemma4:e2b model with context from a perspective capsule.
All processing is local — safe for sensitive code and proprietary information.

## Usage

```
/ask-local "<question>" --perspective <guardian|critic|architect|builder|operator>
```

Examples:
```
/ask-local "OWASPのセッション管理のベストプラクティスは？" --perspective guardian
/ask-local "循環的複雑度を下げるリファクタリング手法は？" --perspective critic
/ask-local "マイクロサービスとモノリスのトレードオフ" --perspective architect
/ask-local "React コンポーネントのテストパターン" --perspective builder
```

## Workflow

### Step 1: Load capsule context

Capsule paths:
- `guardian` → `/home/kk-18-dot/Projects/dev-env-built/knowledge/capsules/guardian/_index.md`
- `critic`   → `/home/kk-18-dot/Projects/dev-env-built/knowledge/capsules/critic/_index.md`
- `architect`→ `/home/kk-18-dot/Projects/dev-env-built/knowledge/capsules/architect/_index.md`
- `builder`  → `/home/kk-18-dot/Projects/dev-env-built/knowledge/capsules/builder/_index.md`
- `operator` → `/home/kk-18-dot/Projects/dev-env-built/knowledge/capsules/operator/_index.md`

Read the capsule file to extract the Role Frame and Knowledge Domain.

### Step 2: Build prompt

```
System: You are the <PERSPECTIVE_NAME> perspective. You think and respond within your role frame:
<capsule Role Frame section>

Knowledge domain you draw from:
<capsule Knowledge Domain section>

Answer the following question from your perspective. Be specific and actionable.
```

### Step 3: Call gemma4:e2b via ollama MCP

Use `mcp__ollama__ollama_generate` with:
- model: `gemma4:e2b`
- prompt: the constructed prompt + user question
- Keep capsule context under 2000 tokens (gemma4:e2b has 8K active token limit with MoE)

### Step 4: Return answer

Display the response with perspective attribution:

```
## /ask-local — <PERSPECTIVE> perspective

<gemma4:e2b response>

---
Source: knowledge/capsules/<perspective>/_index.md (local, offline)
```

## Notes

- gemma4:e2b context limit: ~8K active tokens (MoE architecture). Send one capsule at a time.
- If ollama is not running: `systemctl --user start ollama`
- For multi-perspective query: run `/ask-local` multiple times with different `--perspective` flags
- This is L2 knowledge (5-10s). For L3 web search, use `mcp__ollama__ollama_web_search` or `gemini` CLI.

## Knowledge Layer Reference

| Layer | Method | Latency | Use when |
|-------|--------|---------|----------|
| L1 | Capsule injection (agent Perspective Frame) | 0ms | Always active |
| L2 | `/ask-local` + gemma4:e2b | 5-10s | Deep domain question, offline needed |
| L3 | `ollama_web_search` / `gemini` CLI | 10-30s | External research, up-to-date info |
