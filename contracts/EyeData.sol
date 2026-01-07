// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library EyeData {
    string internal constant ELEMENT_0 = "Weeping"; //3
    string internal constant ELEMENT_1 = "Paranoid"; //3
    string internal constant ELEMENT_2 = "Masked"; //1
    string internal constant ELEMENT_3 = "Neutral"; //7
    string internal constant ELEMENT_4 = "Skeptical"; //6
    string internal constant ELEMENT_5 = "Flat"; //7
    string internal constant ELEMENT_6 = "Dilated"; //4
    string internal constant ELEMENT_7 = "Shielded"; //4
    string internal constant ELEMENT_8 = "Overstimulated"; //3
    string internal constant ELEMENT_9 = "Visor (Red)"; //1
    string internal constant ELEMENT_10 = "Visor (Orange)"; //1
    string internal constant ELEMENT_11 = "Visor (Blue)"; //1
    string internal constant ELEMENT_12 = "Visor (Green)"; //1
    string internal constant ELEMENT_13 = "Eye Patch"; //1
    string internal constant ELEMENT_14 = "Satisfied"; //6
    string internal constant ELEMENT_15 = "Primitive"; //6
    string internal constant ELEMENT_16 = "Wink"; //1
    string internal constant ELEMENT_17 = "Absent"; //7
    string internal constant ELEMENT_18 = "Crossed"; //6
    string internal constant ELEMENT_19 = "Shy"; //6
    string internal constant ELEMENT_20 = "3D Glasses"; //0.5
    string internal constant ELEMENT_21 = "Mime (Blue)"; //1
    string internal constant ELEMENT_22 = "Mime (Red)"; //1
    string internal constant ELEMENT_23 = "Mime (Green)"; //1
    string internal constant ELEMENT_24 = "Glasses"; //3
    string internal constant ELEMENT_25 = "Observing"; //3
    string internal constant ELEMENT_26 = "Lined (Red)"; //1
    string internal constant ELEMENT_27 = "Lined (Green)"; //1
    string internal constant ELEMENT_28 = "Lined (Blue)"; //1
    string internal constant ELEMENT_29 = "Lined (Purple)"; //1
    string internal constant ELEMENT_30 = "Lined (Pink)"; //1
    string internal constant ELEMENT_31 = "Monocle"; //0.75
    string internal constant ELEMENT_32 = "Bug Eyed"; //1
    string internal constant ELEMENT_33 = "Corpse Paint (Red)"; //1
    string internal constant ELEMENT_34 = "Corpse Paint (Green)"; //1
    string internal constant ELEMENT_35 = "Corpse Paint (Blue)"; //1
    string internal constant ELEMENT_36 = "Cyclops"; //0.25
    string internal constant ELEMENT_37 = "Goggles"; //0.5
    string internal constant ELEMENT_38 = "Sunglasses"; //2
    string internal constant ELEMENT_39 = "Hopeful (Brown)"; //1
    string internal constant ELEMENT_40 = "Hopeful (Green)"; //1
    string internal constant ELEMENT_41 = "Hopeful (Blue)"; //1

    function traits(uint256 i) external pure returns (string memory) {
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
        if (i == 27) return ELEMENT_27;
        if (i == 28) return ELEMENT_28;
        if (i == 29) return ELEMENT_29;
        if (i == 30) return ELEMENT_30;
        if (i == 31) return ELEMENT_31;
        if (i == 32) return ELEMENT_32;
        if (i == 33) return ELEMENT_33;
        if (i == 34) return ELEMENT_34;
        if (i == 35) return ELEMENT_35;
        if (i == 36) return ELEMENT_36;
        if (i == 37) return ELEMENT_37;
        if (i == 38) return ELEMENT_38;
        if (i == 39) return ELEMENT_39;
        if (i == 40) return ELEMENT_40;
        if (i == 41) return ELEMENT_41;

        revert("eye idx");
    }
}
