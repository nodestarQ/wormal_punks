// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library HexLib {
    function hex6(bytes3 c) internal pure returns (bytes memory out) {
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
        return n < 10 ? bytes1(uint8(48 + n)) : bytes1(uint8(87 + n)); // 0-9 a-f
    }
}
