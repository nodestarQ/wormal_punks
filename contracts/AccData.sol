// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library AccData {
    function traits(uint256 i) external pure returns (string memory) {
        if (i == 0) return "Cigarette";
        if (i == 1) return "Pipe";
        if (i == 2) return "Collar Red";
        if (i == 3) return "Collar Blue";
        if (i == 4) return "Collar Pink";
        if (i == 5) return "Rog";
        if (i == 6) return "Ball";
        if (i == 7) return "Apple";
        if (i == 8) return "Cactus";
        if (i == 9) return "Floppy Disk";
        if (i == 10) return "Vape Blue";
        if (i == 11) return "Vape Red";
        if (i == 12) return "Vape Green";
        if (i == 13) return "Mushroom";
        if (i == 14) return "Fire";
        if (i == 15) return "Root";
        if (i == 16) return "Banana";
        if (i == 17) return "Chick";
        if (i == 18) return "Bullfinch";
        if (i == 19) return "Sewer Rat";
        if (i == 20) return "Lab Rat";
        if (i == 21) return "Orange Cat";
        if (i == 22) return "Grey Cat";
        if (i == 23) return "Black Cat";
        if (i == 24) return "Face Mask Red";
        if (i == 25) return "Face Mask Blue";
        if (i == 26) return "Face Mask Purple";
        if (i == 27) return "None";

        revert("acc idx");
    }
}
