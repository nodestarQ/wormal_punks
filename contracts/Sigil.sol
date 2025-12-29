// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Base64.sol";

contract Sigil {
    function svg(bytes32 h) public pure returns (string memory) {
        bytes memory out = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 8 8" shape-rendering="crispEdges">'
        );

        for (uint256 r; r < 8; ++r) {
            for (uint256 x; x < 4; ++x) {
                uint256 i = r * 4 + x;
                if ((uint8(h[i]) & 1) == 0) {
                    out = abi.encodePacked(out, _px(x, r), _px(7 - x, r));
                }
            }
        }

        return string(abi.encodePacked(out, "</svg>"));
    }

    function testimg(bytes32 h) external pure returns (string memory) {
        string memory s = svg(h);
        string memory img = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(s))
            )
        );
        return img;
    }

    function _px(uint256 x, uint256 y) private pure returns (bytes memory) {
        return
            abi.encodePacked(
                '<rect x="',
                _d(x),
                '" y="',
                _d(y),
                '" width="1" height="1" fill="#000000',
                '" fill-opacity="0.7"/>'
            );
    }

    function _d(uint256 v) private pure returns (string memory) {
        return string(abi.encodePacked(bytes1(uint8(48 + v))));
    }
}
