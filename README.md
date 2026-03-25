# Reword and Grammar Check

A macOS right-click service that rewrites selected text using an LLM while keeping the original tone. Works in any application.

## How it works

1. Select text in any app
2. Right-click → **Services** → **Reword and Grammar Check**
3. A notification appears while the text is processed
4. The reworded text is copied to your clipboard — press **Cmd+V** to paste

## Backends

| Backend | Description | Requirements |
|---------|-------------|--------------|
| `claude-code` | Uses [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI in headless mode | Claude Code installed and authenticated |
| `bedrock` | Calls Amazon Bedrock directly via AWS CLI | AWS CLI configured with Bedrock access |

## Installation

```bash
git clone https://github.com/dgallitelli/macos-reword-service.git
cd macos-reword-service
./install.sh
```

Then create the Automator Quick Action (the install script prints the steps).

### Automator Quick Action setup

1. Open **Automator** → **New Document** → **Quick Action** → **Choose**
2. Set **"Workflow receives current"** → `text`, **"in"** → `any application`
3. Drag **Run Shell Script** into the workflow
4. Set **Shell** to `/bin/bash` and **Pass input** to `to stdin`
5. Paste this as the script:
   ```bash
   export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"
   /bin/bash "$HOME/.config/reword/reword.sh"
   ```
6. **File → Save** as `Reword and Grammar Check`

> **Tip:** You can assign a keyboard shortcut in **System Settings → Keyboard → Keyboard Shortcuts → Services**.

## Configuration

Edit `~/.config/reword/config.sh`:

```bash
# Backend: "claude-code" or "bedrock"
REWORD_BACKEND="claude-code"

# Claude Code CLI path
CLAUDE_CLI="$HOME/.local/bin/claude"

# System prompt (customize the rewriting behavior)
REWORD_PROMPT="Reword and grammar-check the following text. Keep the same tone, intent, and meaning. Only return the improved text — no explanations, no quotes, no preamble."

# Bedrock settings (when using bedrock backend)
BEDROCK_MODEL_ID="us.anthropic.claude-haiku-4-5-20251001-v1:0"
BEDROCK_REGION="us-east-1"
```

### Using with Bedrock as Claude Code's provider

If your Claude Code uses Bedrock, add these env vars to the config:

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export ANTHROPIC_MODEL='global.anthropic.claude-haiku-4-5-20251001-v1:0'
```

## Troubleshooting

Logs are at `~/.config/reword/reword.log`.

| Issue | Fix |
|-------|-----|
| Service not in right-click menu | System Settings → Keyboard → Keyboard Shortcuts → Services → enable it |
| Script doesn't run | Check the Automator workflow was saved as a Quick Action, not a regular workflow |
| Auth errors with Claude Code | Run `claude` in terminal first to complete login |
| Non-ASCII characters mangled | The script handles UTF-8 and Mac Roman encoding automatically |

## License

MIT
