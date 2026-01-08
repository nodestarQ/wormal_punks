// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./BackgroundLib.sol";
import "./BodyData.sol";
import "./EyeData.sol";
import "./HeadData.sol";
import "./AccData.sol";

library Attributes {

    function levels(uint256 level) internal pure returns(string memory){
        if(level == 0) return "Null";
        if(level == 1) return "Seed";
        if(level == 2) return "Node";
        if(level == 3) return "Process";
        if(level == 4) return "Thread";
        if(level == 5) return "Cluster";
        if(level == 6) return "Network";
        if(level == 7) return "Protocol";
        if(level == 8) return "Singularity";
    }


function attributes(
        bytes32 h,
        uint256 level, 
        uint256 b, 
        uint256 t, 
        uint256 e, 
        uint256 he, 
        uint256 a
    ) external pure returns (bytes memory) {
        return abi.encodePacked(
            "[",
            _sigilAttribute(h),
            ",",
            _visualTraitAttributes(b, t, e, he, a),
            ",",
            _levelAttribute(level),
            "]"
        );
    }

    function _sigilAttribute(bytes32 h) private pure returns (bytes memory) {
        return abi.encodePacked(
            '{"trait_type":"Sigil","value":"',
            Strings.toHexString(uint256(h), 32),
            '"}'
        );
    }

    function _visualTraitAttributes(
        uint256 b,
        uint256 t,
        uint256 e,
        uint256 he,
        uint256 a
    ) private pure returns (bytes memory) {
        return abi.encodePacked(
            '{"trait_type":"Background","value":"',
            BackgroundLib.traits(b),
            '"},',
            '{"trait_type":"Body","value":"',
            BodyData.traits(t),
            '"},',
            '{"trait_type":"Eyes","value":"',
            EyeData.traits(e),
            '"},',
            '{"trait_type":"Head","value":"',
            HeadData.traits(he),
            '"},',
            '{"trait_type":"Accessory","value":"',
            AccData.traits(a),
            '"}'
        );
    }

    function _levelAttribute(uint256 level) private pure returns (bytes memory) {
        return abi.encodePacked(
            '{"trait_type":"Level","value":"',
            levels(level),
            '"}'
        );
    }


}