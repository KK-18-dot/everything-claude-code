#!/usr/bin/env python3
"""UserPromptSubmit hook: Route to appropriate agent based on user intent.

Perspective-aware version: detects perspective-specific triggers in addition
to standard Codex/Gemini routing.
"""

import json
import sys

# Triggers for Codex (design, debugging, deep reasoning)
CODEX_TRIGGERS = {
    "ja": [
        "\u8a2d\u8a08", "\u3069\u3046\u8a2d\u8a08", "\u30a2\u30fc\u30ad\u30c6\u30af\u30c1\u30e3",
        "\u306a\u305c\u52d5\u304b\u306a\u3044", "\u30a8\u30e9\u30fc", "\u30d0\u30b0", "\u30c7\u30d0\u30c3\u30b0",
        "\u3069\u3061\u3089\u304c\u3044\u3044", "\u6bd4\u8f03\u3057\u3066", "\u30c8\u30ec\u30fc\u30c9\u30aa\u30d5",
        "\u5b9f\u88c5\u65b9\u6cd5", "\u3069\u3046\u5b9f\u88c5",
        "\u30ea\u30d5\u30a1\u30af\u30bf\u30ea\u30f3\u30b0", "\u30ea\u30d5\u30a1\u30af\u30bf",
        "\u30ec\u30d3\u30e5\u30fc", "\u898b\u3066",
        "\u8003\u3048\u3066", "\u5206\u6790\u3057\u3066", "\u6df1\u304f",
    ],
    "en": [
        "design", "architecture", "architect",
        "debug", "error", "bug", "not working", "fails",
        "compare", "trade-off", "tradeoff", "which is better",
        "how to implement", "implementation",
        "refactor", "simplify",
        "review", "check this",
        "think", "analyze", "deeply",
    ],
}

# Triggers for Gemini (research, multimodal, large context)
GEMINI_TRIGGERS = {
    "ja": [
        "\u8abf\u3079\u3066", "\u30ea\u30b5\u30fc\u30c1", "\u8abf\u67fb",
        "PDF", "\u52d5\u753b", "\u97f3\u58f0", "\u753b\u50cf",
        "\u30b3\u30fc\u30c9\u30d9\u30fc\u30b9\u5168\u4f53", "\u30ea\u30dd\u30b8\u30c8\u30ea\u5168\u4f53",
        "\u6700\u65b0", "\u30c9\u30ad\u30e5\u30e1\u30f3\u30c8",
        "\u30e9\u30a4\u30d6\u30e9\u30ea", "\u30d1\u30c3\u30b1\u30fc\u30b8",
    ],
    "en": [
        "research", "investigate", "look up", "find out",
        "pdf", "video", "audio", "image",
        "entire codebase", "whole repository",
        "latest", "documentation", "docs",
        "library", "package", "framework",
    ],
}

# Perspective-specific triggers
PERSPECTIVE_TRIGGERS = {
    "ja": [
        "\u30ad\u30e3\u30b9\u30c8", "\u8996\u5ea7", "\u30d1\u30fc\u30b9\u30da\u30af\u30c6\u30a3\u30d6",
        "\u8b70\u8ad6", "\u30c7\u30a3\u30d9\u30fc\u30c8",
        "\u691c\u8a3c", "\u30d9\u30ea\u30d5\u30a1\u30a4",
        "\u30b8\u30e7\u30fc\u30ab\u30fc", "\u7dca\u6025",
    ],
    "en": [
        "cast", "perspective", "wave a", "wave b",
        "debate", "bifurcation",
        "verify", "verification",
        "joker", "emergency",
    ],
}


def detect_agent(prompt: str) -> tuple[str | None, str]:
    """Detect which agent should handle this prompt."""
    prompt_lower = prompt.lower()

    # Check perspective triggers first
    for triggers in PERSPECTIVE_TRIGGERS.values():
        for trigger in triggers:
            if trigger in prompt_lower:
                return "perspective", trigger

    # Check Codex triggers
    for triggers in CODEX_TRIGGERS.values():
        for trigger in triggers:
            if trigger in prompt_lower:
                return "codex", trigger

    # Check Gemini triggers
    for triggers in GEMINI_TRIGGERS.values():
        for trigger in triggers:
            if trigger in prompt_lower:
                return "gemini", trigger

    return None, ""


def main():
    try:
        data = json.load(sys.stdin)
        prompt = data.get("prompt", "")

        if len(prompt) < 10:
            sys.exit(0)

        agent, trigger = detect_agent(prompt)

        if agent == "perspective":
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        f"[Perspective Routing] Detected '{trigger}' - "
                        "this task uses perspective-differentiated architecture. "
                        "Use /kickoff for new tasks, /cast for assignment, "
                        "/debate for bifurcation, /verify-multi for verification."
                    )
                }
            }
            print(json.dumps(output))

        elif agent == "codex":
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        f"[Agent Routing] Detected '{trigger}' - this task may benefit from "
                        "Codex CLI's deep reasoning capabilities."
                    )
                }
            }
            print(json.dumps(output))

        elif agent == "gemini":
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        f"[Agent Routing] Detected '{trigger}' - this task may benefit from "
                        "Gemini CLI's research capabilities."
                    )
                }
            }
            print(json.dumps(output))

        sys.exit(0)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
