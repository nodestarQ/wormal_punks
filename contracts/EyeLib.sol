// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library EyeLib {
    uint256 internal constant N_EYES = 42;

    string internal constant ELEMENT_0 =
        '5fbcd3" d="m13 11v3h1v-3zm5 0v2h1v-2z"/><path fill="#000" d="m13 10v1h2v-1zm5 0v1h2v-1z';

    string internal constant ELEMENT_1 =
        'f9f9f9" d="m14 10v1h1v-1zm5 0v1h1v-1z"/><path fill="#000" d="m15 9v1h1V9Zm2 0v1h1V9Zm1 1v1h1v-1zm-5 0v1h1v-1z';

    string internal constant ELEMENT_2 =
        '000" d="m9 10v2h2v1h2v-1h2v1h2v-1h2v-2z"/><path fill="#f9f9f9" d="m12 11v1h1v-1zm4 0v1h1v-1z"/><path fill="#2ac9de" d="m11 11v1h1v-1zm4 0v1h1v-1z';

    string internal constant ELEMENT_3 = '000" d="m12 11v2h1v-2zm4 0v2h1v-2z';

    string internal constant ELEMENT_4 =
        'f9f9f9" d="m11 10v2h2v-2zm4 0v2h2v-2z"/><path fill="#000" d="m12 10v1h1v-1zm4 0v1h1v-1z';

    string internal constant ELEMENT_5 = '000" d="m11 11v1h1v-1zm5 0v1h1v-1z';

    string internal constant ELEMENT_6 =
        '000" d="m12 10v2h2v-2zm4 0v2h2v-2z"/><path fill="#f9f9f9" d="m11 10v2h1v-2zm4 0v2h1v-2z';

    string internal constant ELEMENT_7 =
        '000" d="m9 10v1h2v1h2v-1h2v1h2v-1h2v-1z"/><path fill="#f9f9f9" d="m12 10v1h1v-1zm4 0v1h1v-1z';

    string internal constant ELEMENT_8 =
        '000" d="m11 10v1h1v-1zm1 1v1h1v-1zm0 1h-1v1h1zm4-2v1h1v-1zm0 1h-1v1h1zm0 1v1h1v-1z';

    string internal constant ELEMENT_13 =
        '000" d="m9 10v1h3v1h1v-1h2v1h2v-1h2v-1z"/><path fill="#f9f9f9" d="m11 11v1h1v-1z';

    string internal constant ELEMENT_14 =
        '000" d="m10.997619 10v1h1v-1zm1 1v1h1v-1zm-1 0H9.9976191v1h1zm5.002381  -1v1h1v-1zm1 1v1h1v-1zm-1 0h-1v1h1z';

    string internal constant ELEMENT_15 =
        'f9f9f9" d="m11 11v1h1v-1zm4 0v1h1v-1z"/><path fill="#000" d="m10 10v1h2v1h1v-1h3v1h1v-1h1v-1h-7z';

    string internal constant ELEMENT_16 = '000" d="m15 10v2h2v-2zm-4 1v1h2v-1z';

    string internal constant ELEMENT_17 =
        '000" width="1" height="2" x="10" y="11"/><rect fill="#000" width="1" height="2" x="17" y="11';

    string internal constant ELEMENT_18 =
        '000" width="3" height="1" x="10" y="11"/><rect fill="#000" width="3" height="1" x="15" y="11"/><rect fill="#f9f9f9" width="3" height="1" x="10" y="12"/><rect fill="#f9f9f9" width="3" height="1" x="15" y="12"/><rect fill="#000" width="1" height="1" x="12" y="12"/><rect fill="#000" width="1" height="1" x="15" y="12';

    string internal constant ELEMENT_19 =
        '000" d="m12 10.5v2h1v-2zm3 0v2h1v-2z"/><path fill="#ff5555" d="m11 11.5v1h1v-1zm5 0v1h1v-1z';

    string internal constant ELEMENT_20 =
        'ff0000" width="2" height="1" x="12" y="11"/><rect fill="#00ccff" width="2" height="1" x="16" y="11"/><path fill="#f9f9f9" d="m9 10v1h1v1h1v1h8v-3zm3 1h2v1h-2zm4 0h2v1h-2z';

    string internal constant ELEMENT_24 =
        '000" d="m11 10v1H9v1h2v1h2v-1h2v1h2v-1h2v-1h-2v-1h-2v1h-2v-1z"/><path fill="#2ad4ff" d="m11 11v1h2v-1zm4 0v1h2v-1z';

    string internal constant ELEMENT_25 =
        '000" d="m11 10v1h2v-1zm4 0v1h2v-1zm-4 2v1h2v-1zm4 0v1h2v-1z"/><path fill="#f9f9f9" d="m12 12v1h1v-1zm4 0v1h1v-1z';

    string internal constant ELEMENT_31 =
        '333" width="1" height="1" x="12" y="11"/><rect fill="#f9f9f9" width="1" height="1" x="11" y="11"/><rect fill="#000" width="2" height="1" x="11" y="10"/><rect fill="#00ccff" width="2" height="2" x="15" y="10"/><rect fill="#000" width="1" height="3" x="17" y="11"/><rect fill="#f9f9f9" width="1" height="1" x="15" y="10';

    string internal constant ELEMENT_32 =
        'f9f9f9" d="m10 10v2h1v1h2v-1h1v-2zm5 0v2h1v1h2v-1h1v-2z"/><path fill="#000" d="m11 10v2h2v-2zm5 0v2h2v-2z';

    string internal constant ELEMENT_36 =
        '000" d="m12 10v1h-1v1h6v-1h-1v-1z"/><path fill="#f9f9f9" d="m12 11v1h1v-1zm1 1v1h2v-1zm2 0h1v-1h-1z';

    string internal constant ELEMENT_37 =
        '784421" width="10" height="2" x="9" y="10"/><path fill="#31b0d0" d="m12 10v2h2v-2zm5 0v2h2v-2z"/><path fill="#f9f9f9" d="m12 10v1h1v-1zm5 0v1h1v-1z';

    string internal constant ELEMENT_38 =
        '000" d="m9 10v1h1v1h3v-1h2v1h3v-1h1v-1z"/><path fill="#f9f9f9" d="m11 10v1h2v-1zm5 0v1h2v-1z';

    function visual(uint256 i) external pure returns (string memory) {
        if (i >= N_EYES) revert("eye idx");

        if (i == 0) return encodeWithTransform(ELEMENT_0);
        if (i == 1) return encodeWithTransform(ELEMENT_1);
        if (i == 2) return encodeWithPath(ELEMENT_2);
        if (i == 3) return encodeWithPath(ELEMENT_3);
        if (i == 4) return encodeWithPath(ELEMENT_4);
        if (i == 5) return encodeWithPath(ELEMENT_5);
        if (i == 6) return encodeWithPath(ELEMENT_6);
        if (i == 7) return encodeWithPath(ELEMENT_7);
        if (i == 8) return encodeWithPath(ELEMENT_8);

        if (i >= 9 && i <= 12) return _eye9to12(_eye9to12VisorColor(i));

        if (i == 13) return encodeWithPath(ELEMENT_13);
        if (i == 14) return encodeWithPath(ELEMENT_14);
        if (i == 15) return encodeWithPath(ELEMENT_15);
        if (i == 16) return encodeWithPath(ELEMENT_16);
        if (i == 17) return encodeWithRect(ELEMENT_17);
        if (i == 18) return encodeWithRect(ELEMENT_18);
        if (i == 19) return encodeWithPath(ELEMENT_19);
        if (i == 20) return encodeWithRect(ELEMENT_20);

        if (i >= 21 && i <= 23) return _eye21to23(_eye21to23PupilColor(i));

        if (i == 24) return encodeWithPath(ELEMENT_24);
        if (i == 25) return encodeWithPath(ELEMENT_25);

        if (i >= 26 && i <= 30) return _eye26to30(_eye26to30Accent(i));

        if (i == 31) return encodeWithRect(ELEMENT_31);
        if (i == 32) return encodeWithPath(ELEMENT_32);

        if (i >= 33 && i <= 35) return _eye33to35(_eye33to35Accent(i));

        if (i == 36) return encodeWithPath(ELEMENT_36);
        if (i == 37) return encodeWithRect(ELEMENT_37);
        if (i == 38) return encodeWithPath(ELEMENT_38);

        if (i >= 39 && i <= 41) {
            (
                string memory irisDark,
                string memory irisLight
            ) = _eye39to41IrisPair(i);
            return _eye39to41(irisDark, irisLight);
        }

        revert("idx");
    }

    function encodeWithTransform(
        string memory input
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g transform="translate(-2,1)"><path fill="#',
                    input,
                    '"/></g>'
                )
            );
    }

    function encodeWithPath(
        string memory input
    ) internal pure returns (string memory) {
        return string(abi.encodePacked('<g><path fill="#', input, '"/></g>'));
    }

    function encodeWithRect(
        string memory input
    ) internal pure returns (string memory) {
        return string(abi.encodePacked('<g><rect fill="#', input, '"/></g>'));
    }

    function _eye9to12(
        string memory visor
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<g>",
                    '<rect fill="#',
                    visor,
                    '" width="2" height="1" x="11" y="11"/>',
                    '<rect fill="#b7c4c8" width="2" height="2" x="9" y="10"/>',
                    '<rect fill="#000" width="1" height="1" x="16" y="11"/>',
                    '<rect fill="#f9f9f9" width="1" height="1" x="15" y="11"/>',
                    "</g>"
                )
            );
    }

    function _eye9to12VisorColor(
        uint256 i
    ) private pure returns (string memory) {
        if (i == 9) return "ff0000";
        if (i == 10) return "ff5500";
        if (i == 11) return "0000ff";
        return "00ff00";
    }

    function _eye21to23(
        string memory pupil
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<g>",
                    '<path fill="#f9f9f9" d="m10 11v1h3v-1zm5 0v1h3v-1z"/>',
                    '<path fill="#000" d="m11 10v3h1v-3zm5 0v3h1v-3z"/>',
                    '<path fill="#',
                    pupil,
                    '" d="m11 11v1h1v-1zm5 0v1h1v-1z"/>',
                    "</g>"
                )
            );
    }

    function _eye21to23PupilColor(
        uint256 i
    ) private pure returns (string memory) {
        if (i == 21) return "00ccff";
        if (i == 22) return "ff0000";
        return "00ff00";
    }

    function _eye26to30(
        string memory accent
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<g>",
                    '<path fill="#000" d="m11 10v1h-1v1h3v-2zm4 0v2h3v-1h-1v-1z"/>',
                    '<path fill="#f9f9f9" d="m11 11v1h1v-1zm4 0v1h1v-1z"/>',
                    '<path fill="#',
                    accent,
                    '" d="m12 11v1h1v-1zm4 0v1h1v-1z"/>',
                    "</g>"
                )
            );
    }

    function _eye26to30Accent(uint256 i) private pure returns (string memory) {
        if (i == 26) return "d95763";
        if (i == 27) return "75db60";
        if (i == 28) return "2ac9de";
        if (i == 29) return "aa6edb";
        return "ed77b4";
    }

    function _eye33to35(
        string memory accent
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<g>",
                    '<path fill="#000" d="m10 10v1H9v3h2v-1h1v-1h1v-1h-1v-1zm6 0v1h-1v1h1v1h1v1h2v-3h-1v-1z"/>',
                    '<path fill="#f9f9f9" d="m10 11v1h2v-1zm6 0v1h2v-1z"/>',
                    '<path fill="#',
                    accent,
                    '" d="m11 11v1h1v-1zm6 0v1h1v-1z"/>',
                    "</g>"
                )
            );
    }

    function _eye33to35Accent(uint256 i) private pure returns (string memory) {
        if (i == 33) return "ff0000";
        if (i == 34) return "00ff00";
        return "00ccff";
    }

    function _eye39to41(
        string memory irisDark,
        string memory irisLight
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<g>",
                    '<path fill="#000" d="m9 10v1h4v-1zm6 0v1h4v-1z"/>',
                    '<path fill="#f9f9f9" d="m10 11v2h1v-2zm7 0v2h1v-2z"/>',
                    '<path fill="#',
                    irisDark,
                    '" d="m11 11v2h2v-1h-1v-1zm4 0v2h2v-1h-1v-1z"/>',
                    '<path fill="#',
                    irisLight,
                    '" d="m12 11v1h1v-1zm4 0v1h1v-1z"/>',
                    "</g>"
                )
            );
    }

    function _eye39to41IrisPair(
        uint256 i
    ) private pure returns (string memory irisDark, string memory irisLight) {
        if (i == 39) return ("784421", "c87137");
        if (i == 40) return ("217821", "37c837");
        return ("0088aa", "00ccff");
    }
}
