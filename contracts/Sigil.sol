// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Base64.sol";

contract Sigil {
    function svg(bytes32 h) public pure returns (string memory) {
        uint256 xOff = 23;
        uint256 yOff = 1;

        bytes memory d;

        for (uint256 r; r < 8; ++r) {
            for (uint256 x; x < 4; ++x) {
                uint256 i = r * 4 + x;
                if ((uint8(h[i]) & 1) == 0) {
                    // left pixel
                    d = abi.encodePacked(d, _pxPath(xOff + x, yOff + r));
                    // mirrored right pixel
                    d = abi.encodePacked(d, _pxPath(xOff + (7 - x), yOff + r));
                }
            }
        }

        return
            string(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" shape-rendering="crispEdges">',
                    '<path fill="#000000" fill-opacity="0.7" d="',
                    d,
                    '"/>',
                    "</svg>"
                )
            );
    }

    function testimg(bytes32 h) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(svg(h)))
                )
            );
    }

    // single 1x1 pixel as path command
    function _pxPath(uint256 x, uint256 y) private pure returns (bytes memory) {
        return abi.encodePacked("M", _u(x), " ", _u(y), "h1v1h-1Z");
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
