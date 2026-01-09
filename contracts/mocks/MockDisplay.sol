// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract MockDisplay {
    function tokenURIFromHash(
        bytes32 seed,
        uint256 level,
        uint256 tokenId
    ) external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,eyJuYW1lIjoiQ3lwaGVyV29ybSAj",
                _toString(tokenId),
                '","level":',
                _toString(level),
                '","seed":"',
                _toHexString(seed),
                '"}'
            )
        );
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _toHexString(bytes32 value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint8(value[i] >> 4)];
            str[1 + i * 2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }
}
