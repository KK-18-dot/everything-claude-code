"""Execution Infrastructure MCP Server (PLAN Section 2-1, 2-2, 2-3, 2-4).

Provides:
- Artifact Store: CRUD for PerspectiveOutput artifacts
- Task Board: SQLite-backed task management with budget tracking
- Agent Communication: Structured event logging + queries
- Budget Governor: time/token/retry budget with 80% warning / 100% stop
"""

from __future__ import annotations

import asyncio
import json
from pathlib import Path

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
DB_PATH = PROJECT_ROOT / ".dev-env" / "dev-env.db"

# Lazy imports to avoid circular deps at module level
_store = None
_board = None


def _get_store():
    global _store
    if _store is None:
        import sys

        sys.path.insert(0, str(PROJECT_ROOT / "src"))
        from dev_env.db.store import EventStore

        _store = EventStore(DB_PATH)
    return _store


def _get_board():
    global _board
    if _board is None:
        import sys

        sys.path.insert(0, str(PROJECT_ROOT / "src"))
        from dev_env.db.store import TaskBoard

        _board = TaskBoard(DB_PATH)
    return _board


PERSPECTIVES = [
    "CONDUCTOR",
    "ARCHITECT",
    "GUARDIAN",
    "BUILDER",
    "SCOUT",
    "CRITIC",
    "OPERATOR",
    "HUMAN",
    "SYSTEM",
]

app = Server("execution")


@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        # === Task Board (2-2) ===
        Tool(
            name="create_task",
            description="Create a new task on the board",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string"},
                    "description": {"type": "string", "default": ""},
                    "priority": {
                        "type": "string",
                        "enum": ["critical", "high", "medium", "low"],
                        "default": "medium",
                    },
                    "assigned_to": {
                        "type": "string",
                        "enum": PERSPECTIVES,
                        "description": "Perspective to assign",
                    },
                    "budget_tokens": {"type": "integer", "default": 0},
                    "budget_time_min": {"type": "integer", "default": 0},
                },
                "required": ["title"],
            },
        ),
        Tool(
            name="update_task",
            description="Update task status",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_id": {"type": "string"},
                    "status": {
                        "type": "string",
                        "enum": [
                            "pending",
                            "in_progress",
                            "review",
                            "completed",
                            "failed",
                            "cancelled",
                        ],
                    },
                },
                "required": ["task_id", "status"],
            },
        ),
        Tool(
            name="list_tasks",
            description="List tasks, optionally filtered by status",
            inputSchema={
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": [
                            "pending",
                            "in_progress",
                            "review",
                            "completed",
                            "failed",
                        ],
                    },
                },
            },
        ),
        # === Event Log / Agent Communication (2-3) ===
        Tool(
            name="log_event",
            description="Log an agent event to the durable event store",
            inputSchema={
                "type": "object",
                "properties": {
                    "perspective": {"type": "string", "enum": PERSPECTIVES},
                    "event_type": {
                        "type": "string",
                        "enum": [
                            "task_created",
                            "task_started",
                            "task_completed",
                            "task_failed",
                            "debate_started",
                            "debate_concluded",
                            "verification_passed",
                            "verification_failed",
                            "artifact_created",
                            "artifact_updated",
                            "budget_warning",
                            "budget_exhausted",
                            "fallback_triggered",
                            "joker_invoked",
                            "closer_invoked",
                            "merge_approved",
                            "merge_rejected",
                            "knowledge_distilled",
                            "formation_changed",
                        ],
                    },
                    "task_id": {"type": "string"},
                    "payload": {"type": "object", "default": {}},
                    "tokens_used": {"type": "integer", "default": 0},
                    "model": {"type": "string"},
                },
                "required": ["perspective", "event_type"],
            },
        ),
        Tool(
            name="query_events",
            description="Query recent events from the event store",
            inputSchema={
                "type": "object",
                "properties": {
                    "perspective": {"type": "string", "enum": PERSPECTIVES},
                    "event_type": {"type": "string"},
                    "task_id": {"type": "string"},
                    "limit": {"type": "integer", "default": 20},
                },
            },
        ),
        # === Artifact Store (2-1) ===
        Tool(
            name="store_artifact",
            description="Store a PerspectiveOutput artifact as JSON file",
            inputSchema={
                "type": "object",
                "properties": {
                    "perspective": {"type": "string", "enum": PERSPECTIVES},
                    "task_id": {"type": "string"},
                    "artifact": {
                        "type": "object",
                        "description": "PerspectiveOutput JSON: {summary, risks, actions, confidence, artifact_path}",
                    },
                },
                "required": ["perspective", "task_id", "artifact"],
            },
        ),
        Tool(
            name="get_artifact",
            description="Retrieve a stored artifact",
            inputSchema={
                "type": "object",
                "properties": {
                    "perspective": {"type": "string", "enum": PERSPECTIVES},
                    "task_id": {"type": "string"},
                },
                "required": ["perspective", "task_id"],
            },
        ),
        # === Budget Governor (2-4) ===
        Tool(
            name="check_budget",
            description="Check budget status for a task. Returns remaining tokens/time and warning level.",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_id": {"type": "string"},
                },
                "required": ["task_id"],
            },
        ),
    ]


