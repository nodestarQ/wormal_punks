// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library PseudoRandomness {
    uint16 internal constant TOTAL = 10_000;

    uint256 internal constant EYE_LEN = 42;
    uint256 internal constant BODY_LEN = 43;
    uint256 internal constant ACCESSORY_LEN = 28;
    uint256 internal constant BACKGROUND_LEN = 26;
    uint256 internal constant HEAD_LEN = 100;

    bytes internal constant EYE_CDF =
        hex"012c025802bc057807d00a8c0c1c0dac0ed80f3c0fa01004106810cc1324157c15e0189c1af41d4c1d7e1de21e461eaa1fd62102216621ca222e229222f6234123a52409246d24d124ea251c25e4264826ac2710";

    bytes internal constant BODY_CDF =
        hex"012c0258038404b005dc0708083409600a8c0bb80ce40e100f3c1068119412c013ec151816441770189c19c81af41c201d4c1e781fa420d02198229222f6238c2422248624ea254e25b22616267a269326ac26de2710";

    bytes internal constant ACCESSORY_CDF =
        hex"0064007d00e1014501a901c2020d03390465052d05f506bd078508b109dd0aa50b6d0c350cfd0dc50e8d0f55101d10e511c612a713882710";

    bytes internal constant BACKGROUND_CDF =
        hex"0190032004b0064007d009600af00c800e100fa0113012c01450151816a8183819c81b581ce81e7820082198232824b826482710";

    bytes internal constant HEAD_CDF =
        hex"006400c8012c019001c20226025802bc03200352038403b603cf0433049704fb055f059105aa05dc060e06400659068b06bd06d607080712077607da083e08a20906096a09ce0a320a960afa0b2c0b5e0b770b810bb30bbd0c210c850ce90d4d0d7f0db10dca0e2e0e380e420e740ebf0ed80f0a0f550fa00feb104f10b31117117b11df124312a7130b136f13d3140514371469149b14cd14ff156315c7162b168f16f31725178917ed185118b51919196419af19c81a2c1a901af41b581bbc1bee1c071c202710";

    function pickEyeTrait(bytes32 h) internal pure returns (uint256) {
        uint256 r = uint256(h) % TOTAL;
        return _pickPacked(r, EYE_CDF, EYE_LEN);
    }

    function pickBodyTrait(bytes32 h) internal pure returns (uint256) {
        uint256 r = uint256(h) % TOTAL;
        return _pickPacked(r, BODY_CDF, BODY_LEN);
    }

    function pickAccessoryTrait(bytes32 h) internal pure returns (uint256) {
        uint256 r = uint256(h) % TOTAL;
        return _pickPacked(r, ACCESSORY_CDF, ACCESSORY_LEN);
    }

    function pickBackgroundTrait(bytes32 h) internal pure returns (uint256) {
        uint256 r = uint256(h) % TOTAL;
        return _pickPacked(r, BACKGROUND_CDF, BACKGROUND_LEN);
    }

    function pickHeadTrait(bytes32 h) internal pure returns (uint256) {
        uint256 r = uint256(h) % TOTAL;
        return _pickPacked(r, HEAD_CDF, HEAD_LEN);
    }

    function _pickPacked(
        uint256 r,
        bytes memory packed,
        uint256 len
    ) private pure returns (uint256) {
        uint256 lo = 0;
        uint256 hi = len;

        while (lo < hi) {
            uint256 mid = (lo + hi) >> 1;
            uint16 v = _u16At(packed, mid);
            if (r < v) hi = mid;
            else lo = mid + 1;
        }
        return lo;
    }

    function _u16At(
        bytes memory packed,
        uint256 i
    ) private pure returns (uint16 v) {
        uint256 o = i * 2;
        assembly {
            let data := add(packed, 0x20)
            let word := mload(add(data, o))
            v := shr(240, word)
        }
    }
}
