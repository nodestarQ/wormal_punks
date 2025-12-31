// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AccLib {
    string internal constant ELEMENT_0 =
        '<g> <path style="fill:#1a1a1a;" d="m 19,12 v 1 h -1 v 1 h 1 v 1 h 5 v -1 h 1 v -1 h -1 v -1 z" /> <path style="fill:#ff6600;" d="m 19,13 v 1 h 2 v -1 z" /> <path style="fill:#f9f9f9;" d="m 21,13 v 1 h 2 v -1 z" /> <path style="fill:#ff0000;" d="m 23,13 v 1 h 1 v -1 z" /> <path style="fill:#e6e6e6;" d="m 23,8 v 1 h 1 V 8 Z m 1,1 v 1 h 1 V 9 Z m 1,1 v 2 h 1 v -2 z m 0,2 h -1 v 1 h 1 z" /> </g>';
    string internal constant ELEMENT_1 =
        '<g> <path style="fill:#1a1a1a;" d="m 22,12 v 1 h -1 v 1 h -1 v -1 h -1 v 3 h 1 v 1 h 1 v 1 h 2 v -1 h 1 v -1 h 1 v -3 h -1 v -1 z" /> <path style="fill:#a05a2c;" d="m 18,13 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 1,1 v 1 h 2 v -1 h 1 v -1 -1 -1 h -2 v 1 1 1 z" /> <path style="fill:#deaa87;" d="m 22,14 v 1 h 2 v -1 z" /> <path style="fill:#cccccc;" d="m 24,9 v 2 h 1 V 9 Z m 0,2 h -1 v 1 h 1 z" /> </g>';
    string internal constant ELEMENT_2 =
        '<g> <path style="fill:#000000;" d="m 7,16 v 2 h 5 v 1 h 1 v -1 h 4 v -2 z" /> <path style="fill:#ff0000;" d="m 8,16 v 1 h 8 v -1 z" /> <path style="fill:#ffcc00;" d="m 12,17 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_3 =
        '<g> <path style="fill:#000000;" d="m 7,16 v 2 h 5 v 1 h 1 v -1 h 4 v -2 z" /> <path style="fill:#2a2aff;" d="m 8,16 v 1 h 8 v -1 z" /> <path style="fill:#ffcc00;" d="m 12,17 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_4 =
        '<g> <path style="fill:#000000;" d="m 7,16 v 2 h 5 v 1 h 1 v -1 h 4 v -2 z" /> <path style="fill:#ff2a7f;" d="m 8,16 v 1 h 8 v -1 z" /> <path style="fill:#f9f9f9;" d="m 12,17 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_5 =
        '<g> <path style="fill:#1a1a1a;" d="m 2,20 v 1 H 1 v 2 h 1 v 1 H 3 V 23 H 4 V 21 H 3 v -1 z" /> <path style="fill:#e6e6e6;" d="m 1,16 v 1 h 1 v -1 z m 0,1 H 0 v 1 h 1 z m 0,1 v 1 h 1 v -1 z m 0,1 H 0 v 1 h 1 z m 0,1 v 1 h 1 v -1 z" /> <path style="fill:#1a1a1a;" d="m 2,14 v 1 H 1 v 1 H 4 V 15 H 3 v -1 z" /> <path style="fill:#1a1a1a;" d="m 2,16 v 1 h 1 v 1 h 1 v 1 h 1 v 1 h 1 v 1 2 h 1 v 1 h 1 v 1 h 1 v 1 h 1 v -1 h 1 V 22 H 10 V 21 H 9 V 20 H 8 V 19 H 7 V 18 H 6 V 17 H 5 v -1 z" /> <path style="fill:#aa4400;" d="m 2,15 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z m 2,2 v 3 h 1 v -3 z" /> <path style="fill:#b3b3b3;" d="m 7,21 v 2 h 2 v -2 z" /> <path style="fill:#f9f9f9;" d="m 2,21 v 1 h 1 v -1 z" /> <path style="fill:#ff2a2a;" d="m 2,22 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_6 =
        '<g> <path style="fill:#1a1a1a;" d="m 4,24 v 1 H 3 v 1 H 2 v 3 h 1 v 1 h 1 v 1 h 5 v -1 h 1 v -1 h 1 V 26 H 10 V 25 H 9 v -1 z" /> <path style="fill:#ff6600;" d="m 4,25 v 1 H 3 v 3 h 1 v 1 h 5 v -1 h 1 V 26 H 9 v -1 z" /> <path style="fill:#1a1a1a;" d="m 6,25 v 2 H 5 V 26 H 4 v 1 H 3 v 1 h 1 v 1 h 1 v -1 h 1 v 2 h 1 v -2 h 1 v 1 h 1 v -1 h 1 V 27 H 9 V 26 H 8 v 1 H 7 v -2 z" /> </g>';
    string internal constant ELEMENT_7 =
        '<g> <path style="fill:#ff0000;" d="m 2,27 v 3 h 3 v -3 z" /> <path style="fill:#ffb380;" d="m 4,28 v 1 h 1 v -1 z" /> <path style="fill:#784421;" d="m 3,26 v 1 h 1 v -1 z" /> <path style="fill:#00aa44;" d="m 2,25 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_8 =
        '<g> <path style="fill:#a05a2c;" d="m 2,29 v 2 h 1 v 1 h 2 v -1 h 1 v -2 z" /> <path style="fill:#00aa44;" d="m 3,25 v 4 H 5 V 27 H 6 V 26 H 5 v -1 z" /> <path style="fill:#008033;" d="m 1,26 v 1 1 H 3 V 27 H 2 v -1 z" /> </g>';
    string internal constant ELEMENT_9 =
        '<g> <path style="fill:#1a1a1a;" d="m 2,27 v 2 1 h 2 v -1 h 1 v -2 z" /> <path style="fill:#b3b3b3;" d="m 3,27 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_10 =
        '<g> <path style="fill:#e6e6e6;" d="m 23,10 v 2 h 1 v -2 z" /> <path style="fill:#1a1a1a;" d="m 19,12 v 1 h -1 v 1 h 1 v 1 h 5 v -1 h 1 v -1 h -1 v -1 z" /> <path style="fill:#4d4d4d;" d="m 19,13 v 1 h 4 v -1 z" /> <path style="fill:#5599ff;" d="m 23,13 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_11 =
        '<g> <path style="fill:#e6e6e6;" d="m 23,10 v 2 h 1 v -2 z" /> <path style="fill:#1a1a1a;" d="m 19,12 v 1 h -1 v 1 h 1 v 1 h 5 v -1 h 1 v -1 h -1 v -1 z" /> <path style="fill:#4d4d4d;" d="m 19,13 v 1 h 4 v -1 z" /> <path style="fill:#ff5599;" d="m 23,13 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_12 =
        '<g> <path style="fill:#e6e6e6;" d="m 23,10 v 2 h 1 v -2 z" /> <path style="fill:#1a1a1a;" d="m 19,12 v 1 h -1 v 1 h 1 v 1 h 5 v -1 h 1 v -1 h -1 v -1 z" /> <path style="fill:#4d4d4d;" d="m 19,13 v 1 h 4 v -1 z" /> <path style="fill:#87deaa;" d="m 23,13 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_13 =
        '<g> <path style="fill:#f4e3d7;" d="m 3,29 v 2 h 1 v -2 z" /> <path style="fill:#e6e6e6;" d="m 2,26 v 1 H 1 v 1 1 H 6 V 28 27 H 5 v -1 z" /> <path style="fill:#ff0000;" d="m 3,26 v 1 H 2 1 v 2 h 1 v -1 h 1 v 1 H 5 6 V 27 H 5 v 1 H 4 v -1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_14 =
        '<g> <path style="fill:#803300;" d="m 1,30 v 1 h 5 v -1 z" /> <path style="fill:#ff6600;" d="m 3,27 v 1 H 2 v 1 1 H 5 V 29 H 4 v -1 -1 z" /> <path style="fill:#ffff00;" d="m 3,29 v 1 h 1 v -1 z" /> <path style="fill:#ff0000;" d="m 3,24 v 1 H 2 v 2 H 1 v 2 h 1 v -1 h 1 v -1 h 1 v 2 H 6 V 28 H 5 V 27 26 H 4 v -2 z" /> </g>';
    string internal constant ELEMENT_15 =
        '<g> <path style="fill:#ff6600;" d="m 2,26 v 1 1 h 1 v 1 H 4 V 28 H 5 V 27 26 H 4 3 Z" /> <path style="fill:#2ca02c;" d="m 2,23 v 1 h 1 v 2 H 4 V 25 H 5 V 24 H 4 V 23 H 3 Z" /> </g>';
    string internal constant ELEMENT_16 =
        '<g> <path style="fill:#ffff00;" d="m 4,26 v 1 H 3 v 3 h 1 v 1 h 1 v -1 -3 -1 z" /> <path style="fill:#803300;" d="m 4,25 v 1 h 1 v -1 z m 1,5 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_17 =
        '<g> <path style="fill:#ff6600;" d="m 2,27 v 1 h 2 v 2 h 1 v -2 -1 z" /> <path style="fill:#ffff00;" d="m 3,26 v 3 H 4 5 6 V 28 H 5 V 27 H 4 v -1 z" /> <path style="fill:#1a1a1a;" d="m 3,27 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_18 =
        '<g> <path style="fill:#ff6600;" d="m 2,27 v 1 h 2 v 2 h 1 v -2 -1 z" /> <path style="fill:#ff2a2a;" d="m 3,26 v 3 H 4 5 6 V 28 H 5 V 27 H 4 v -1 z" /> <path style="fill:#1a1a1a;" d="m 3,27 v 1 h 1 v -1 z" /> <path style="fill:#f9f9f9;" d="m 3,28 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_19 =
        '<g> <path style="fill:#ffaaaa;" d="m 3,26 v 1 H 1 v 1 h 1 v 1 1 h 1 v -1 h 1 v 1 h 1 v -1 0 H 6 V 28 H 4 v -2 z" /> <path style="fill:#b3b3b3;" d="m 2,27 v 2 h 3 v -2 z" /> <path style="fill:#1a1a1a;" d="m 2,27 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_20 =
        '<g> <path style="fill:#ffaaaa;" d="m 3,26 v 1 H 1 v 1 h 1 v 1 1 h 1 v -1 h 1 v 1 h 1 v -1 0 H 6 V 28 H 4 v -2 z" /> <path style="fill:#ececec;" d="m 2,27 v 2 h 3 v -2 z" /> <path style="fill:#1a1a1a;" d="m 2,27 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_21 =
        '<g> <path style="fill:#ff6600;" d="m 2,25 v 5 h 1 v -1 h 1 v 1 h 1 v -1 h 1 v 1 H 7 V 25 H 6 v 2 H 5 V 25 H 4 v 1 H 3 v -1 z" /> <path style="fill:#1a1a1a;" d="m 2,27 v 1 h 1 v -1 z m 2,0 v 1 h 1 v -1 z" /> <path style="fill:#1a1a1a;" d="m 6,25 v 1 h 1 v -1 z m -3,1 v 1 h 1 v -1 z m 2,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_22 =
        '<g> <path style="fill:#aca793;" d="m 2,25 v 5 h 1 v -1 h 1 v 1 h 1 v -1 h 1 v 1 H 7 V 25 H 6 v 2 H 5 V 25 H 4 v 1 H 3 v -1 z" /> <path style="fill:#1a1a1a;" d="m 2,27 v 1 h 1 v -1 z m 2,0 v 1 h 1 v -1 z" /> <path style="fill:#1a1a1a;" d="m 6,25 v 1 h 1 v -1 z m -3,1 v 1 h 1 v -1 z m 2,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_23 =
        '<g> <path style="fill:#333333;" d="m 2,25 v 5 h 1 v -1 h 1 v 1 h 1 v -1 h 1 v 1 H 7 V 25 H 6 v 2 H 5 V 25 H 4 v 1 H 3 v -1 z" /> <path style="fill:#37c837;" d="m 2,27 v 1 h 1 v -1 z m 2,0 v 1 h 1 v -1 z" /> <path style="fill:#1a1a1a;" d="m 6,25 v 1 h 1 v -1 z m -3,1 v 1 h 1 v -1 z m 2,1 v 1 h 1 v -1 z m 1,1 v 1 h 1 v -1 z" /> </g>';
    string internal constant ELEMENT_24 =
        '<g> <path style="fill:#ff2929;" d="m 9,12 v 1 h 1 v -1 z m 1,1 v 1 h 2 v 1 h 1 v 1 h 1 v 1 h 2 v -1 h 1 v -1 h 1 v -1 h 1 v -1 h -8 z" /> </g>';
    string internal constant ELEMENT_25 =
        '<g> <path style="fill:#0044aa;" d="m 9,12 v 1 h 1 v -1 z m 1,1 v 1 h 2 v 1 h 1 v 1 h 1 v 1 h 2 v -1 h 1 v -1 h 1 v -1 h 1 v -1 h -8 z" /> </g>';
    string internal constant ELEMENT_26 =
        '<g> <path style="fill:#800080;" d="m 9,12 v 1 h 1 v -1 z m 1,1 v 1 h 2 v 1 h 1 v 1 h 1 v 1 h 2 v -1 h 1 v -1 h 1 v -1 h 1 v -1 h -8 z" /> </g>';

    function acc(uint256 i) external pure returns (string memory) {
        if (i == 0) return ELEMENT_0;
        if (i == 1) return ELEMENT_1;
        if (i == 2) return ELEMENT_2;
        if (i == 3) return ELEMENT_3;
        if (i == 4) return ELEMENT_4;
        if (i == 5) return ELEMENT_5;
        if (i == 6) return ELEMENT_6;
        if (i == 7) return ELEMENT_7;
        if (i == 8) return ELEMENT_8;
        if (i == 9) return ELEMENT_9;
        if (i == 10) return ELEMENT_10;
        if (i == 11) return ELEMENT_11;
        if (i == 12) return ELEMENT_12;
        if (i == 13) return ELEMENT_13;
        if (i == 14) return ELEMENT_14;
        if (i == 15) return ELEMENT_15;
        if (i == 16) return ELEMENT_16;
        if (i == 17) return ELEMENT_17;
        if (i == 18) return ELEMENT_18;
        if (i == 19) return ELEMENT_19;
        if (i == 20) return ELEMENT_20;
        if (i == 21) return ELEMENT_21;
        if (i == 22) return ELEMENT_22;
        if (i == 23) return ELEMENT_23;
        if (i == 24) return ELEMENT_24;
        if (i == 25) return ELEMENT_25;
        if (i == 26) return ELEMENT_26;

        revert("acc idx");
    }
}
