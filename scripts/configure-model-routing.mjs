#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

function argument(name, fallback) {
  const index = process.argv.indexOf(name);
  return index === -1 ? fallback : process.argv[index + 1];
}

const home = path.resolve(argument("--home", os.homedir()));
const backupRoot = path.resolve(
  argument(
    "--backup-dir",
    path.join(home, ".ai-dev-suite-backups", new Date().toISOString().replaceAll(/[:.]/g, "-")),
  ),
);
const backedUp = new Set();

function backup(file) {
  if (!fs.existsSync(file) || backedUp.has(file)) return;
  const relative = path.relative(home, file);
  if (relative.startsWith("..")) throw new Error(`Refusing to back up path outside home: ${file}`);
  const destination = path.join(backupRoot, relative);
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.copyFileSync(file, destination);
  backedUp.add(file);
  process.stdout.write(`backed up ${file} -> ${destination}\n`);
}

function writeChanged(file, before, after) {
  if (before === after) return false;
  backup(file);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, after);
  process.stdout.write(`updated ${file}\n`);
  return true;
}

function readJsonObject(file) {
  const before = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : "";
  let value = {};
  if (before.trim()) {
    try {
      value = JSON.parse(before);
    } catch (error) {
      throw new Error(`Cannot update invalid JSON in ${file}: ${error.message}`);
    }
  }
  if (!value || Array.isArray(value) || typeof value !== "object") {
    throw new Error(`Expected a JSON object in ${file}`);
  }
  return { before, value };
}

function objectOrEmpty(value) {
  return value && typeof value === "object" && !Array.isArray(value) ? value : {};
}

function updateClaudeSettings() {
  const file = path.join(home, ".claude", "settings.json");
  const { before, value: settings } = readJsonObject(file);

  settings.model = "claude-opus-5";
  settings.effortLevel = "high";
  settings.autoCompactEnabled = true;
  settings.env = {
    ...objectOrEmpty(settings.env),
    CLAUDE_CODE_MAX_CONTEXT_TOKENS: "160000",
    CLAUDE_CODE_AUTO_COMPACT_WINDOW: "160000",
  };

  writeChanged(file, before, `${JSON.stringify(settings, null, 2)}\n`);
}

function updatePiSettings() {
  const file = path.join(home, ".pi", "agent", "settings.json");
  const { before, value: settings } = readJsonObject(file);
  const existingSkills = Array.isArray(settings.skills) ? settings.skills : [];

  settings.defaultProvider = "openai-codex";
  settings.defaultModel = "gpt-5.6-sol";
  settings.defaultThinkingLevel = "high";
  settings.modelThinkingLevels = {
    ...objectOrEmpty(settings.modelThinkingLevels),
    "openai-codex/gpt-5.6-sol": "high",
    "openai-codex/gpt-5.6-luna": "low",
    "openai-codex/gpt-5.6-terra": "xhigh",
  };
  settings.compaction = {
    ...objectOrEmpty(settings.compaction),
    enabled: true,
  };
  settings.skills = [...new Set([...existingSkills, "~/.agents/skills", "~/.claude/skills"])];
  settings.enableSkillCommands = true;

  writeChanged(file, before, `${JSON.stringify(settings, null, 2)}\n`);
}

function updatePiModels() {
  const file = path.join(home, ".pi", "agent", "models.json");
  const { before, value: models } = readJsonObject(file);
  const providers = objectOrEmpty(models.providers);
  const codex = objectOrEmpty(providers["openai-codex"]);
  const overrides = objectOrEmpty(codex.modelOverrides);

  for (const model of ["gpt-5.6-sol", "gpt-5.6-luna", "gpt-5.6-terra"]) {
    const existing = objectOrEmpty(overrides[model]);
    overrides[model] = { ...existing, contextWindow: 160000 };
  }
  codex.modelOverrides = overrides;
  providers["openai-codex"] = codex;
  models.providers = providers;

  writeChanged(file, before, `${JSON.stringify(models, null, 2)}\n`);
}

function tomlValue(value) {
  return typeof value === "number" ? String(value) : JSON.stringify(value);
}

function updateTomlTable(lines, tableName, values) {
  const header = `[${tableName}]`;
  const starts = lines
    .map((line, index) => ({ line, index }))
    .filter(({ line }) => line.trim() === header);
  if (starts.length > 1) throw new Error(`Duplicate ${header} tables in Codex config`);

  let start;
  let end;
  if (starts.length === 0) {
    while (lines.length && lines.at(-1) === "") lines.pop();
    lines.push("", header);
    start = lines.length - 1;
    end = lines.length;
  } else {
    start = starts[0].index;
    end = lines.findIndex((line, index) => index > start && /^\s*\[/.test(line));
    if (end === -1) end = lines.length;
  }

  for (const [key, value] of values) {
    const matches = lines
      .slice(start + 1, end)
      .map((line, index) => ({ line, index: start + 1 + index }))
      .filter(({ line }) => new RegExp(`^\\s*${key}\\s*=`).test(line));
    if (matches.length > 1) throw new Error(`Duplicate ${tableName}.${key} entries in Codex config`);
    const replacement = `${key} = ${tomlValue(value)}`;
    if (matches.length === 1) lines[matches[0].index] = replacement;
    else {
      lines.splice(end, 0, replacement);
      end += 1;
    }
  }
}

function updateCodexConfig() {
  const file = path.join(home, ".codex", "config.toml");
  const before = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : "";
  const lines = before.split("\n");
  const firstTable = lines.findIndex((line) => /^\s*\[/.test(line));
  const splitAt = firstTable === -1 ? lines.length : firstTable;
  const top = lines.slice(0, splitAt);
  const rest = lines.slice(splitAt);
  const values = new Map([
    ["model", "gpt-5.6-sol"],
    ["model_reasoning_effort", "high"],
    ["model_context_window", 160000],
    ["model_auto_compact_token_limit", 150000],
    ["model_auto_compact_token_limit_scope", "total"],
  ]);

  for (const [key, value] of values) {
    const matches = top
      .map((line, index) => ({ line, index }))
      .filter(({ line }) => new RegExp(`^\\s*${key}\\s*=`).test(line));
    if (matches.length > 1) throw new Error(`Duplicate top-level ${key} entries in ${file}`);
    const replacement = `${key} = ${tomlValue(value)}`;
    if (matches.length === 1) top[matches[0].index] = replacement;
    else top.push(replacement);
  }

  while (top.length && top.at(-1) === "") top.pop();
  const outputLines = [
    ...(top.length ? top : ["# AI Dev Suite Codex configuration"]),
    ...(rest.length ? ["", ...rest] : []),
  ];
  updateTomlTable(outputLines, "agents", [
    ["enabled", true],
    ["max_concurrent_threads_per_session", 3],
  ]);
  const output = outputLines.join("\n");
  writeChanged(file, before, `${output.replace(/\n+$/u, "")}\n`);
}

try {
  updateClaudeSettings();
  updateCodexConfig();
  updatePiSettings();
  updatePiModels();
} catch (error) {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
}
