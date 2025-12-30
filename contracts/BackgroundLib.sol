// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SigilLib.sol";

library BackgroundLib {
    uint256 internal constant N = 25;

    bytes32 internal constant PACK_BASE_0 =
        hex"ebab99d95763eb7d43facc7efb9e27e6c912d3e387a7d03abde89875db600000";
    bytes32 internal constant PACK_BASE_1 =
        hex"99e4e82ac9deaecaf8639bff5681d58983ec746fc7aa6edbedb2e5dd6cd90000";
    bytes32 internal constant PACK_BASE_2 =
        hex"ed77b4f9f9f955ddff666666afafe90000000000000000000000000000000000";

    bytes32 internal constant PACK_DARK_0 =
        hex"d6532e90212b9e4111ef9a09a05b03706209a5be2c59701b7ad1303799230000";
    bytes32 internal constant PACK_DARK_1 =
        hex"31c8d1126b76397dee0051e32245892a20d03833836b28a1d54bc2a4269f0000";
    bytes32 internal constant PACK_DARK_2 =
        hex"ca1b75b9b9b900aad42626264b4bce0000000000000000000000000000000000";

    function colorBase(uint256 i) internal pure returns (bytes3) {
        return _color(i, false);
    }

    function colorDark(uint256 i) internal pure returns (bytes3) {
        return _color(i, true);
    }

    function _color(uint256 i, bool dark) private pure returns (bytes3) {
        if (i >= N) revert("idx");

        bytes32 w;
        uint256 j;
        uint256 shift;

        if (i < 20) {
            // packs 0..1, 10 items each, 2 bytes padding => +16 bits
            uint256 p = i / 10;     // 0 or 1
            j = i - p * 10;         // 0..9
            shift = (9 - j) * 24 + 16;

            if (!dark) w = (p == 0) ? PACK_BASE_0 : PACK_BASE_1;
            else       w = (p == 0) ? PACK_DARK_0 : PACK_DARK_1;
        } else {
            // pack 2, 5 items, 17 bytes padding => +136 bits
            j = i - 20;             // 0..4
            shift = (4 - j) * 24 + 136;

            w = dark ? PACK_DARK_2 : PACK_BASE_2;
        }

        return bytes3(uint24(uint256(w >> shift)));
    }

    function backgroundSvg(bytes32 h, uint256 i) internal pure returns (string memory) {
        bytes3 wall = colorBase(i);
        bytes3 floor = colorDark(i);


        return string(
            abi.encodePacked(
                '<rect style="fill:#', _hex(wall),
                ';" id="wall" width="32" height="24" x="0" y="0" />',
                '<rect style="fill:#', _hex(floor),
                ';" id="floor" width="32" height="8" x="0" y="24" />',
                SigilLib.sigilPath(h, _hex(floor))
            )
        );
    }

    function _hex(bytes3 c) private pure returns (bytes memory out) {
        out = new bytes(6);
        uint24 v = uint24(c);
        out[0] = _n(uint8(v >> 20));
        out[1] = _n(uint8(v >> 16));
        out[2] = _n(uint8(v >> 12));
        out[3] = _n(uint8(v >> 8));
        out[4] = _n(uint8(v >> 4));
        out[5] = _n(uint8(v));
    }

    function _n(uint8 x) private pure returns (bytes1) {
        uint8 n = x & 0x0f;
        return n < 10 ? bytes1(uint8(48 + n)) : bytes1(uint8(87 + n));
    }
}
