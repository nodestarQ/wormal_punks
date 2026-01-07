// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./BackgroundLib.sol";
import "./BodyLib.sol";
import "./EyeLib.sol";
import "./HeadStartLib.sol";
import "./HeadEndLib.sol";
import "./AccLib.sol";
import "./Attributes.sol";
import "./PseudoRandomness.sol";

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
                    BackgroundLib.visual(h, b),
                    BodyLib.visual(t),
                    EyeLib.visual(e),
                    (he < 50) ? HeadStartLib.visual(he) : HeadEndLib.visual(he),
                    AccLib.visual(a),
                    "</svg>"
                )
            );
    }

    function hashChunk(
        bytes32 seed,
        uint8 index
    ) internal pure returns (bytes32) {
        require(index < 5, "index out of range");

        uint256 offset = uint256(index) * 6;

        bytes memory chunk = new bytes(6);
        for (uint256 i = 0; i < 6; i++) {
            chunk[i] = seed[offset + i];
        }

        return keccak256(chunk);
    }

    function hashAllChunks(
        bytes32 seed
    ) internal pure returns (bytes32[5] memory hashes) {
        for (uint8 i = 0; i < 5; i++) {
            hashes[i] = hashChunk(seed, i);
        }
    }

    function tokenURIFromHash(
        bytes32 h,
        uint256 level,
        uint256 tokenId
    ) external pure returns (string memory) {
        // derive traits
        bytes32[5] memory hs = hashAllChunks(h);
        uint256 b = PseudoRandomness.pickBackgroundTrait(hs[0]);
        uint256 t = PseudoRandomness.pickBodyTrait(hs[1]);
        uint256 e = PseudoRandomness.pickEyeTrait(hs[2]);
        uint256 he = PseudoRandomness.pickHeadTrait(hs[3]);
        uint256 a = PseudoRandomness.pickAccessoryTrait(hs[4]);


        // image (base64 svg data uri)
        string memory image = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(svg(h, b, t, e, he, a)))
            )
        );


        // metadata JSON
        bytes memory json = abi.encodePacked(
            "{",
            '"name":"Worm #',
            Strings.toString(tokenId),
            '",',
            '"description":"7,503 Cypher Worms crawling through the Ethereum underground",',
            '"image":"',
            image,
            '",',
            '"attributes":',
            Attributes.attributes(h, level, b, t, e, he, a),
            "}"
        );

        // base64 encode full JSON as data:application/json
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(json)
                )
            );
    }

}
