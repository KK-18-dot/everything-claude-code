"""Knowledge Oracle MCP Server (PLAN Section 1-8).

Wraps notebooklm-py to provide programmatic access to NotebookLM notebooks.
Each Perspective agent can query its dedicated notebook via MCP tools.

Access priority (PLAN Section 4):
  1. LOCAL capsule (0ms, always available)
  2. NotebookLM Oracle (2-5s, deep knowledge)
  3. Gemini Web Search (5-15s, fallback)
"""

from __future__ import annotations

import asyncio
import json
from pathlib import Path

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
NOTEBOOK_IDS_PATH = PROJECT_ROOT / "knowledge" / "oracles" / "notebook-ids.json"
CONFIG_PATH = PROJECT_ROOT / "knowledge" / "oracles" / "config.yaml"
CAPSULES_ROOT = PROJECT_ROOT / "knowledge" / "capsules"

PERSPECTIVES = [
    "architect",
    "guardian",
    "builder",
    "scout",
    "critic",
    "operator",
]


def _load_notebook_ids() -> dict[str, str | None]:
    if not NOTEBOOK_IDS_PATH.exists():
        return {}
    return json.loads(NOTEBOOK_IDS_PATH.read_text())


def _read_local_capsule(perspective: str) -> str:
    capsule_dir = CAPSULES_ROOT / perspective
    if not capsule_dir.exists():
        return ""
    parts: list[str] = []
    for md_file in sorted(capsule_dir.glob("*.md")):
        parts.append(f"## {md_file.stem}\n\n{md_file.read_text().strip()}")
    return "\n\n---\n\n".join(parts)


async def _ask_notebooklm(notebook_id: str, question: str) -> str:
    """Query a NotebookLM notebook via notebooklm-py."""
    try:
        from notebooklm import NotebookLMClient

        async with await NotebookLMClient.from_storage() as client:
            result = await client.chat.ask(notebook_id, question)
            return result.answer if hasattr(result, "answer") else str(result)
    except Exception as e:
        return f"NotebookLM query failed: {e}"


app = Server("knowledge-oracle")


@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="ask_perspective",
            description=(
                "Query a Perspective's knowledge. Checks local capsule first, "
                "then queries NotebookLM for deeper knowledge. "
                "Perspectives: architect, guardian, builder, scout, critic, operator"
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "perspective": {
                        "type": "string",
                        "enum": PERSPECTIVES,
                        "description": "Which perspective to query",
                    },
                    "question": {
                        "type": "string",
                        "description": "The question to ask",
                    },
                    "source": {
                        "type": "string",
                        "enum": ["auto", "local", "notebooklm"],
                        "default": "auto",
                        "description": (
                            "Knowledge source: auto (local first, then NotebookLM), "
                            "local (capsule only), notebooklm (remote only)"
                        ),
                    },
                },
                "required": ["perspective", "question"],
            },
        ),
        Tool(
            name="list_perspectives",
            description="List all available perspectives and their notebook status",
            inputSchema={
                "type": "object",
                "properties": {},
            },
        ),
        Tool(
            name="read_capsule",
            description="Read the full local knowledge capsule for a perspective",
            inputSchema={
                "type": "object",
                "properties": {
                    "perspective": {
                        "type": "string",
                        "enum": PERSPECTIVES,
                        "description": "Which perspective's capsule to read",
                    },
                },
                "required": ["perspective"],
            },
        ),
    ]


@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "ask_perspective":
        return await _handle_ask_perspective(arguments)
    elif name == "list_perspectives":
        return await _handle_list_perspectives()
    elif name == "read_capsule":
        return await _handle_read_capsule(arguments)
    else:
        return [TextContent(type="text", text=f"Unknown tool: {name}")]


async def _handle_ask_perspective(args: dict) -> list[TextContent]:
    perspective = args["perspective"]
    question = args["question"]
    source = args.get("source", "auto")

    if perspective not in PERSPECTIVES:
        return [TextContent(type="text", text=f"Unknown perspective: {perspective}")]

    results: list[str] = []

    # Step 1: Local capsule (always fast)
    if source in ("auto", "local"):
        local = _read_local_capsule(perspective)
        if local:
            results.append(f"[LOCAL CAPSULE]\n{local}")

    # Step 2: NotebookLM (deeper knowledge)
    if source in ("auto", "notebooklm"):
        ids = _load_notebook_ids()
        notebook_id = ids.get(perspective)
        if notebook_id:
            nlm_result = await _ask_notebooklm(notebook_id, question)
            results.append(f"[NOTEBOOKLM]\n{nlm_result}")
        elif source == "notebooklm":
            results.append(f"[NOTEBOOKLM] No notebook ID configured for {perspective}")

    if not results:
        return [TextContent(type="text", text=f"No knowledge available for {perspective}")]

    return [TextContent(type="text", text="\n\n---\n\n".join(results))]


async def _handle_list_perspectives() -> list[TextContent]:
    ids = _load_notebook_ids()
    lines: list[str] = []
    for p in PERSPECTIVES:
        nb_id = ids.get(p)
        capsule_dir = CAPSULES_ROOT / p
        capsule_files = len(list(capsule_dir.glob("*.md"))) if capsule_dir.exists() else 0
        nb_status = f"connected ({nb_id[:8]}...)" if nb_id else "not configured"
        lines.append(f"  {p}: capsule={capsule_files} files, notebook={nb_status}")

    studio_core = ids.get("studio_core")
    sc_status = f"connected ({studio_core[:8]}...)" if studio_core else "not configured"
    lines.append(f"  studio_core: notebook={sc_status}")

    return [TextContent(type="text", text="Perspectives:\n" + "\n".join(lines))]


async def _handle_read_capsule(args: dict) -> list[TextContent]:
    perspective = args["perspective"]
    if perspective not in PERSPECTIVES:
        return [TextContent(type="text", text=f"Unknown perspective: {perspective}")]

    content = _read_local_capsule(perspective)
    if not content:
        return [TextContent(type="text", text=f"No local capsule for {perspective}")]

    return [TextContent(type="text", text=content)]


async def main() -> None:
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())
