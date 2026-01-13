// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./seadrop/ERC721SeaDrop.sol";
import "./seadrop/interfaces/ISeaDropTokenContractMetadata.sol";
import "./Display.sol";
import "./PreReveal.sol";
import "./Special.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

//
//        ::    --         -+          .::.:       :-
//     .-&░▒+:  &▓%:     :*▒░#%*&%#%:  :▒▒▒▓:   .-%░@*++++*++&░@#&%%&+:
//   .+#▓████▒&--██▒+   +▒█▓#███████▓@+.@███-  =@▓█@*█████████░▓██████▒%-
//  -@▓███#▒███▓░#██▓- -#██%*███░&@████@@███-  -███%-███▒@&##%.████@▓████&:
//  *@██@: .+@██@:███▓-#███.*███%  =░██▓░███:  -███%=▓██&      ▒██▓ .%▒███#
//  &███%     :-  :▓██▒███* *███&*%░███▒░███%*%%▓██%=▓██#=*@*. ████-+▒████*
//  +@██%          +█████*  *████████#=.#██████████*-███████@.=▓███▓███▒*:
//  *███%           %███%   *███#&&*.   ░███%**&███%=███▒░▓&:  ▒██████▒.
//  +███%    :++.   %███+   *███-       @███-  -███%=███#      ▒██▒@███░.
//  *███▓%.:&░██▒-  *▓██+   %███-       #███*  -███&=███#+=++-.░██░ +███░-
//  .&████@░███▓&.  &███=   @█▒%.        :%█*  .+▒█@=█████████#▓░=.  :▒██▒+
//   +-%▓████▒%.    %█▓=-= .@#=.   -++===--:. =-..*#+█▒%%%%&#@▓@-  :==.%▒█&
//   &▓*:*▓▒+.      +▓+#▓-:+@▓█░=. .▒█████▓▒+:-░▒+-..:.    :+@@. :+@██░*:%&
//   .░██&-   +░    =@▓█%%░██████▒%:#████████░&-▓█▓░:   .-&▒█░ -%▒██████▓*.
//    *███░.  #█+  =███▒@███%-=░███&&███-.#████@▓███▓=..%▓███#%████@+@████%
//     ░███= *▓█▓. ░███+▒██▒   -███%&███=:+░███@▓█████##█████#%███*.  -#@&-
//     *███@:░███#:████.▒██▒   -███&&████▓███▒*.▓████████████&+████▒&%-
//     .░██▓@█████@███* ▒██▒   -███&%███████+   ▓███░████#███& .%██████@=
//      +██████░█████▒  ▒███= .+▓██%%███@███▓-  ███▓.#██*-███#   .*%@████░=
//      .▒████@-█████*  +▒███@%#&&#=&███-=▓███% ▓██▓  *= =███&.-=--: -░███&
//       #████- @████:   .&░&:-@%@::=:+#=::▓███%▓██▒   .-=▒▓@#&&+░#░:=&███&
//       :▓██@. =███&     *=&██▒@▓██@#======▒█+&█▓+  :-+=-###░█▓▒█▓▓█▓███▒=
//        @█▓:   &██-     @@█▒-  .-=#░█▓@%-:**..%:.-+-+%#█▓░&%:*▒██████▒=.
//        .░▓    *█=      @▒▓:        :%▒█▒*:=-*--%.+&#█▒*:      -#██&=
//         :+    -+       .-:           :=#██▓░░+*@▓██@+           ::
//                                         :=&#▒▒▒▒&+-
//                                                       Privacy is Wormal