@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    handlers = {
        "create_task": _handle_create_task,
        "update_task": _handle_update_task,
        "list_tasks": _handle_list_tasks,
        "log_event": _handle_log_event,
        "query_events": _handle_query_events,
        "store_artifact": _handle_store_artifact,
        "get_artifact": _handle_get_artifact,
        "check_budget": _handle_check_budget,
    }
    handler = handlers.get(name)
    if handler is None:
        return [TextContent(type="text", text=f"Unknown tool: {name}")]
    return await handler(arguments)


# --- Task Board handlers ---


async def _handle_create_task(args: dict) -> list[TextContent]:
    board = _get_board()
    task_id = board.create(
        title=args["title"],
        description=args.get("description", ""),
        priority=args.get("priority", "medium"),
        assigned_to=args.get("assigned_to"),
        budget_tokens=args.get("budget_tokens", 0),
        budget_time_min=args.get("budget_time_min", 0),
    )
    return [TextContent(type="text", text=json.dumps({"task_id": task_id, "status": "created"}))]


async def _handle_update_task(args: dict) -> list[TextContent]:
    board = _get_board()
    board.update_status(args["task_id"], args["status"])
    return [TextContent(type="text", text=json.dumps({"task_id": args["task_id"], "status": args["status"]}))]


async def _handle_list_tasks(args: dict) -> list[TextContent]:
    board = _get_board()
    tasks = board.list_by_status(args.get("status"))
    summary = [
        {"id": t["id"], "title": t["title"], "status": t["status"], "assigned_to": t["assigned_to"]}
        for t in tasks
    ]
    return [TextContent(type="text", text=json.dumps(summary, ensure_ascii=False))]


# --- Event Log handlers ---


async def _handle_log_event(args: dict) -> list[TextContent]:
    store = _get_store()
    event_id = store.log(
        perspective=args["perspective"],
        event_type=args["event_type"],
        task_id=args.get("task_id"),
        payload=args.get("payload"),
        tokens_used=args.get("tokens_used", 0),
        model=args.get("model"),
    )
    return [TextContent(type="text", text=json.dumps({"event_id": event_id}))]


async def _handle_query_events(args: dict) -> list[TextContent]:
    store = _get_store()
    events = store.query(
        perspective=args.get("perspective"),
        event_type=args.get("event_type"),
        task_id=args.get("task_id"),
        limit=args.get("limit", 20),
    )
    return [TextContent(type="text", text=json.dumps(events, ensure_ascii=False, default=str))]


# --- Artifact Store handlers ---

ARTIFACT_DIR = PROJECT_ROOT / ".dev-env" / "artifacts"


async def _handle_store_artifact(args: dict) -> list[TextContent]:
    perspective = args["perspective"]
    task_id = args["task_id"]
    artifact = args["artifact"]

    artifact_dir = ARTIFACT_DIR / task_id
    artifact_dir.mkdir(parents=True, exist_ok=True)
    path = artifact_dir / f"{perspective.lower()}.json"
    path.write_text(json.dumps(artifact, ensure_ascii=False, indent=2))

    store = _get_store()
    store.log(
        perspective=perspective,
        event_type="artifact_created",
        task_id=task_id,
        payload={"path": str(path)},
    )

    return [TextContent(type="text", text=json.dumps({"stored": str(path)}))]


async def _handle_get_artifact(args: dict) -> list[TextContent]:
    perspective = args["perspective"]
    task_id = args["task_id"]
    path = ARTIFACT_DIR / task_id / f"{perspective.lower()}.json"

    if not path.exists():
        return [TextContent(type="text", text=json.dumps({"error": "artifact not found"}))]

    content = json.loads(path.read_text())
    return [TextContent(type="text", text=json.dumps(content, ensure_ascii=False))]


# --- Budget Governor handler ---


async def _handle_check_budget(args: dict) -> list[TextContent]:
    board = _get_board()
    task = board.get(args["task_id"])

    if task is None:
        return [TextContent(type="text", text=json.dumps({"error": "task not found"}))]

    budget_tokens = task["budget_tokens"] or 0
    spent_tokens = task["spent_tokens"] or 0
    budget_time = task["budget_time_min"] or 0
    spent_time = task["spent_time_min"] or 0

    token_pct = (spent_tokens / budget_tokens * 100) if budget_tokens > 0 else 0
    time_pct = (spent_time / budget_time * 100) if budget_time > 0 else 0
    max_pct = max(token_pct, time_pct)

    if max_pct >= 100:
        level = "EXHAUSTED"
    elif max_pct >= 80:
        level = "WARNING"
    else:
        level = "OK"

    result = {
        "task_id": task["id"],
        "level": level,
        "tokens": {"budget": budget_tokens, "spent": spent_tokens, "pct": round(token_pct, 1)},
        "time_min": {"budget": budget_time, "spent": spent_time, "pct": round(time_pct, 1)},
    }

    if level in ("WARNING", "EXHAUSTED"):
        store = _get_store()
        store.log(
            perspective="SYSTEM",
            event_type="budget_warning" if level == "WARNING" else "budget_exhausted",
            task_id=task["id"],
            payload=result,
        )

    return [TextContent(type="text", text=json.dumps(result))]


async def main() -> None:
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())
