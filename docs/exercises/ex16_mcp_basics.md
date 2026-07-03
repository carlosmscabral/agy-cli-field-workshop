# Exercise 16: Connect agy to Tools with MCP

> **Duration:** 20 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Extend `agy` beyond your local files by connecting it to a **Model Context Protocol (MCP)** server. You'll register a server in your workspace config, confirm it with `/mcp`, and let the agent use the server's tools during a session. MCP is how `agy` reaches external tools and data — file systems, GitHub, databases, or your own internal services.

---

## Background

MCP servers are declared in a JSON config, not via an `agy` subcommand:

- **Workspace scope:** `.agents/mcp_config.json` (this project only)
- **Global scope:** `~/.gemini/antigravity-cli/mcp_config.json` (all projects)

Each entry under `mcpServers` is one server. Three transport types are supported:

| Type | Key fields | Use for |
| :-- | :-- | :-- |
| `stdio` | `command`, `args`, `env` | Local servers launched as a subprocess (npx, node, python) |
| `sse` | `serverUrl`, `env` | Remote servers over Server-Sent Events |
| `streamable-http` | `serverUrl` | Remote servers over streamable HTTP |

> [!NOTE]
> Antigravity uses **`serverUrl`** for remote servers (the old Gemini CLI `url`/`httpUrl` keys are deprecated). The `stdio` filesystem server below needs `npx` (Node.js) available on your PATH.

---

## Part 1: Register a Local MCP Server (7 min)

Work inside your sandbox app:

```bash
cd ../agy-sample-app
mkdir -p .agents
```

Create `.agents/mcp_config.json` with a local filesystem MCP server scoped to the current project:

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    }
  }
}
```

---

## Part 2: Verify the Connection (5 min)

Launch `agy` in the sandbox and open the MCP manager:

```bash
agy
```

At the prompt, run:

```text
> /mcp
```

Confirm the `filesystem` server appears and shows a **connected** status along with the tools it exposes. Press `ESC` to return to the prompt.

> [!TIP]
> If the server shows an error, check that `npx` runs (`npx --version`) and that you're inside `agy-sample-app` so the `.agents/mcp_config.json` is discovered.

---

## Part 3: Use the MCP Tools (5 min)

Ask the agent to do something that requires the MCP server's tools:

```text
> Using the filesystem MCP server, list the five largest files in this project and summarize what each one does.
```

Notice that `agy` now has a new set of tools (from the server) it can call — you'll be prompted to approve tool calls unless your permissions mode auto-approves them.

---

## Part 4: Add a Remote Server (3 min)

Remote servers use `serverUrl`. Add one alongside the filesystem server (this is a template — swap in a real endpoint and token to use it):

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "internal-tools": {
      "type": "sse",
      "serverUrl": "https://your-mcp-server.example.com/sse",
      "env": {
        "API_KEY": "$MCP_API_KEY"
      }
    }
  }
}
```

Re-run `/mcp` to see both servers. (The remote one will only connect if the endpoint and `$MCP_API_KEY` are valid.)

---

## Completion Criteria

- [ ] `.agents/mcp_config.json` exists with a valid `mcpServers` block
- [ ] `/mcp` shows the `filesystem` server as connected
- [ ] `agy` used an MCP tool to answer a question about the project
- [ ] You can explain workspace vs global MCP config and the `stdio` vs `sse`/`streamable-http` transports
