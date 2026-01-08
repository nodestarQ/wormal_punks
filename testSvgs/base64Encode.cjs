#!/usr/bin/env node
/**
 * make-metadata.js
 *
 * Usage:
 *   node make-metadata.js \
 *     --svg ./worm.svg \
 *     --name "Worm #Genesis" \
 *     --type "Cypher Worm" \
 *     --pretty
 *
 * Output:
 *   data:application/json;base64,<...>
 */

const fs = require("fs");
const path = require("path");

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const arg = argv[i];
    if (!arg.startsWith("--")) continue;

    const key = arg.slice(2);
    const next = argv[i + 1];

    if (!next || next.startsWith("--")) {
      args[key] = true;
    } else {
      args[key] = next;
      i++;
    }
  }
  return args;
}

function required(args, key) {
  if (!args[key] || args[key] === true) {
    throw new Error(`Missing required option --${key}`);
  }
  return String(args[key]);
}

function optional(args, key, fallback) {
  if (!args[key] || args[key] === true) return fallback;
  return String(args[key]);
}

function readSvgBase64(svgPath) {
  return fs.readFileSync(svgPath).toString("base64");
}

function main() {
  const args = parseArgs(process.argv);

  const svgPath = path.resolve(process.cwd(), required(args, "svg"));
  const name = required(args, "name");
  const typeValue = required(args, "type");

  const svgB64 = readSvgBase64(svgPath);
  const imageDataUri = `data:image/svg+xml;base64,${svgB64}`;

  const metadata = {
    name,
    description: "7,503 Cypher Worms crawling through the Ethereum underground.",
    image: imageDataUri,
    attributes: [
      { trait_type: "Type", value: typeValue },
      { trait_type: "1/1", value: "True" },
    ],
  };

  const json = JSON.stringify(metadata);
  const jsonB64 = Buffer.from(json, "utf8").toString("base64");
  const jsonDataUri = `data:application/json;base64,${jsonB64}`;

  // Primary output (tokenURI-style)
  console.log(jsonDataUri);

  if (args.pretty) {
    console.log("\n--- decoded JSON ---");
    console.log(JSON.stringify(metadata, null, 2));
  }
}

main();
