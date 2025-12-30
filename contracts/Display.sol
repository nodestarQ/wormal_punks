// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BackgroundLib.sol";
import "./BodyLib.sol";

contract Display {
    function svg(bytes32 h, uint256 b, uint256 t) external pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" shape-rendering="crispEdges">',
                BackgroundLib.backgroundSvg(h, b),
                BodyLib.bodySvg(t),
                "</svg>"
            )
        );
    }
}
