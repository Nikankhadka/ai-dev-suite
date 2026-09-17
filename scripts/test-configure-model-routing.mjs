#!/usr/bin/env node

import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptsDir = path.dirname(fileURLToPath(import.meta.url));
const helper = path.join(scriptsDir, "configure-model-routing.mjs");
const root = fs.mkdtempSync(path.join(os.tmpdir(), "ai-dev-suite-routing-"));
const home = path.join(root, "home");
const backupOne = path.join(root, "backup-one");
const backupTwo = path.join(root, "backup-two");

function run(backupDir) {
  return spawnSync(process.execPath, [helper, "--home", home, "--backup-dir", backupDir], {
    encoding: "utf8",
  });
}

fs.mkdirSync(path.join(home, ".claude"), { recursive: true });
fs.mkdirSync(path.join(home, ".codex"), { recursive: true });
const originalClaude = `${JSON.stringify({ theme: "dark", env: { KEEP_ME: "yes" }, model: "sonnet" }, null, 2)}\n`;
const originalCodex = `model = "old"\ncustom_key = "keep"\n\n[agents]\ninterrupt_message = false\n\n[mcp_servers.docs]\ncommand = "docs-server"\n`;
fs.writeFileSync(path.join(home, ".claude", "settings.json"), originalClaude);
fs.writeFileSync(path.join(home, ".codex", "config.toml"), originalCodex);

const first = run(backupOne);
assert.equal(first.status, 0, first.stderr);
const claude = JSON.parse(fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8"));
assert.equal(claude.theme, "dark");
assert.equal(claude.model, "claude-opus-5");
assert.equal(claude.effortLevel, "high");
assert.equal(claude.env.KEEP_ME, "yes");
assert.equal(claude.env.CLAUDE_CODE_MAX_CONTEXT_TOKENS, "160000");
assert.equal(claude.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW, "160000");

const codex = fs.readFileSync(path.join(home, ".codex", "config.toml"), "utf8");
assert.match(codex, /^model = "gpt-5\.6-sol"$/m);
assert.match(codex, /^model_reasoning_effort = "high"$/m);
assert.match(codex, /^model_context_window = 160000$/m);
assert.match(codex, /^model_auto_compact_token_limit = 150000$/m);
assert.match(codex, /^custom_key = "keep"$/m);
assert.match(codex, /^\[mcp_servers\.docs\]$/m);
assert.match(codex, /^\[agents\]$/m);
assert.match(codex, /^enabled = true$/m);
assert.match(codex, /^max_concurrent_threads_per_session = 3$/m);
assert.match(codex, /^interrupt_message = false$/m);
assert.equal(
  fs.readFileSync(path.join(backupOne, ".claude", "settings.json"), "utf8"),
  originalClaude,
);
assert.equal(
  fs.readFileSync(path.join(backupOne, ".codex", "config.toml"), "utf8"),
  originalCodex,
);

const firstClaude = fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8");
const firstCodex = fs.readFileSync(path.join(home, ".codex", "config.toml"), "utf8");
const second = run(backupTwo);
assert.equal(second.status, 0, second.stderr);
assert.equal(second.stdout, "");
assert.equal(fs.existsSync(backupTwo), false);
assert.equal(fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8"), firstClaude);
assert.equal(fs.readFileSync(path.join(home, ".codex", "config.toml"), "utf8"), firstCodex);

fs.writeFileSync(path.join(home, ".claude", "settings.json"), "not json\n");
const invalid = run(path.join(root, "backup-invalid"));
assert.notEqual(invalid.status, 0);
assert.equal(fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8"), "not json\n");

fs.rmSync(root, { recursive: true, force: true });
process.stdout.write("model routing configuration tests passed\n");
