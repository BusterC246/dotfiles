#!/usr/bin/env node
// Validate JSONC files (JSON with // and /* */ comments and trailing commas).
// Usage: node scripts/validate-jsonc.mjs [files...]
// With no arguments, validates every *.jsonc file in the repository.

import { lstatSync, readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";

const IGNORED_DIRS = new Set([".git", "node_modules", ".omo"]);

function findJsonc(dir, found = []) {
  for (const entry of readdirSync(dir)) {
    if (IGNORED_DIRS.has(entry)) continue;
    const full = join(dir, entry);
    const stat = lstatSync(full);
    if (stat.isSymbolicLink()) continue;
    if (stat.isDirectory()) findJsonc(full, found);
    else if (entry.endsWith(".jsonc")) found.push(full);
  }
  return found;
}

// String-aware: skips over quoted strings so "//" inside a URL is not a comment.
function stripJsonc(text) {
  const withoutComments = text.replace(
    /\\"|"(?:\\.|[^"\\])*"|(\/\/[^\n]*|\/\*[\s\S]*?\*\/)/g,
    (match, comment) => (comment ? "" : match)
  );
  return withoutComments.replace(
    /\\"|"(?:\\.|[^"\\])*"|(,)(\s*[}\]])/g,
    (match, comma, closing) => (comma ? closing : match)
  );
}

function locate(text, message) {
  const match = /position (\d+)/.exec(message);
  if (!match) return message;
  const position = Number(match[1]);
  const before = text.slice(0, position);
  const line = before.split("\n").length;
  const column = position - before.lastIndexOf("\n");
  const source = text.split("\n")[line - 1] ?? "";
  return `${message}\n    line ${line}, column ${column}\n    ${source.trim()}`;
}

const files = process.argv.length > 2 ? process.argv.slice(2) : findJsonc(process.cwd());
if (files.length === 0) {
  console.log("No .jsonc files found.");
  process.exit(0);
}

let failed = 0;
for (const file of files) {
  const text = readFileSync(file, "utf-8").replace(/^\uFEFF/, "");
  try {
    JSON.parse(stripJsonc(text));
    console.log(`ok   ${relative(process.cwd(), file)}`);
  } catch (error) {
    failed += 1;
    console.error(`FAIL ${relative(process.cwd(), file)}: ${locate(text, error.message)}`);
  }
}

process.exit(failed === 0 ? 0 : 1);
