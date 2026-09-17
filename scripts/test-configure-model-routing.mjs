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
fs.mkdirSync(path.join(home, ".pi", "agent"), { recursive: true });
const originalClaude = `${JSON.stringify({ theme: "dark", env: { KEEP_ME: "yes" }, model: "sonnet" }, null, 2)}\n`;
const originalCodex = `model = "old"\ncustom_key = "keep"\n\n[agents]\ninterrupt_message = false\n\n[mcp_servers.docs]\ncommand = "docs-server"\n`;
const originalPiSettings = `${JSON.stringify(
  {
    theme: "light",
    skills: ["~/custom-skill"],
    compaction: { keepRecentTokens: 12345 },
  },
  null,
  2,
)}\n`;
const originalPiModels = `${JSON.stringify(
  {
    providers: {
      custom: { baseUrl: "http://localhost:11434/v1" },
      "openai-codex": { headers: { "x-keep": "yes" } },
    },
  },
  null,
  2,
)}\n`;
fs.writeFileSync(path.join(home, ".claude", "settings.json"), originalClaude);
fs.writeFileSync(path.join(home, ".codex", "config.toml"), originalCodex);
fs.writeFileSync(path.join(home, ".pi", "agent", "settings.json"), originalPiSettings);
fs.writeFileSync(path.join(home, ".pi", "agent", "models.json"), originalPiModels);

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
const piSettings = JSON.parse(fs.readFileSync(path.join(home, ".pi", "agent", "settings.json"), "utf8"));
assert.equal(piSettings.theme, "light");
assert.equal(piSettings.defaultProvider, "openai-codex");
assert.equal(piSettings.defaultModel, "gpt-5.6-sol");
assert.equal(piSettings.defaultThinkingLevel, "high");
assert.equal(piSettings.modelThinkingLevels["openai-codex/gpt-5.6-luna"], "low");
assert.equal(piSettings.modelThinkingLevels["openai-codex/gpt-5.6-terra"], "xhigh");
assert.equal(piSettings.compaction.enabled, true);
assert.equal(piSettings.compaction.keepRecentTokens, 12345);
assert.deepEqual(piSettings.skills, ["~/custom-skill", "~/.agents/skills", "~/.claude/skills"]);
assert.equal(piSettings.enableSkillCommands, true);
const piModels = JSON.parse(fs.readFileSync(path.join(home, ".pi", "agent", "models.json"), "utf8"));
assert.equal(piModels.providers.custom.baseUrl, "http://localhost:11434/v1");
assert.equal(piModels.providers["openai-codex"].headers["x-keep"], "yes");
for (const model of ["gpt-5.6-sol", "gpt-5.6-luna", "gpt-5.6-terra"]) {
  assert.equal(piModels.providers["openai-codex"].modelOverrides[model].contextWindow, 160000);
}
assert.equal(
  fs.readFileSync(path.join(backupOne, ".claude", "settings.json"), "utf8"),
  originalClaude,
);
assert.equal(
  fs.readFileSync(path.join(backupOne, ".codex", "config.toml"), "utf8"),
  originalCodex,
);
assert.equal(
  fs.readFileSync(path.join(backupOne, ".pi", "agent", "settings.json"), "utf8"),
  originalPiSettings,
);
assert.equal(
  fs.readFileSync(path.join(backupOne, ".pi", "agent", "models.json"), "utf8"),
  originalPiModels,
);

const firstClaude = fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8");
const firstCodex = fs.readFileSync(path.join(home, ".codex", "config.toml"), "utf8");
const firstPiSettings = fs.readFileSync(path.join(home, ".pi", "agent", "settings.json"), "utf8");
const firstPiModels = fs.readFileSync(path.join(home, ".pi", "agent", "models.json"), "utf8");
const second = run(backupTwo);
assert.equal(second.status, 0, second.stderr);
assert.equal(second.stdout, "");
assert.equal(fs.existsSync(backupTwo), false);
assert.equal(fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8"), firstClaude);
assert.equal(fs.readFileSync(path.join(home, ".codex", "config.toml"), "utf8"), firstCodex);
assert.equal(
  fs.readFileSync(path.join(home, ".pi", "agent", "settings.json"), "utf8"),
  firstPiSettings,
);
assert.equal(fs.readFileSync(path.join(home, ".pi", "agent", "models.json"), "utf8"), firstPiModels);

fs.writeFileSync(path.join(home, ".claude", "settings.json"), "not json\n");
const invalid = run(path.join(root, "backup-invalid"));
assert.notEqual(invalid.status, 0);
assert.equal(fs.readFileSync(path.join(home, ".claude", "settings.json"), "utf8"), "not json\n");

fs.rmSync(root, { recursive: true, force: true });
process.stdout.write("model routing configuration tests passed\n");
