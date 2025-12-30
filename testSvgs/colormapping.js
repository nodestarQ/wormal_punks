// make-packs.js
// node make-packs.js

const COLORS = [
  "0xebab99",
  "0xd95763",
  "0xeb7d43",
  "0xfacc7e",
  "0xfb9e27",
  "0xe6c912",
  "0xd3e387",
  "0xa7d03a",
  "0xbde898",
  "0x75db60",
  "0x99e4e8",
  "0x2ac9de",
  "0xaecaf8",
  "0x639bff",
  "0x5681d5",
  "0x8983ec",
  "0x746fc7",
  "0xaa6edb",
  "0xedb2e5",
  "0xdd6cd9",
  "0xed77b4",
  "0xf9f9f9",
  "0x55ddff",
  "0x666666",
  "0xafafe9",
];


function hexToRgb(hex) {
  hex = hex.trim().toLowerCase().replace(/^0x/, "").replace(/^#/, "");
  if (!/^[0-9a-f]{6}$/.test(hex)) throw new Error(`Bad hex: ${hex}`);
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  return { r, g, b };
}

function rgbToHex({ r, g, b }) {
  const clamp = (v) => Math.max(0, Math.min(255, Math.round(v)));
  const to2 = (v) => clamp(v).toString(16).padStart(2, "0");
  return `${to2(r)}${to2(g)}${to2(b)}`.toLowerCase();
}

// H:0..360, S/L:0..1 (float)
function rgbToHsl(r, g, b) {
  r /= 255; g /= 255; b /= 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const d = max - min;

  let h = 0;
  const l = (max + min) / 2;
  let s = 0;

  if (d !== 0) {
    s = d / (1 - Math.abs(2 * l - 1));
    switch (max) {
      case r: h = ((g - b) / d) % 6; break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
    }
    h *= 60;
    if (h < 0) h += 360;
  }

  return { h, s, l };
}

function hslToRgb(h, s, l) {
  const c = (1 - Math.abs(2 * l - 1)) * s;
  const hp = h / 60;
  const x = c * (1 - Math.abs((hp % 2) - 1));
  let r1 = 0, g1 = 0, b1 = 0;

  if (0 <= hp && hp < 1) [r1, g1, b1] = [c, x, 0];
  else if (1 <= hp && hp < 2) [r1, g1, b1] = [x, c, 0];
  else if (2 <= hp && hp < 3) [r1, g1, b1] = [0, c, x];
  else if (3 <= hp && hp < 4) [r1, g1, b1] = [0, x, c];
  else if (4 <= hp && hp < 5) [r1, g1, b1] = [x, 0, c];
  else if (5 <= hp && hp < 6) [r1, g1, b1] = [c, 0, x];

  const m = l - c / 2;
  return { r: (r1 + m) * 255, g: (g1 + m) * 255, b: (b1 + m) * 255 };
}

// subtract 25 percentage points from Lightness
function darkenMinus25L(hex6) {
  const { r, g, b } = hexToRgb(hex6);
  const { h, s, l } = rgbToHsl(r, g, b);
  const l2 = Math.max(0, l - 0.25);
  return rgbToHex(hslToRgb(h, s, l2));
}

// Packs are 32 bytes.
// We pack 10 colors (30 bytes) MSB -> LSB, then pad with 2 zero bytes (or more for last pack).
function packColors(hexList, packSize = 10) {
  const packs = [];
  for (let i = 0; i < hexList.length; i += packSize) {
    const chunk = hexList.slice(i, i + packSize);

    // concatenate chunk bytes (each 3 bytes = 6 hex chars)
    let hex = chunk.join("");

    // pad to 64 hex chars (32 bytes)
    hex = hex.padEnd(64, "0");

    packs.push(hex);
  }
  return packs;
}

function normalizeHex6(x) {
  return x.trim().toLowerCase().replace(/^0x/, "").replace(/^#/, "");
}

function solidityConst(name, hex64) {
  return `bytes32 internal constant ${name} = hex"${hex64}";`;
}


const baseHex6 = COLORS.map(normalizeHex6);
const darkHex6 = baseHex6.map(darkenMinus25L);

const basePacks = packColors(baseHex6, 10);
const darkPacks = packColors(darkHex6, 10);

console.log("// ---- BASE COLORS (bytes32 packs) ----");
basePacks.forEach((p, i) => console.log(solidityConst(`PACK_BASE_${i}`, p)));

console.log("\n// ---- DARK COLORS (L-25) (bytes32 packs) ----");
darkPacks.forEach((p, i) => console.log(solidityConst(`PACK_DARK_${i}`, p)));

console.log("\n// sanity check example:");
console.log("ebab99 ->", darkenMinus25L("ebab99")); // should print d6532e
