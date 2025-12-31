// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HexLib.sol";

library BodyLib {
    uint256 internal constant BASE_BODY_COLOR_N = 28;
    uint8 internal constant BASE_BODY_COLOR_TAIL = 8; // last pack has 8 colors (indices 20..27)

    uint256 internal constant MATERIAL_BODY_COLOR_N = 5; // 5 pairs => 10 colors in one pack
    uint256 internal constant VAR1_BODY_COLOR_N = 6; // 6 pairs => 12 colors across 2 packs
    uint256 internal constant VAR2_BODY_COLOR_N = 4; // 4 pairs => 8 colors in one pack

    uint256 internal constant OFF_BASE = 0;
    uint256 internal constant OFF_MAT = OFF_BASE + BASE_BODY_COLOR_N;
    uint256 internal constant OFF_VAR1 = OFF_MAT + MATERIAL_BODY_COLOR_N;
    uint256 internal constant OFF_VAR2 = OFF_VAR1 + VAR1_BODY_COLOR_N;
    uint256 internal constant TOTAL_N = OFF_VAR2 + VAR2_BODY_COLOR_N;

    bytes32 internal constant PACK_BASE_0 =
        hex"ebab99d95763eb7d43c16a40fb9e27e6c912d3e387a7d03a8bab39bde8980000";
    bytes32 internal constant PACK_BASE_1 =
        hex"75db6064b45799e4e82ac9deaecaf8639bffc2bce48983ecaa6edb8e5eb80000";
    bytes32 internal constant PACK_BASE_2 =
        hex"edb2e5dd6cd9b65cb7ed77b4c36599ff66002ca05a0066ff0000000000000000";

    bytes32 internal constant PACK_BASE_MATERIALS =
        hex"ffd700b7bec855ddff2aff80ff5555ccac009aa4b222d3ff00f663ff22220000"; // 0..4 base, 5..9 shade

    bytes32 internal constant PACK_VAR1_0 =
        hex"f9f9f9ececec71c83755ddff0080004d4d4dff2a2aff6600aa00d42a7fff0000";
    bytes32 internal constant PACK_VAR1_1 =
        hex"00d455e6c9120000000000000000000000000000000000000000000000000000";

    bytes32 internal constant PACK_VAR2_0 =
        hex"f9f9f9f2f2f2c87137aade8700aad4e6e6e6ffd42a7c916f0000000000000000"; // 0..3 base, 4..7 shade

    string internal constant D_BODY =
        "m 11,8 v 1 h -1 v 1 H 9 v 3 1 3 h 6 v -2 -1 h 1 3 V 10 H 18 V 9 H 17 V 8 Z M 7,18 v 4 h 1 1 6 1 1 V 18 H 16 15 9 8 Z m 14,3 v 1 h -1 v 1 h -1 v 1 h -1 v 1 H 16 15 V 23 H 9 v 2 1 h 1 v 2 h 1 v 1 h 9 v -1 h 1 v -1 h 1 v -1 -1 h 1 v -1 h 1 v 1 h 1 v 1 h 3 v -1 h -1 v -1 h -1 v -2 h -1 v -1 z";

    string internal constant D_MAT_SHADE =
        "m 17,9 v 1 h 1 V 9 Z m 1,1 v 3 h -3 v 1 h 3 1 v -4 z m -3,4 h -1 v 2 h -3 -1 v 1 h 1 3 1 z m 1,5 v 2 H 8 v 1 h 8 1 v -3 z m 9,3 v 2 h 1 v -2 z m 1,2 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m -1,0 h -1 v 1 h 1 z m -1,0 v -1 h -1 v 1 z m -1,-1 v -1 h -1 v 1 z m -1,0 h -1 v 1 h 1 z m -1,1 h -1 v 2 h 1 z m -1,2 h -1 v 1 h 1 z m -1,1 h -8 v 1 h 8 z M 10,23 v 1 h 4 v 1 h 1 v -1 -1 z m 5,2 v 1 h 3 v -1 z";

    string internal constant D_VAR1 =
        "m 11,8 v 1 h -1 v 1 H 9 v 2 1 h 2 v 1 h 2 v 1 h 2 V 14 12 H 14 V 10 H 13 V 8 Z m -2,7 v 1 1 h 1 1 1 1 v -1 h -1 -1 v -1 h -1 z m 0,3 v 1 h 1 v 1 h 1 v 1 h 1 v 1 h 1 1 1 v -1 h -1 v -1 h -1 v -1 h -1 v -1 z m 5,0 v 1 h 1 v 1 h 1 v 1 h 1 v -1 -1 -1 z m -7,1 v 1 1 1 h 1 1 1 V 21 H 9 V 20 H 8 v -1 z m 14,2 v 1 h -1 v 1 h -1 v 1 h -1 v 1 h -1 v 1 1 h 1 v 1 h 1 v 1 h 1 v -1 h 1 v -1 h 1 v -1 -1 h 1 v -1 h -1 v -1 -2 z m 4,1 v 1 h -1 v 1 1 h 1 v 1 h 1 2 V 25 H 27 V 24 H 26 V 22 Z M 9,23 v 2 1 h 1 v 1 1 h 1 v 1 h 1 1 v -1 h 1 v -1 -1 h 1 v -1 -2 z";

    string internal constant D_VAR2 =
        "m 9,10 v 4 h 1 v -1 h 1 v -2 h -1 v -1 z m 3,2 v 1 h 1 v -1 z m -1,2 v 1 h 1 v -1 z m 3,0 v 1 h -1 v 2 h 1 1 v -3 z m -5,2 v 1 h 1 v -1 z m -2,2 v 1 h 1 v -1 z m 4,0 v 1 h 1 v 1 h 2 v -1 h 1 v -1 z m -3,2 v 1 H 7 v 1 h 4 v -1 h -1 v -1 z m 7,0 v 1 h -1 v 1 h 1 2 v -2 z m 6,1 v 1 h 1 v 1 h 2 v -1 h 1 v -1 z m 1,2 h -1 v 1 h 1 z M 9,23 v 3 h 1 1 v -2 h -1 v -1 z m 4,0 v 1 h 1 v 1 h 1 v -1 -1 z m 6,0 v 1 h 1 v -1 z m 6,0 v 1 h 1 v -1 z m -13,2 v 1 h 1 v -1 z m 4,0 v 1 h 2 v -1 z m 3,0 v 1 h 1 v -1 z m 2,0 v 1 h 1 v -1 z m 4,0 v 1 h 2 v -1 z m -13,2 v 1 h -1 v 1 h 4 v -1 h -1 v -1 z m 6,0 v 1 h -1 v 1 h 3 v -1 -1 z";

    function colorBase(uint256 i) internal pure returns (bytes3) {
        if (i >= BASE_BODY_COLOR_N) revert("idx");

        bytes32 w;
        uint256 j;
        uint256 shift;

        if (i < 20) {
            uint256 p = i / 10; // 0 or 1
            j = i - p * 10; // 0..9
            shift = (9 - j) * 24 + 16;
            w = (p == 0) ? PACK_BASE_0 : PACK_BASE_1;
        } else {
            j = i - 20; // 0..7
            shift = (uint256(BASE_BODY_COLOR_TAIL - 1) - j) * 24 + 64;
            w = PACK_BASE_2;
        }

        return bytes3(uint24(uint256(w >> shift)));
    }

    function materialPair(
        uint256 i
    ) internal pure returns (bytes3 base, bytes3 shade) {
        if (i >= MATERIAL_BODY_COLOR_N) revert("idx");
        base = _matColor(i);
        shade = _matColor(i + 5);
    }

    function _matColor(uint256 j) private pure returns (bytes3) {
        uint256 shift = (9 - j) * 24 + 16; // 10 colors, 2-byte pad
        return bytes3(uint24(uint256(PACK_BASE_MATERIALS >> shift)));
    }

    function var1Pair(
        uint256 i
    ) internal pure returns (bytes3 base, bytes3 shade) {
        if (i >= VAR1_BODY_COLOR_N) revert("idx");
        base = _var1Color(i);
        shade = _var1Color(i + 6);
    }

    function _var1Color(uint256 j) private pure returns (bytes3) {
        if (j < 10) {
            uint256 shift = (9 - j) * 24 + 16;
            return bytes3(uint24(uint256(PACK_VAR1_0 >> shift)));
        } else if (j < 12) {
            uint256 k = j - 10; // 0..1
            uint256 shift = (1 - k) * 24 + 208; // 2 colors => padBits 208
            return bytes3(uint24(uint256(PACK_VAR1_1 >> shift)));
        } else {
            revert("idx");
        }
    }

    function var2Pair(
        uint256 i
    ) internal pure returns (bytes3 base, bytes3 shade) {
        if (i >= VAR2_BODY_COLOR_N) revert("idx");
        base = _var2Color(i);
        shade = _var2Color(i + 4);
    }

    function _var2Color(uint256 j) private pure returns (bytes3) {
        if (j >= 8) revert("idx");
        uint256 shift = (7 - j) * 24 + 64; // 8 colors => padBits 64
        return bytes3(uint24(uint256(PACK_VAR2_0 >> shift)));
    }

    function _fillPath(
        bytes3 c,
        string memory d,
        string memory id
    ) private pure returns (bytes memory) {
        return
            abi.encodePacked(
                '<path id="',
                id,
                '" style="fill:#',
                HexLib.hex6(c),
                ';" d="',
                d,
                '" />'
            );
    }

    function selectBodyPattern(
        uint256 i
    ) internal pure returns (string memory) {
        if (i >= TOTAL_N) revert("idx");

        if (i < OFF_MAT) {
            bytes3 c = colorBase(i);
            return string(_fillPath(c, D_BODY, "bodyColor"));
        }
        if (i < OFF_VAR1) {
            (bytes3 c, bytes3 s) = materialPair(i - OFF_MAT);
            return
                string(
                    abi.encodePacked(
                        _fillPath(c, D_BODY, "bodyColor"),
                        _fillPath(s, D_MAT_SHADE, "bodyShade")
                    )
                );
        }

        if (i < OFF_VAR2) {
            (bytes3 c1, bytes3 c2) = var1Pair(i - OFF_VAR1);
            return
                string(
                    abi.encodePacked(
                        _fillPath(c1, D_BODY, "bodyColor"),
                        _fillPath(c2, D_VAR1, "bodyPattern")
                    )
                );
        }

        (bytes3 v1, bytes3 v2) = var2Pair(i - OFF_VAR2);
        return
            string(
                abi.encodePacked(
                    _fillPath(v1, D_BODY, "bodyColor"),
                    _fillPath(v2, D_VAR2, "bodyPattern")
                )
            );
    }

    function body(uint256 i) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<path id="bodyOutline" style="fill:#000;" d="M 11,7 V 8 H 10 V 9 H 9 v 1 H 8 v 7 H 7 v 1 H 6 v 4 h 1 v 1 h 1 v 2 1 h 1 v 2 h 1 v 1 h 1 v 1 h 9 v -1 h 1 v -1 h 1 v -1 h 1 v -1 h 2 v 1 h 3 v -1 h 1 v -1 h -1 v -1 h -1 v -2 h -1 v -1 h -1 v -1 h -4 v 1 h -1 v 1 h -1 v 1 h -1 v 1 h -2 v -1 h 1 v -1 h 1 v -4 h -1 v -1 h -1 v -2 h 3 v -1 h 1 V 10 H 19 V 9 H 18 V 8 H 17 V 7 Z" />',
                    selectBodyPattern(i),
                    '<path id="bodyHighlight" style="fill:#fff;fill-opacity:0.75;" d="m 11,8 v 1 h 6 V 8 Z m 0,1 h -1 v 1 h 1 z m -1,1 H 9 v 7 h 1 z m -3,8 v 1 3 h 1 v -3 h 9 v -1 z m 14,3 v 1 h 4 v -1 z m 0,1 h -1 v 1 h 1 z m -1,1 h -1 v 1 h 1 z m -1,1 h -1 v 1 h 1 z M 9,23 v 3 h 1 v -3 z m 1,3 v 2 h 1 v -2 z m 1,2 v 1 h 1 v -1 z" />'
                )
            );
    }
}
