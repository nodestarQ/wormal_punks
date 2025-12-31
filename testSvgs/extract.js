// extract-gs.js
// usage:
//   node extract-gs.js worm.svg
// or:
//   node extract-gs.js ./path/to/worm.svg

import fs from "node:fs";

const file = process.argv[2] || "worm.svg";
const svg = fs.readFileSync(file, "utf8");

// --- helpers ---
function escapeForSoliditySingleQuotedString(s) {
  // produce a single-line solidity string literal using single quotes
  return s
    .replace(/\\/g, "\\\\")     // escape backslash
    .replace(/'/g, "\\'")       // escape single quote
    .replace(/\r?\n/g, " ")     // flatten newlines
    .replace(/\s+/g, " ")       // collapse whitespace
    .trim();
}

// Very small tag scanner for extracting direct child <g> blocks:
// - We find the first <svg ...> ... </svg>
// - Inside it: find the first <g ...> ... </g>  (this is svg/g)
// - Then extract all direct child <g>...</g> blocks inside that parent g.
function findFirstTagBlock(source, tagName, startIndex = 0) {
  const openRe = new RegExp(`<${tagName}\\b[^>]*>`, "i");
  const m = openRe.exec(source.slice(startIndex));
  if (!m) return null;

  const openStart = startIndex + m.index;
  const openTag = m[0];
  const openEnd = openStart + openTag.length;

  // Now find matching closing tag using a depth counter for same tagName
  let i = openEnd;
  let depth = 1;

  const tagRe = new RegExp(`</?${tagName}\\b[^>]*>`, "ig");
  tagRe.lastIndex = i;

  while (true) {
    const t = tagRe.exec(source);
    if (!t) return null; // malformed
    const txt = t[0];
    if (txt[1] === "/") depth--;
    else depth++;

    if (depth === 0) {
      const closeStart = t.index;
      const closeEnd = closeStart + txt.length;
      const inner = source.slice(openEnd, closeStart);
      const full = source.slice(openStart, closeEnd);
      return { openStart, openEnd, closeStart, closeEnd, inner, full };
    }
  }
}

function extractDirectChildGs(parentInner) {
  // We need only <g> blocks that are direct children of parent <g>
  // We'll scan all <g> tags and track depth:
  // depth 0 = inside parentInner (not inside any child g)
  // when we hit <g ...> at depth 0 -> start capture, and then find its matching </g>
  const results = [];
  let idx = 0;

  while (idx < parentInner.length) {
    const nextOpen = parentInner.slice(idx).search(/<g\b[^>]*>/i);
    if (nextOpen === -1) break;

    const openStart = idx + nextOpen;
    // find that exact <g ...> block from openStart using matcher
    const block = findFirstTagBlock(parentInner, "g", openStart);
    if (!block) break;

    // If there was no other <g> opened between idx and openStart at depth 0,
    // this block is a direct child (because we always jump to next <g> at the current idx).
    // BUT we must ensure we are not currently inside another child. Our jumping method ensures that:
    // after capturing, we move idx to block.closeEnd.
    results.push(block.full);
    idx = block.closeEnd;
  }

  return results;
}

// --- main extraction pipeline ---
// 1) First <svg>...</svg>
const svgBlock = findFirstTagBlock(svg, "svg", 0);
if (!svgBlock) {
  console.error("Could not find <svg>...</svg> in file:", file);
  process.exit(1);
}

// 2) First <g>...</g> inside svg (svg/g)
const firstG = findFirstTagBlock(svgBlock.inner, "g", 0);
if (!firstG) {
  console.error("Could not find first <g> inside <svg>.");
  process.exit(1);
}

// 3) Direct child <g> blocks inside that parent <g>
const childGs = extractDirectChildGs(firstG.inner);

if (!childGs.length) {
  console.error("No direct child <g> blocks found inside svg>g.");
  process.exit(1);
}

// --- output solidity constants ---
childGs.forEach((gBlock, i) => {
  const s = escapeForSoliditySingleQuotedString(gBlock);
  console.log(
    `string internal constant ELEMENT_${i} = '${s}';`
  );
});

// Optional: also print count
console.error(`\nExtracted ${childGs.length} direct <g> blocks from svg>g in ${file}`);
