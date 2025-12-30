// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library SigilLib {
    function sigilPath(
        bytes32 h,
        bytes memory c
    ) internal pure returns (string memory) {
        uint256 xOff = 23;
        uint256 yOff = 1;

        bytes memory d;

        for (uint256 r; r < 8; ++r) {
            for (uint256 x; x < 4; ++x) {
                uint256 i = r * 4 + x;
                if ((uint8(h[i]) & 1) == 0) {
                    d = abi.encodePacked(d, _pxPath(xOff + x, yOff + r));
                    d = abi.encodePacked(d, _pxPath(xOff + (7 - x), yOff + r));
                }
            }
        }

        return string(abi.encodePacked('<path fill="#', c, '" d="', d, '"/>'));
    }

    function _pxPath(uint256 x, uint256 y) private pure returns (bytes memory) {
        return abi.encodePacked("M", _u(x), " ", _u(y), "h1v1h-1Z");
    }

    function _u(uint256 v) private pure returns (string memory) {
        if (v < 10) return string(abi.encodePacked(bytes1(uint8(48 + v))));
        bytes memory b = new bytes(2);
        b[0] = bytes1(uint8(48 + (v / 10)));
        b[1] = bytes1(uint8(48 + (v % 10)));
        return string(b);
    }
}
