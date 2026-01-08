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
    // Struct to hold visual traits and reduce stack depth
    struct VisualTraits {
        uint256 background;
        uint256 body;
        uint256 eyes;
        uint256 head;
        uint256 accessory;
    }
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
        bytes32[5] memory hs = hashAllChunks(h);
        VisualTraits memory traits = _deriveTraits(hs);
        
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(_buildMetadataJSON(h, level, tokenId, traits))
        ));
    }

    function _deriveTraits(bytes32[5] memory hs) 
        private pure returns (VisualTraits memory) {
        return VisualTraits({
            background: PseudoRandomness.pickBackgroundTrait(hs[0]),
            body: PseudoRandomness.pickBodyTrait(hs[1]),
            eyes: PseudoRandomness.pickEyeTrait(hs[2]),
            head: PseudoRandomness.pickHeadTrait(hs[3]),
            accessory: PseudoRandomness.pickAccessoryTrait(hs[4])
        });
    }

    function _buildMetadataJSON(
        bytes32 h,
        uint256 level, 
        uint256 tokenId,
        VisualTraits memory traits
    ) private pure returns (bytes memory) {
        return abi.encodePacked(
            "{",
            '"name":"Worm #',
            Strings.toString(tokenId),
            '",',
            '"description":"7,503 Cypher Worms crawling through the Ethereum underground.",',
            '"image":"',
            _buildImageDataURI(h, traits),
            '",',
            '"attributes":',
            Attributes.attributes(h, level, traits.background, traits.body, traits.eyes, traits.head, traits.accessory),
            "}"
        );
    }

    function _buildImageDataURI(bytes32 h, VisualTraits memory traits) 
        private pure returns (string memory) {
        return string(abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg(h, traits.background, traits.body, traits.eyes, traits.head, traits.accessory)))
        ));
    }

}
