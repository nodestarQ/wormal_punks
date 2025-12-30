// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Sigil {
    function svg(bytes32 h) public pure returns (string memory) {
        uint256 xOff = 23;
        uint256 yOff = 1;

        bytes memory out = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" shape-rendering="crispEdges">'
        );

        for (uint256 r; r < 8; ++r) {
            for (uint256 x; x < 4; ++x) {
                uint256 i = r * 4 + x;
                if ((uint8(h[i]) & 1) == 0) {
                    out = abi.encodePacked(
                        out,
                        _px(xOff + x, yOff + r),
                        _px(xOff + (7 - x), yOff + r)
                    );
                }
            }
        }

        return string(abi.encodePacked(out, "</svg>"));
    }

    function _px(uint256 x, uint256 y) private pure returns (bytes memory) {
        return
            abi.encodePacked(
                '<rect x="',
                _u(x),
                '" y="',
                _u(y),
                '" width="1" height="1" fill="#000000" fill-opacity="0.7"/>'
            );
    }

    function _u(uint256 v) private pure returns (string memory) {
        if (v < 10) {
            return string(abi.encodePacked(bytes1(uint8(48 + v))));
        }
        bytes memory b = new bytes(2);
        b[0] = bytes1(uint8(48 + (v / 10)));
        b[1] = bytes1(uint8(48 + (v % 10)));
        return string(b);
    }
}
