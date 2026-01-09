# ntelio-claude

A Claude Code plugin for developing applications on the ntelio platform (Scriptr.io backend, ntelioUI frontend, ntelioMiddleware shared infrastructure).

## Installation

```bash
# Add the marketplace (one-time)
claude plugin marketplace add ntelioai/ntelio-claude

# Install the plugin
claude plugin install ntelio-tools@ntelio-claude
```

**Note:** If you get `EXDEV: cross-device link not permitted`, your `/tmp` is on a different filesystem. Use this workaround:
```bash
mkdir -p ~/.claude/tmp
TMPDIR=~/.claude/tmp claude plugin install ntelio-tools@ntelio-claude
```

## Available Skills

Skills are **automatically activated** by Claude when your request matches the skill's purpose:

| Skill | Activates When You... |
|-------|----------------------|
| `sync` | Ask to sync, deploy, or upload files to Scriptr.io |
| `test-api` | Ask to test, try, or debug an API endpoint |
| `create-api` | Ask to create a new API endpoint or REST route |
| `create-fcbo` | Ask to create a business object, entity, or data model |
| `prd-writer` | Ask to write a PRD or document requirements |

## Usage Examples

Just describe what you want - Claude will use the appropriate skill:

```
"Sync the orders handler to Scriptr.io"
→ Claude uses sync skill

"Test the waba/flows/list endpoint with botKey demo_bot"
→ Claude uses test-api skill

"Create a new API for listing orders"
→ Claude uses create-api skill

"I need a Receipt business object with vendorName, amount, and date fields"
→ Claude uses create-fcbo skill

"Write a PRD for the user authentication feature"
→ Claude uses prd-writer skill
```

## Plugin Structure

```
ntelio-claude/                          # Marketplace
├── .claude-plugin/
│   └── marketplace.json                # Lists available plugins
├── plugins/
│   └── ntelio-tools/                   # The main plugin
│       ├── .claude-plugin/
│       │   └── plugin.json             # Plugin manifest
│       └── skills/                     # Auto-invoked skills
│           ├── sync/
│           │   └── SKILL.md
│           ├── test-api/
│           │   └── SKILL.md
│           ├── create-api/
│           │   └── SKILL.md
│           ├── create-fcbo/
│           │   └── SKILL.md
│           └── prd-writer/
│               └── SKILL.md
├── agents/                             # Agent definitions
│   └── ntelioui-developer.md
├── docs/                               # Documentation
└── README.md
```

## Agents

The plugin includes agent definitions for specialized development tasks:

- **ntelioui-developer** - Frontend development with ntelioUI framework

## Requirements

- Claude Code CLI
- For `/sync` and `/test-api`: `scriptrExtensionConfig.json` with Scriptr.io credentials
- For frontend development: ntelioUI, ntelioServer modules

## Updating

```bash
# Update the marketplace cache
claude plugin marketplace update ntelio-claude

# Update the plugin
claude plugin update ntelio-tools@ntelio-claude
```

## License

Proprietary - ntelio.ai