/// @title CypherWorms - Privacy-Focused NFT Collection with Evolution Mechanics
/// @author CypherWorms Team
/// @notice An NFT collection with holding-based evolution, transfer protection, and special 1/1 variants
/// @dev Optimized for gas efficiency with packed storage (1 slot per token vs 5 slots)
contract CypherWorms is ERC721SeaDrop {
    /// @notice Token metadata packed into a single storage slot for gas efficiency
    /// @dev Reduces storage from 5 slots per token to 1 slot (32 bytes total)
    /// @dev Total size: 23 + 5 + 2 + 1 + 1 = 32 bytes (exactly one storage slot)
    struct TokenData {
        /// @dev DNA hash (23 bytes = 2^184 entropy, re-hashed with wormSecret in tokenURI)
        bytes23 dna;
        /// @dev Timestamp of last transfer or mint (uint40 valid until year ~36,000)
        uint40 holdCount;
        /// @dev Special variant index (0-5) for special 1/1 tokens
        uint16 specialVariant;
        /// @dev Whether this token is a special 1/1
        bool isSpecialToken;
        /// @dev One-time protection flag (consumed on next transfer to preserve hold count)
        bool transferProtection;
    }

    /// @notice Maximum supply of tokens (owner reserve 750 + strategic 225 + public 6,528)
    uint256 constant MAX_SUPPLY = 7503;

    /// @notice Display contract for rendering token metadata and artwork
    Display public displayContract;
    
    /// @notice Reveal secret and mint flags packed into single slot for gas efficiency
    /// @dev Total: 30 + 1 + 1 = 32 bytes (one storage slot, was 3 slots)
    /// @dev Reveal secret with 2^240 entropy (cryptographically secure)
    bytes30 public wormSecret;
    /// @dev Whether owner reserve mint (750 tokens) has been used
    bool public ownerMinted;
    /// @dev Whether strategic mint (225 tokens) has been used
    bool public strategicMinted;
    
    /// @notice Token metadata storage (1 slot per token)
    /// @dev Maps token ID to packed TokenData struct
    mapping(uint256 => TokenData) private tokens;

    /// @notice Transfer protection payment settings packed into single slot
    /// @dev Total: 20 + 12 = 32 bytes (one storage slot, was 2 slots)
    /// @dev ERC20 token for payment (address(0) for ETH)
    address public transferProtectionToken;
    /// @dev Base price for level 0 protection (supports up to 79B tokens @ 18 decimals)
    uint96 public transferProtectionBasePrice;

    /// @notice Single payment recipient (can be EOA or splitter contract for custom distribution)
    address public paymentRecipient;
    
    /// @notice Pending ETH withdrawals (pull pattern for gas efficiency)
    /// @dev Only paymentRecipient accumulates balance, calls withdraw() to claim
    mapping(address => uint256) public pendingWithdrawals;

    /// @notice Array of 6 special token IDs (set during reveal via adminSetWormSecret)
    uint256[6] public specialTokenIds;

    // EVENTS
    
    /// @notice Emitted when a token's DNA is generated during minting
    /// @param tokenId The token ID that received DNA
    /// @param dna The full 32-byte DNA hash (stored as bytes23, emitted as bytes32)
    event DNAGenerated(uint256 indexed tokenId, bytes32 dna);
    
    /// @notice Emitted when the reveal secret is set (one-time operation)
    /// @param secret The reveal secret (bytes32, stored as bytes30)
    event WormSecretSet(bytes32 secret);
    
    /// @notice Emitted when a token's hold count is reset due to unprotected transfer
    /// @param tokenId The token ID whose hold count was reset
    event HoldCountReset(uint256 indexed tokenId);
    
    /// @notice Emitted when a token transfer is protected from hold count reset
    /// @param tokenId The token ID that was protected
    /// @param level The current evolution level of the token (0-8)
    /// @param pricePaid The amount paid for protection (ETH or ERC20)
    event TransferProtected(
        uint256 indexed tokenId,
        uint256 level,
        uint256 pricePaid
    );
    
    /// @notice Emitted when the transfer protection base price is updated
    /// @param newBasePrice The new base price in wei (or token units if ERC20)
    event TransferProtectionPriceUpdated(uint256 newBasePrice);
    
    /// @notice Emitted when the transfer protection payment token is updated
    /// @param token The new payment token address (address(0) for ETH)
    event TransferProtectionTokenUpdated(address indexed token);
    
    /// @notice Emitted when ETH payment is received (protection fees or royalties)
    /// @param from The address that sent the payment
    /// @param amount The amount of ETH received
    event PaymentReceived(address indexed from, uint256 amount);
    
    /// @notice Emitted when ETH is withdrawn from pending balance
    /// @param recipient The address that withdrew funds
    /// @param amount The amount withdrawn
    event PaymentWithdrawn(address indexed recipient, uint256 amount);
    
    /// @notice Emitted when accidentally sent ERC20 tokens are recovered
    /// @param token The ERC20 token that was recovered
    /// @param recipient The address that received the recovered tokens
    /// @param amount The amount of tokens recovered
    event ERC20Recovered(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );
    
    /// @notice Emitted when ERC20 payment is processed for transfer protection
    /// @param token The ERC20 token used for payment
    /// @param from The address that paid
    /// @param amount The amount of tokens paid
    event ERC20PaymentProcessed(
        address indexed token,
        address indexed from,
        uint256 amount
    );
    
    /// @notice Emitted when the payment recipient is updated
    /// @param oldRecipient The previous payment recipient
    /// @param newRecipient The new payment recipient
    event PaymentRecipientUpdated(
        address indexed oldRecipient,
        address indexed newRecipient
    );
    
    /// @notice Emitted when owner performs reserve mint (one-time, max 750 tokens)
    /// @param recipient The address that received the minted tokens
    /// @param quantity The number of tokens minted
    event OwnerMint(address indexed recipient, uint256 quantity);
    
    /// @notice Emitted when strategic mint is performed (one-time, max 225 tokens)
    /// @param recipient The address that received the minted tokens
    /// @param quantity The number of tokens minted
    event StrategicMint(address indexed recipient, uint256 quantity);
    
    /// @notice Emitted when 6 special 1/1 tokens are assigned during reveal
    /// @param tokenIds Array of 6 token IDs that became special variants
    event SpecialsAssigned(uint256[6] tokenIds);

    /// @notice Deploy CypherWorms NFT contract
    /// @dev Initializes with Display contract and single payment recipient
    /// @dev Automatically configures SeaDrop integration for minting
    /// @param _displayContract Address of the Display contract for token rendering
    /// @param _paymentRecipient Address to receive all payments (can be EOA or splitter contract)
    constructor(
        address _displayContract,
        address _paymentRecipient
    ) ERC721SeaDrop("CypherWorms", "CYWO", _buildSeaDropArray()) {
        require(
            _paymentRecipient != address(0),
            "Payment recipient cannot be zero address"
        );

        displayContract = Display(_displayContract);
        paymentRecipient = _paymentRecipient;
        _maxSupply = MAX_SUPPLY;
        transferProtectionBasePrice = 0;
        transferProtectionToken = address(0);
    }

    function _buildSeaDropArray() private pure returns (address[] memory) {
        address[] memory seaDrop = new address[](1);
        seaDrop[0] = 0x00005EA00Ac477B1030CE78506496e8C2dE24bf5;
        return seaDrop;
    }

    // OWNER RESERVE MINT

    /// @notice One-time owner mint for initial allocation (750 tokens / 10% of supply)
    /// @dev Can only be called once before public sale. Mints up to 750 tokens to a specified recipient.
    /// @param recipient The address to receive the tokens
    /// @param quantity The number of tokens to mint (max 750)
    function ownerMint(address recipient, uint256 quantity) external onlyOwner {
        require(!ownerMinted, "Owner mint already used");
        require(quantity > 0 && quantity <= 750, "Must mint 1-750 tokens");
        require(recipient != address(0), "Invalid recipient");
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Exceeds max supply");

        ownerMinted = true;
        _mint(recipient, quantity);

        emit OwnerMint(recipient, quantity);
    }

    /// @notice One-time strategic mint for partnerships/marketing (225 tokens / 3% of supply)
    /// @dev Can only be called once. Mints up to 225 tokens to a specified recipient.
    /// @param recipient The address to receive the tokens
    /// @param quantity The number of tokens to mint (max 225)
    function strategicMint(
        address recipient,
        uint256 quantity
    ) external onlyOwner {
        require(!strategicMinted, "Strategic mint already used");
        require(quantity > 0 && quantity <= 225, "Must mint 1-225 tokens");
        require(recipient != address(0), "Invalid recipient");
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Exceeds max supply");

        strategicMinted = true;
        _mint(recipient, quantity);

        emit StrategicMint(recipient, quantity);
    }

    // HOLDING & LEVELING SYSTEM

    /// @notice Get the number of days a token has been held by current owner
    /// @param tokenId The token ID to check
    /// @return Number of days held
    function getHoldCountInDays(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "token does not exist");
        return (block.timestamp - tokens[tokenId].holdCount) / 1 days;
    }

    /// @notice Get the evolution level of a token based on holding duration
    /// @param tokenId The token ID to check
    /// @return Level (0-8): Null, Seed, Node, Process, Thread, Cluster, Network, Protocol, Singularity
    function getTokenLevel(uint256 tokenId) public view returns (uint256) {
        uint256 daysHeld = getHoldCountInDays(tokenId);
        if (daysHeld < 2) return 0;
        if (daysHeld < 7) return 1;
        if (daysHeld < 14) return 2;
        if (daysHeld < 21) return 3;
        if (daysHeld < 28) return 4;
        if (daysHeld < 60) return 5;
        if (daysHeld < 90) return 6;
        if (daysHeld < 180) return 7;
        return 8;
    }

    // TRANSFER PROTECTION

    /// @notice Calculate the price to protect a token transfer based on its level
    /// @dev Uses square root curve to prevent excessive pricing for long-term holders
    /// @dev Formula: basePrice * sqrt(level + 1)
    /// @dev Examples: Level 0 = 1.0x, Level 1 = 1.41x, Level 3 = 2.0x, Level 8 = 3.0x
    /// @param tokenId The token ID to check
    /// @return Price in wei (or tokens if ERC20 is set)
    function getTransferProtectionPrice(
        uint256 tokenId
    ) public view returns (uint256) {
        if (transferProtectionBasePrice == 0) {
            return 0;
        }

        uint256 level = getTokenLevel(tokenId);

        // Square root pricing curve: basePrice * sqrt(level + 1)
        // FixedPointMathLib.sqrt expects a WAD (1e18 scale) input and returns WAD output
        // sqrt(1e18) = 1e9 (which represents 1.0 when in WAD scale)
        // So we need to: sqrt(levelPlusOne * 1e18) to get the result in WAD
        // Then multiply basePrice by this WAD value and divide by 1e9 to get actual multiplier
        uint256 levelPlusOne = level + 1;
        uint256 sqrtResult = FixedPointMathLib.sqrt(levelPlusOne * 1e18);

        // sqrtResult is the square root in WAD format (1e9 = 1.0x multiplier)
        // Multiply by basePrice and divide by 1e9 to apply the multiplier
        return (transferProtectionBasePrice * sqrtResult) / 1e9;
    }

    /// @notice Protect a token from having its hold count reset on next transfer (one-time use)
    /// @param tokenId The token ID to protect
    function protectTransfer(uint256 tokenId) external payable {
        require(ownerOf(tokenId) == msg.sender, "not token owner");
        require(!tokens[tokenId].transferProtection, "already protected");

        uint256 price = getTransferProtectionPrice(tokenId);
        _processProtectionPayment(price);

        tokens[tokenId].transferProtection = true;
        emit TransferProtected(tokenId, getTokenLevel(tokenId), price);
    }

    /// @notice Process payment for transfer protection (internal helper)
    /// @dev Sends 100% of payment to paymentRecipient (can be EOA or splitter contract)
    /// @dev Uses pull pattern for ETH (pending withdrawals), direct transfer for ERC20
    /// @param price Amount to be paid
    function _processProtectionPayment(uint256 price) private {
        if (transferProtectionToken != address(0)) {
            // ERC20 payment: Direct transfer to recipient
            require(msg.value == 0, "ETH not accepted for ERC20 payment");

            SafeTransferLib.safeTransferFrom(
                transferProtectionToken,
                msg.sender,
                paymentRecipient,
                price
            );

            emit ERC20PaymentProcessed(transferProtectionToken, msg.sender, price);
        } else {
            // ETH payment: Pending withdrawal pattern (more gas efficient for many users)
            require(msg.value >= price, "insufficient payment");

            pendingWithdrawals[paymentRecipient] += price;
            emit PaymentReceived(msg.sender, price);

            // Refund excess ETH
            if (msg.value > price) {
                SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);
            }
        }
    }

    /// @notice Set the base price for transfer protection (only owner)
    /// @param newBasePrice New base price in wei (max uint96)
    function setTransferProtectionBasePrice(
        uint96 newBasePrice
    ) external onlyOwner {
        transferProtectionBasePrice = newBasePrice;
        emit TransferProtectionPriceUpdated(newBasePrice);
    }

    /// @notice Set the token used for transfer protection payment (only owner)
    /// @param token Address of ERC20 token (address(0) for ETH)
    function setTransferProtectionToken(address token) external onlyOwner {
        transferProtectionToken = token;
        emit TransferProtectionTokenUpdated(token);
    }

    /// @notice Get the current payment token for transfer protection
    /// @return Address of ERC20 token (address(0) means ETH)
    function getTransferProtectionPaymentToken()
        external
        view
        returns (address)
    {
        return transferProtectionToken;
    }

    /// @notice Setup royalty info (only owner, should be called after deployment)
    /// @dev Sets this contract as royalty receiver with 5% (500 bps)
    /// @dev Royalties are forwarded to paymentRecipient via receive() function
    function setupRoyalties() external onlyOwner {
        RoyaltyInfo memory royaltyInfo = RoyaltyInfo({
            royaltyAddress: address(this),
            royaltyBps: 500
        });
        this.setRoyaltyInfo(royaltyInfo);
    }

    /// @notice Withdraw pending ETH balance
    /// @dev Only paymentRecipient can withdraw
    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "no pending withdrawal");

        pendingWithdrawals[msg.sender] = 0;

        SafeTransferLib.safeTransferETH(msg.sender, amount);
        emit PaymentWithdrawn(msg.sender, amount);
    }

    /// @notice Check pending withdrawal amount for an address
    /// @param account Address to check
    /// @return Pending withdrawal amount in wei
    function getPendingWithdrawal(
        address account
    ) external view returns (uint256) {
        return pendingWithdrawals[account];
    }

    /// @notice Recover accidentally sent ERC20 tokens to a specified recipient
    /// @dev Only owner can recover tokens. Cannot recover the payment token to prevent loss.
    /// @dev Simplified to allow direct transfer to intended recipient (e.g., the original sender)
    /// @param token The ERC20 token contract address to recover
    /// @param recipient The address to send recovered tokens to
    /// @param amount The amount of tokens to recover
    function recoverERC20(
        address token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(token != address(0), "invalid token address");
        require(recipient != address(0), "invalid recipient");
        require(
            token != transferProtectionToken,
            "cannot recover payment token"
        );

        SafeTransferLib.safeTransfer(token, recipient, amount);

        emit ERC20Recovered(token, recipient, amount);
    }

    /// @notice Update the payment recipient address
    /// @dev Only owner can update. Can be set to EOA or splitter contract.
    /// @dev Transfers any pending withdrawals to new address.
    /// @param newRecipient The new payment recipient address
    function updatePaymentRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "invalid recipient address");
        require(newRecipient != paymentRecipient, "same as current recipient");

        address oldRecipient = paymentRecipient;
        uint256 pendingAmount = pendingWithdrawals[oldRecipient];

        if (pendingAmount > 0) {
            pendingWithdrawals[oldRecipient] = 0;
            pendingWithdrawals[newRecipient] += pendingAmount;
        }

        paymentRecipient = newRecipient;
        emit PaymentRecipientUpdated(oldRecipient, newRecipient);
    }

    // REVEAL MECHANISM

    /// @notice Set the reveal secret (only owner, can only be set once)
    /// @dev Can be called when collection reaches max supply (allows reveal even if not fully minted)
    /// @dev Automatically selects 6 random tokens to become special 1/1s
    /// @param secret The secret used to finalize DNA generation (will be cast to bytes30)
    function adminSetWormSecret(bytes32 secret) external onlyOwner {
        require(wormSecret == bytes30(0), "secret already set");
        require(
            _totalMinted() >= MAX_SUPPLY,
            "must reach max supply to reveal"
        );

        wormSecret = bytes30(secret);
        _assignSpecialTokens(secret);

        emit WormSecretSet(secret);
    }

    /// @notice Internal function to select 6 random tokens and assign them to special variants
    /// @dev Uses wormSecret as entropy to deterministically select unique token IDs
    /// @dev Note: specialsAssigned check removed as redundant (already checked via wormSecret in caller)
    /// @param secret The wormSecret used for randomness
    function _assignSpecialTokens(bytes32 secret) private {
        uint256 totalMinted = _totalMinted();
        uint256 segmentSize = totalMinted / 6;

        for (uint256 i = 0; i < 6; i++) {
            uint256 segmentStart = i * segmentSize;
            uint256 segmentEnd = (i == 5) ? totalMinted : (i + 1) * segmentSize;

            uint256 randomValue = uint256(
                keccak256(abi.encodePacked(secret, i))
            );
            uint256 tokenId = segmentStart +
                (randomValue % (segmentEnd - segmentStart)) +
                1;

            specialTokenIds[i] = tokenId;
            tokens[tokenId].isSpecialToken = true;
            tokens[tokenId].specialVariant = uint16(i);
        }

        emit SpecialsAssigned(specialTokenIds);
    }

    // MINTING & TRANSFER HOOKS

    /// @notice Hook called after token transfers (including mints and burns)
    /// @dev Generates DNA on mint, resets hold counter on transfer if not protected
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        if (from == address(0)) {
            // Minting: Initialize token data
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = startTokenId + i;
                bytes32 fullDna = keccak256(
                    abi.encodePacked(to, block.timestamp, tokenId)
                );

                // Store DNA as bytes23 (trim last 9 bytes)
                tokens[tokenId].dna = bytes23(fullDna);
                tokens[tokenId].holdCount = uint40(block.timestamp);

                emit DNAGenerated(tokenId, fullDna);
            }
        } else if (to != address(0)) {
            // Transfer: Reset hold count unless protected
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = startTokenId + i;

                if (!tokens[tokenId].transferProtection) {
                    tokens[tokenId].holdCount = uint40(block.timestamp);
                    emit HoldCountReset(tokenId);
                } else {
                    tokens[tokenId].transferProtection = false;
                }
            }
        }

        super._afterTokenTransfers(from, to, startTokenId, quantity);
    }

    // METADATA

    /// @notice Get the token URI with metadata and image
    /// @param tokenId The token ID
    /// @return data URI containing JSON metadata
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "token does not exist");

        if (wormSecret != bytes30(0)) {
            TokenData memory tokenData = tokens[tokenId];

            if (tokenData.isSpecialToken) {
                return Special.traits(tokenData.specialVariant);
            }

            // Re-hash the 23-byte DNA with wormSecret to generate full seed
            bytes32 seed = keccak256(
                abi.encodePacked(tokenData.dna, wormSecret)
            );
            return
                displayContract.tokenURIFromHash(
                    seed,
                    getTokenLevel(tokenId),
                    tokenId
                );
        }

        return PreReveal.tokenURIPreReveal(tokenId);
    }

    // SPECIAL 1/1 VIEW FUNCTIONS

    /// @notice Check if a token is a special 1/1
    /// @param tokenId The token ID to check
    /// @return True if the token is a special 1/1
    function isSpecial(uint256 tokenId) external view returns (bool) {
        return tokens[tokenId].isSpecialToken;
    }

    /// @notice Get the special variant index for a token (0-5)
    /// @param tokenId The token ID to check
    /// @return The variant index (0-5), reverts if not a special token
    function getSpecialVariant(
        uint256 tokenId
    ) external view returns (uint256) {
        require(tokens[tokenId].isSpecialToken, "not a special token");
        return tokens[tokenId].specialVariant;
    }

    /// @notice Get all 6 special token IDs assigned during reveal
    /// @return Array of 6 token IDs that are special 1/1 variants (empty before reveal)
    function getSpecialTokenIds() external view returns (uint256[6] memory) {
        return specialTokenIds;
    }

    // PAYMENT HANDLING

    /// @notice Receive ETH payments (royalties, etc.) and add to pending withdrawals
    /// @dev Adds to paymentRecipient's pending withdrawal balance
    receive() external payable {
        if (msg.value > 0) {
            pendingWithdrawals[paymentRecipient] += msg.value;
            emit PaymentReceived(msg.sender, msg.value);
        }
    }
}
