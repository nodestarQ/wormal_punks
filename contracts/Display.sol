// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Base64.sol";
import "./BackgroundLib.sol";
import "./BodyLib.sol";
import "./EyeLib.sol";
import "./HeadStartLib.sol";
import "./HeadEndLib.sol";
import "./AccLib.sol";

contract Display {
    function svg(
        bytes32 h,
        uint256 b,
        uint256 t,
        uint256 e,
        uint256 he,
        uint256 a
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" shape-rendering="crispEdges">',
                    BackgroundLib.background(h, b),
                    BodyLib.body(t),
                    EyeLib.eye(e),
                    (he < 50) ? HeadStartLib.head(he) : HeadEndLib.head(he),
                    AccLib.acc(a),
                    "</svg>"
                )
            );
    }

    function svgBase64(
        bytes32 h,
        uint256 b,
        uint256 t,
        uint256 e,
        uint256 he,
        uint256 a
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(svg(h, b, t, e, he, a)))
                )
            );
    }
}
