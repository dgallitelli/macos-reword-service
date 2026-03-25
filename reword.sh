#!/bin/bash
# Reword and Grammar Check - Main script
# Reads selected text from stdin (passed by Automator),
# sends to LLM, copies result to clipboard and notifies user.

set -euo pipefail
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

CONFIG_FILE="$HOME/.config/reword/config.sh"
source "$CONFIG_FILE"
LOG_FILE="$HOME/.config/reword/reword.log"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"

log() { echo "$(date '+%H:%M:%S') $1" >> "$LOG_FILE"; }

notify() {
    osascript -e "display notification \"$1\" with title \"Reword & Grammar Check\"" 2>/dev/null
}

log "=== Started ==="

# Read selected text from stdin, normalize encoding to UTF-8
TMPINPUT=$(mktemp /tmp/reword-input.XXXXXX)
cat > "$TMPINPUT"
# Try to convert from UTF-8, fall back to Mac Roman if it fails
if ! iconv -f UTF-8 -t UTF-8 "$TMPINPUT" >/dev/null 2>&1; then
    iconv -f MAC -t UTF-8 "$TMPINPUT" > "$TMPINPUT.utf8" && mv "$TMPINPUT.utf8" "$TMPINPUT"
fi
INPUT=$(cat "$TMPINPUT")
rm -f "$TMPINPUT"

log "Input: ${INPUT:0:80}..."

if [ -z "$INPUT" ]; then
    log "Empty input, aborting"
    notify "No text selected."
    exit 0
fi

notify "Rewriting..."

# Write prompt + input to a temp file to avoid shell escaping issues
TMPPROMPT=$(mktemp /tmp/reword-prompt.XXXXXX)
cat > "$TMPPROMPT" <<PROMPT_EOF
$REWORD_PROMPT

$INPUT
PROMPT_EOF

case "$REWORD_BACKEND" in
    claude-code)
        RESULT=$("$CLAUDE_CLI" -p "$(cat "$TMPPROMPT")" 2>>"$LOG_FILE") || true
        ;;
    bedrock)
        TMPFILE=$(mktemp /tmp/reword-payload.XXXXXX)
        python3 -c "
import json, sys
text = open(sys.argv[1]).read()
payload = {
    'anthropic_version': 'bedrock-2023-05-31',
    'max_tokens': 4096,
    'messages': [
        {'role': 'user', 'content': text}
    ]
}
json.dump(payload, open(sys.argv[2], 'w'), ensure_ascii=False)
" "$TMPPROMPT" "$TMPFILE"

        RESPONSE=$(aws bedrock-runtime invoke-model \
            --model-id "$BEDROCK_MODEL_ID" \
            --region "$BEDROCK_REGION" \
            --content-type "application/json" \
            --body "file://$TMPFILE" \
            /dev/stdout 2>>"$LOG_FILE") || true
        rm -f "$TMPFILE"

        RESULT=$(echo "$RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin)['content'][0]['text'])") || true
        ;;
    *)
        notify "Unknown backend: $REWORD_BACKEND"
        rm -f "$TMPPROMPT"
        exit 1
        ;;
esac

rm -f "$TMPPROMPT"
log "Result: ${RESULT:0:80}..."

if [ -z "$RESULT" ]; then
    notify "Failed — check ~/.config/reword/reword.log"
    exit 1
fi

# Copy result to clipboard so user can paste it
echo -n "$RESULT" | pbcopy
notify "Done! Reworded text copied to clipboard. Press Cmd+V to paste."
log "=== Done ==="
