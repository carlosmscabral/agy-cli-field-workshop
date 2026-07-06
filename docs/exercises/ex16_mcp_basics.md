# Exercise 16: Governed Access with MCP

> **Duration:** 20 min | **Module:** 1 — Antigravity CLI Fundamentals

---

## Objective

Give `agy` access to a system it **cannot** reach on its own terms — a database — through a **governed** channel. You'll connect an MCP server to a local billing database, then run `agy` in **strict permissions** (no shell, no file writes) and watch it still answer real business questions **only** through the MCP server's scoped query tool.

> [!NOTE]
> **Why MCP and not just `!curl` / shell?** `agy` can already read files, run shell commands, and hit URLs. Wrapping those in an MCP server adds nothing. MCP earns its place through **governance**: the server owns the connection/credentials and exposes only *scoped, structured* operations — so you can grant a capability **without handing the agent raw shell or secrets**, and even when shell is switched off. This lab proves it by denying shell entirely.

---

## Background

MCP servers are declared in a JSON config, not via an `agy` subcommand:

- **Workspace scope:** `.agents/mcp_config.json` (this project only)
- **Global scope:** `~/.gemini/antigravity-cli/mcp_config.json` (all projects)

Local servers run as a subprocess (`type: "stdio"`); remote ones use `type: "sse"` / `"streamable-http"` with a `serverUrl`.

> [!NOTE]
> **Prerequisites:** `uv` installed (provides `uvx`, same as Module 3) and `python3`. No accounts or API keys.

---

## Part 1: Create the Billing Database (4 min)

The sample app keeps data in memory; for this lab we materialize a small SQLite copy of the billing domain. Run this once in the sandbox:

```bash
cd ../agy-sample-app
python3 - <<'PY'
import sqlite3
db = sqlite3.connect("billing.db")
db.executescript("""
CREATE TABLE plans(id INTEGER PRIMARY KEY, code TEXT, name TEXT, amount_cents INT, currency TEXT, interval TEXT);
CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, email TEXT);
CREATE TABLE subscriptions(id INTEGER PRIMARY KEY, user_id INT, plan_id INT, status TEXT, started_on TEXT);
CREATE TABLE invoices(id INTEGER PRIMARY KEY, subscription_id INT, amount_cents INT, currency TEXT, status TEXT);
INSERT INTO plans VALUES
 (1,'starter','Starter',900,'USD','monthly'),
 (2,'pro','Pro',2900,'USD','monthly'),
 (3,'pro_yr','Pro Annual',29000,'USD','yearly'),
 (4,'ent','Enterprise',99000,'USD','yearly');
INSERT INTO users VALUES
 (1,'Ada','ada@example.com'),(2,'Bo','bo@example.com'),
 (3,'Cy','cy@example.com'),(4,'Di','di@example.com'),(5,'El','el@example.com');
INSERT INTO subscriptions VALUES
 (1,1,2,'active','2026-01-10'),(2,2,2,'active','2026-02-01'),
 (3,3,3,'active','2026-02-15'),(4,4,4,'active','2026-03-01'),
 (5,5,1,'canceled','2026-01-05'),(6,1,1,'active','2026-03-20');
INSERT INTO invoices VALUES
 (1,1,2900,'USD','paid'),(2,2,2900,'USD','paid'),(3,3,29000,'USD','paid'),
 (4,4,99000,'USD','open'),(5,6,900,'USD','open');
""")
db.commit(); db.close()
print("billing.db created")
PY
```

---

## Part 2: Register the Database MCP Server (3 min)

Create `.agents/mcp_config.json` — a local SQLite MCP server (via `uvx`, no account) scoped to that database:

```json
{
  "mcpServers": {
    "billing-db": {
      "type": "stdio",
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "./billing.db"]
    }
  }
}
```

The server exposes structured tools (`list_tables`, `describe_table`, `read_query`, …) — the agent calls those instead of shelling out to a `sqlite3` binary.

---

## Part 3: Lock It Down, Then Query (10 min)

Launch `agy` in the sandbox and confirm the server:

```bash
agy
```

```text
/mcp
```

Verify `billing-db` shows **connected**. Now **remove the agent's ability to shell or write** so the MCP tool is its *only* path to the data:

```text
/permissions
# select: strict
```

In `strict` mode agy cannot run `!`-shell commands, `curl`, or write files. Ask it business questions anyway — it must use the `billing-db` query tool:

```text
Using the billing-db tools, how many active subscriptions are there per plan? Show plan name and count.
```

```text
Compute monthly recurring revenue (MRR) by plan. Treat yearly plans as amount_cents / 12. Which tier contributes the most?
```

```text
List the users who have an invoice in 'open' status, with the amount.
```

> [!TIP]
> **The point:** the agent couldn't `curl` or `sqlite3` its way in even if it tried — shell is denied. It answers purely through the MCP server's scoped, auditable tools. That's the enterprise pattern: grant a *specific, governed capability* instead of raw shell + credentials.

---

## Part 4: From Local to Managed Remote (3 min)

Remote MCP servers use `serverUrl` instead of a local `command` — and the server, not the agent, holds the credentials:

```json
{
  "mcpServers": {
    "billing-db": {
      "type": "stdio",
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "./billing.db"]
    },
    "managed-data": {
      "type": "sse",
      "serverUrl": "https://your-mcp-server.example.com/sse",
      "env": { "API_KEY": "$MCP_API_KEY" }
    }
  }
}
```

This is exactly how the **managed GCP data lab in Module 3** works — Google-hosted BigQuery/Dataplex MCP servers where auth flows through your Vertex/ADC credentials and the agent never sees a key.

---

## Completion Criteria

- [ ] `billing.db` created and `.agents/mcp_config.json` registers the `billing-db` server
- [ ] `/mcp` shows `billing-db` connected
- [ ] With `/permissions strict` (shell denied), agy answered the business questions **only** via the MCP query tool
- [ ] You can explain MCP's real value — governed, credential-mediated, scoped access — versus letting the agent shell/`curl` freely
