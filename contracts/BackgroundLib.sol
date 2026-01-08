// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./SigilLib.sol";
import "./HexLib.sol";

library BackgroundLib {
    uint256 internal constant N = 25;
    uint256 private constant COLOR_BITS = 24;
    uint256 private constant PACK01_COUNT = 10;
    uint256 private constant PACK01_PAD_BITS = (32 - (PACK01_COUNT * 3)) * 8;
    uint256 private constant PACK2_COUNT = 6;
    uint256 private constant PACK2_PAD_BITS = (32 - (PACK2_COUNT * 3)) * 8;

    bytes32 internal constant PACK_BASE_0 =
        hex"ff99b3ff99e5e599ffb399ff99b3ff99e5ff99ffe599ffb3b3ff99e5ff990000";
    bytes32 internal constant PACK_BASE_1 =
        hex"ffe599ffb399f9f9f9ff0080ff00ff8000ff0000ff0080ff00ffff00ff800000";
    bytes32 internal constant PACK_BASE_2 =
        hex"00ff0080ff00ffff00ff8000ff00006666660000000000000000000000000000";

    bytes32 internal constant PACK_DARK_0 =
        hex"ff668dff66d8d866ff8d66ff668dff66d8ff66ffd866ff8d8dff66d8ff660000";
    bytes32 internal constant PACK_DARK_1 =
        hex"ffd866ff8d66e0e0e0cc0066cc00cc6600cc0000cc0066cc00cccc00cc660000";
    bytes32 internal constant PACK_DARK_2 =
        hex"00cc0066cc00cccc00cc6600cc00004d4d4d0000000000000000000000000000";

    string internal constant ELEMENT_0 = "Pink Light";
    string internal constant ELEMENT_1 = "Magenta Light";
    string internal constant ELEMENT_2 = "Purple Light";
    string internal constant ELEMENT_3 = "Indigo Light";
    string internal constant ELEMENT_4 = "Blue Light";
    string internal constant ELEMENT_5 = "Cyan Light";
    string internal constant ELEMENT_6 = "Mint Light";
    string internal constant ELEMENT_7 = "Green Light";
    string internal constant ELEMENT_8 = "Lime Light";
    string internal constant ELEMENT_9 = "Yellow Light";
    string internal constant ELEMENT_10 = "Amber Light";
    string internal constant ELEMENT_11 = "Orange Light";
    string internal constant ELEMENT_12 = "Null";
    string internal constant ELEMENT_13 = "Pink Neutral";
    string internal constant ELEMENT_14 = "Magenta Neutral";
    string internal constant ELEMENT_15 = "Purple Neutral";
    string internal constant ELEMENT_16 = "Indigo Neutral";
    string internal constant ELEMENT_17 = "Blue Neutral";
    string internal constant ELEMENT_18 = "Cyan Neutral";
    string internal constant ELEMENT_19 = "Mint Neutral";
    string internal constant ELEMENT_20 = "Green Neutral";
    string internal constant ELEMENT_21 = "Lime Neutral";
    string internal constant ELEMENT_22 = "Yellow Neutral";
    string internal constant ELEMENT_23 = "Amber Neutral";
    string internal constant ELEMENT_24 = "Orange Neutral";
    string internal constant ELEMENT_25 = "Blackout";

    function traits(uint256 i) external pure returns (string memory) {
        if (i == 0) return ELEMENT_0;
        if (i == 1) return ELEMENT_1;
        if (i == 2) return ELEMENT_2;
        if (i == 3) return ELEMENT_3;
        if (i == 4) return ELEMENT_4;
        if (i == 5) return ELEMENT_5;
        if (i == 6) return ELEMENT_6;
        if (i == 7) return ELEMENT_7;
        if (i == 8) return ELEMENT_8;
        if (i == 9) return ELEMENT_9;
        if (i == 10) return ELEMENT_10;
        if (i == 11) return ELEMENT_11;
        if (i == 12) return ELEMENT_12;
        if (i == 13) return ELEMENT_13;
        if (i == 14) return ELEMENT_14;
        if (i == 15) return ELEMENT_15;
        if (i == 16) return ELEMENT_16;
        if (i == 17) return ELEMENT_17;
        if (i == 18) return ELEMENT_18;
        if (i == 19) return ELEMENT_19;
        if (i == 20) return ELEMENT_20;
        if (i == 21) return ELEMENT_21;
        if (i == 22) return ELEMENT_22;
        if (i == 23) return ELEMENT_23;
        if (i == 24) return ELEMENT_24;
        if (i == 25) return ELEMENT_25;

        revert("background idx");
    }

    function colorBase(uint256 i) internal pure returns (bytes3) {
        return _color(i, false);
    }

    function colorDark(uint256 i) internal pure returns (bytes3) {
        return _color(i, true);
    }

    function _color(uint256 i, bool dark) private pure returns (bytes3) {
        if (i > N) revert("background idx");

        bytes32 w;
        uint256 j;
        uint256 shift;

        if (i < 20) {
            uint256 p = i / 10;
            j = i - p * 10;
            shift = (PACK01_COUNT - 1 - j) * COLOR_BITS + PACK01_PAD_BITS;

            if (!dark) w = (p == 0) ? PACK_BASE_0 : PACK_BASE_1;
            else w = (p == 0) ? PACK_DARK_0 : PACK_DARK_1;
        } else {
            j = i - 20;
            shift = (PACK2_COUNT - 1 - j) * COLOR_BITS + PACK2_PAD_BITS;
            w = dark ? PACK_DARK_2 : PACK_BASE_2;
        }

        return bytes3(uint24(uint256(w >> shift)));
    }

    function visual(
        bytes32 h,
        uint256 i
    ) external pure returns (string memory) {
        bytes3 wall = colorBase(i);
        bytes3 floor = colorDark(i);

        return
            string(
                abi.encodePacked(
                    '<rect style="fill:#',
                    HexLib.hex6(wall),
                    ';" id="wall" width="32" height="24" x="0" y="0" />',
                    '<rect style="fill:#',
                    HexLib.hex6(floor),
                    ';" id="floor" width="32" height="8" x="0" y="24" />',
                    SigilLib.sigilPath(h, HexLib.hex6(floor))
                )
            );
    }
}
