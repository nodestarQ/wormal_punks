// make-packs.js
// node make-packs.js

const BG_COLORS = [
    "0xebab99", "0xd95763", "0xeb7d43", "0xfacc7e", "0xfb9e27", "0xe6c912", "0xd3e387", "0xa7d03a", "0xbde898", "0x75db60",
    "0x99e4e8", "0x2ac9de", "0xaecaf8", "0x639bff", "0x5681d5", "0x8983ec", "0x746fc7", "0xaa6edb", "0xedb2e5", "0xdd6cd9",
    "0xed77b4", "0xf9f9f9", "0x55ddff", "0x666666", "0xafafe9",
];

const BODY_COLORS = [
    "0xebab99", "0xd95763", "0xeb7d43", "0xc16a40", "0xfb9e27", "0xe6c912", "0xd3e387", "0xa7d03a", "0x8bab39", "0xbde898",
    "0x75db60", "0x64b457", "0x99e4e8", "0x2ac9de", "0xaecaf8", "0x639bff", "0xc2bce4", "0x8983ec", "0xaa6edb", "0x8e5eb8",
    "0xedb2e5", "0xdd6cd9", "0xb65cb7", "0xed77b4", "0xc36599", "0xff6600", "0x2ca05a", "0x0066ff",
];

const BODY_COLORS_MATERIALS = [
    "0xffd700", "0xb7bec8", "0x55ddff", "0x2aff80", "0xff5555"
]

const COLOR_VARIATION1 = [
    "0xf9f9f9", "0xececec", "0x71c837", "0x55ddff", "0x008000", "0x4d4d4d",
    "0xff2a2a", "0xff6600", "0xaa00d4", "0x2a7fff", "0x00d455", "0xe6c912"
]

const COLOR_VARIATION2 = [
    "0xf9f9f9", "0xf2f2f2", "0xc87137", "0xaade87",
    "0x00aad4", "0xe6e6e6", "0xffd42a", "0x7c916f"
]


const COLORS = COLOR_VARIATION2; // <--- pick source here
console.log(COLORS.length);

// bytes32 can hold 10 * bytes3 = 30 bytes, leaving 2 bytes padding
const PACK_SIZE = 10;


function hexToRgb(hex) {
    hex = hex.trim().toLowerCase().replace(/^0x/, "").replace(/^#/, "");
    if (!/^[0-9a-f]{6}$/.test(hex)) throw new Error(`Bad hex: ${hex}`);
    return {
        r: parseInt(hex.slice(0, 2), 16),
        g: parseInt(hex.slice(2, 4), 16),
        b: parseInt(hex.slice(4, 6), 16),
    };
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

function darkenMinus25L(hex6) {
    const { r, g, b } = hexToRgb(hex6);
    const { h, s, l } = rgbToHsl(r, g, b);
    return rgbToHex(hslToRgb(h, s, Math.max(0, l - 0.25)));
}

function darkenMinus10L(hex6) {
    const { r, g, b } = hexToRgb(hex6);
    const { h, s, l } = rgbToHsl(r, g, b);
    return rgbToHex(hslToRgb(h, s, Math.max(0, l - 0.10)));
}

function normalizeHex6(x) {
    return x.trim().toLowerCase().replace(/^0x/, "").replace(/^#/, "");
}

function solidityConst(name, hex64) {
    return `bytes32 internal constant ${name} = hex"${hex64}";`;
}

function packColorsAdaptive(hexList, packSize) {
    const packs = [];
    for (let i = 0; i < hexList.length; i += packSize) {
        const chunk = hexList.slice(i, i + packSize);
        const count = chunk.length;

        // 3 bytes per color
        const usedBytes = count * 3;
        const padBytes = 32 - usedBytes;
        if (padBytes < 0) throw new Error("pack overflow");

        let hex = chunk.join("");              // usedBytes * 2 hex chars
        hex = hex + "0".repeat(padBytes * 2);  // pad to 32 bytes => 64 hex chars

        if (hex.length !== 64) throw new Error(`bad pack len: ${hex.length}`);
        packs.push({ hex64: hex, count, padBytes });
    }
    return packs;
}


const baseHex6 = COLORS.map(normalizeHex6);
const darkHex6 = baseHex6.map(darkenMinus10L);

const basePacks = packColorsAdaptive(baseHex6, PACK_SIZE);
const darkPacks = packColorsAdaptive(darkHex6, PACK_SIZE);

console.log(`// colors: ${COLORS.length}, packSize: ${PACK_SIZE}, packs: ${basePacks.length}`);
console.log(`// NOTE: packs are MSB-aligned and padded with zeros to 32 bytes.\n`);

console.log("// ---- BASE COLORS (bytes32 packs) ----");
basePacks.forEach((p, i) => {
    console.log(`// pack ${i}: count=${p.count}, padBytes=${p.padBytes}`);
    console.log(solidityConst(`PACK_BASE_${i}`, p.hex64));
});

console.log("\n// ---- DARK COLORS (L-25) (bytes32 packs) ----");
darkPacks.forEach((p, i) => {
    console.log(`// pack ${i}: count=${p.count}, padBytes=${p.padBytes}`);
    console.log(solidityConst(`PACK_DARK_${i}`, p.hex64));
});

console.log("\n// sanity check example:");
console.log("ebab99 ->", darkenMinus25L("ebab99")); // d6532e
