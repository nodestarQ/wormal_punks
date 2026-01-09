// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Metadata for pre reveal state of the NFTs

library PreReveal {
    function tokenURIPreReveal(
        uint256 tokenId
    ) external pure returns (string memory) {
        string memory image = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(
                    bytes(
                        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><g style="fill:#d7eef4"><rect style="fill:#cccccc;" id="rect28" width="32" height="32" x="0" y="0" /><rect style="fill:#999999;" width="32" height="8" x="0" y="-32" transform="scale(1,-1)"/></g><g id="layer39"><path style="fill:#f9f9f9;" d="m 24,4 v 1 h 3 V 4 Z m 3,1 v 2 h 1 V 5 Z m 0,2 h -1 v 1 h 1 z m -1,1 h -1 v 1 h 1 z M 24,5 h -1 v 1 h 1 z m 1,5 v 1 h 1 v -1 z" /></g><g style="fill:#1a1a1a"><path style="fill:#1a1a1a;" d="M 11,7 V 8 H 10 V 9 H 9 v 1 H 8 v 7 H 7 v 1 H 6 v 4 h 1 v 1 h 1 v 2 1 h 1 v 2 h 1 v 1 h 1 v 1 h 9 v -1 h 1 v -1 h 1 v -1 h 1 v -1 h 2 v 1 h 3 v -1 h 1 v -1 h -1 v -1 h -1 v -2 h -1 v -1 h -1 v -1 h -4 v 1 h -1 v 1 h -1 v 1 h -1 v 1 h -2 v -1 h 1 v -1 h 1 v -4 h -1 v -1 h -1 v -2 h 3 v -1 h 1 V 10 H 19 V 9 H 18 V 8 H 17 V 7 Z"/><path style="fill:#ffffff;fill-opacity:0.75;" d="m 11,8 v 1 h 6 V 8 Z m 0,1 h -1 v 1 h 1 z m -1,1 H 9 v 7 h 1 z m -3,8 v 1 3 h 1 v -3 h 9 v -1 z m 14,3 v 1 h 4 v -1 z m 0,1 h -1 v 1 h 1 z m -1,1 h -1 v 1 h 1 z m -1,1 h -1 v 1 h 1 z M 9,23 v 3 h 1 v -3 z m 1,3 v 2 h 1 v -2 z m 1,2 v 1 h 1 v -1 z"/></g></svg>'
                    )
                )
            )
        );

        bytes memory attrs = abi.encodePacked(
            "[",
            '{"trait_type":"Hidden","value":"true"}',
            "]"
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
            attrs,
            "}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(json)
                )
            );
    }
}
