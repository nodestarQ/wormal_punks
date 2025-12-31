// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SigilLib.sol";
import "./HexLib.sol";

library BackgroundLib {
    uint256 internal constant N = 25;

    bytes32 internal constant PACK_BASE_0 =
        hex"ebab99d95763eb7d43facc7efb9e27e6c912d3e387a7d03abde89875db600000";
    bytes32 internal constant PACK_BASE_1 =
        hex"99e4e82ac9deaecaf8639bff5681d58983ec746fc7aa6edbedb2e5dd6cd90000";
    bytes32 internal constant PACK_BASE_2 =
        hex"ed77b4f9f9f955ddff666666afafe90000000000000000000000000000000000";

    bytes32 internal constant PACK_DARK_0 =
        hex"d6532e90212b9e4111ef9a09a05b03706209a5be2c59701b7ad1303799230000";
    bytes32 internal constant PACK_DARK_1 =
        hex"31c8d1126b76397dee0051e32245892a20d03833836b28a1d54bc2a4269f0000";
    bytes32 internal constant PACK_DARK_2 =
        hex"ca1b75b9b9b900aad42626264b4bce0000000000000000000000000000000000";

    function colorBase(uint256 i) internal pure returns (bytes3) {
        return _color(i, false);
    }

    function colorDark(uint256 i) internal pure returns (bytes3) {
        return _color(i, true);
    }

    function _color(uint256 i, bool dark) private pure returns (bytes3) {
        if (i >= N) revert("idx");

        bytes32 w;
        uint256 j;
        uint256 shift;

        if (i < 20) {
            uint256 p = i / 10; // 0 or 1
            j = i - p * 10; // 0..9
            shift = (9 - j) * 24 + 16;

            if (!dark) w = (p == 0) ? PACK_BASE_0 : PACK_BASE_1;
            else w = (p == 0) ? PACK_DARK_0 : PACK_DARK_1;
        } else {
            j = i - 20; // 0..4
            shift = (4 - j) * 24 + 136;
            w = dark ? PACK_DARK_2 : PACK_BASE_2;
        }

        return bytes3(uint24(uint256(w >> shift)));
    }

    function background(
        bytes32 h,
        uint256 i
    ) external pure returns (string memory) {
        bytes3 wall = colorBase(i);
        bytes3 floor = colorDark(i);

        bytes memory wallHex = HexLib.hex6(wall);
        bytes memory floorHex = HexLib.hex6(floor);

        return
            string(
                abi.encodePacked(
                    '<rect style="fill:#',
                    wallHex,
                    ';" id="wall" width="32" height="24" x="0" y="0" />',
                    '<rect style="fill:#',
                    floorHex,
                    ';" id="floor" width="32" height="8" x="0" y="24" />',
                    SigilLib.sigilPath(h, floorHex)
                )
            );
    }
}
