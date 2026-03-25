#!/bin/bash
# Reword and Grammar Check - Configuration

# Backend: "claude-code" or "bedrock"
REWORD_BACKEND="claude-code"

# Claude Code CLI path (update if yours is elsewhere)
CLAUDE_CLI="$HOME/.local/bin/claude"

# Claude Code env vars (Automator doesn't inherit your shell env)
# Uncomment and set these if you use Bedrock as Claude Code's provider:
# export CLAUDE_CODE_USE_BEDROCK=1
# export ANTHROPIC_MODEL='global.anthropic.claude-haiku-4-5-20251001-v1:0'

# System prompt sent to the LLM
REWORD_PROMPT="Reword and grammar-check the following text. Keep the same tone, intent, and meaning. Only return the improved text — no explanations, no quotes, no preamble."

# Bedrock settings (used when REWORD_BACKEND="bedrock")
BEDROCK_MODEL_ID="us.anthropic.claude-haiku-4-5-20251001-v1:0"
BEDROCK_REGION="us-east-1"
