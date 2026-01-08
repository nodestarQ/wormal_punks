// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./seadrop/ERC721SeaDrop.sol";
import "./seadrop/interfaces/ISeaDropTokenContractMetadata.sol";
import "./Display.sol";
import "./PreReveal.sol";
import "./Special.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract CypherWorms is ERC721SeaDrop {
    uint256 constant MAX_SUPPLY = 7503;

    Display public displayContract; // Display contract for rendering
    bytes32 public wormSecret; // Reveal secret (0x00... = not revealed)
    mapping(uint256 => bytes32) private dnaMap; // Token DNA
    mapping(uint256 => uint256) private holdCount; // Hold start timestamp
    mapping(uint256 => bool) private transferProtection; // One-time transfer protection
    
    address public transferProtectionToken; // ERC20 token for payment (address(0) = ETH)
    uint256 public transferProtectionBasePrice; // Base price for level 1

    // Payment split recipients (70/30 split)
    // Note: ENS names will be resolved to addresses during deployment
    address public primaryRecipient; // eip7503.eth - 70%
    address public secondaryRecipient; // warptoad.eth - 30%
    
    // Track balances for each recipient
    mapping(address => uint256) public pendingWithdrawals;

    // Owner reserve mint tracking
    bool public ownerMinted; // Track if owner has used their one-time mint

    // Special 1/1 tracking
    uint256[6] public specialTokenIds; // The 6 token IDs that are special 1/1s (index 0-5)
    mapping(uint256 => bool) private isSpecialToken; // Quick lookup if token is special
    mapping(uint256 => uint256) private tokenToSpecialVariant; // tokenId → variant index (0-5)
    bool public specialsAssigned; // Track if specials have been assigned

    // ========== EVENTS ==========
    event DNAGenerated(uint256 indexed tokenId, bytes32 dna);
    event WormSecretSet(bytes32 secret);
    event HoldCountReset(uint256 indexed tokenId);
    event TransferProtected(uint256 indexed tokenId, uint256 level, uint256 pricePaid);
    event TransferProtectionPriceUpdated(uint256 newBasePrice);
    event TransferProtectionTokenUpdated(address indexed token);
    event PaymentReceived(address indexed from, uint256 amount, uint256 primaryShare, uint256 secondaryShare);
    event PaymentWithdrawn(address indexed recipient, uint256 amount);
    event ERC20Recovered(address indexed token, uint256 amount, uint256 primaryShare, uint256 secondaryShare);
    event PrimaryRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event OwnerMint(address indexed recipient, uint256 quantity);
    event SpecialsAssigned(uint256[6] tokenIds);

    constructor(
        address _displayContract,
        address _primaryRecipient,
        address _secondaryRecipient
    ) ERC721SeaDrop("CypherWorms", "CYWO", _buildSeaDropArray()) {
        require(_primaryRecipient != address(0), "Primary recipient cannot be zero address");
        require(_secondaryRecipient != address(0), "Secondary recipient cannot be zero address");
        
        // Set display contract
        displayContract = Display(_displayContract);
        
        // Set payment recipients
        primaryRecipient = _primaryRecipient;
        secondaryRecipient = _secondaryRecipient;
        
        // Set max supply
        _maxSupply = MAX_SUPPLY;
        
        // Initialize transfer protection pricing (0 = free by default)
        transferProtectionBasePrice = 0;
        transferProtectionToken = address(0); // ETH by default
    }

    function _buildSeaDropArray() private pure returns (address[] memory) {
        address[] memory seaDrop = new address[](1);
        seaDrop[0] = 0x00005EA00Ac477B1030CE78506496e8C2dE24bf5;
        return seaDrop;
    }

    // ========== OWNER RESERVE MINT ==========

    /// @notice One-time owner mint for initial allocation (700 tokens / 10% of supply)
    /// @dev Can only be called once before public sale. Mints up to 700 tokens to a specified recipient.
    /// @param recipient The address to receive the tokens
    /// @param quantity The number of tokens to mint (max 700)
    function ownerMint(address recipient, uint256 quantity) external onlyOwner {
        require(!ownerMinted, "Owner mint already used");
        require(quantity > 0 && quantity <= 700, "Must mint 1-700 tokens");
        require(recipient != address(0), "Invalid recipient");
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Exceeds max supply");
        
        ownerMinted = true;
        _mint(recipient, quantity);
        
        emit OwnerMint(recipient, quantity);
    }

    // ========== HOLDING & LEVELING SYSTEM ==========

    /// @notice Get the number of days a token has been held by current owner
    /// @param tokenId The token ID to check
    /// @return Number of days held
    function getHoldCountInDays(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "token does not exist");
        return (block.timestamp - holdCount[tokenId]) / 1 days;
    }

    /// @notice Get the evolution level of a token based on holding duration
    /// @param tokenId The token ID to check
    /// @return Level (0-8): Null, Seed, Node, Process, Thread, Cluster, Network, Protocol, Singularity
    function getTokenLevel(uint256 tokenId) public view returns (uint256) {
        uint256 daysHeld = getHoldCountInDays(tokenId);
        if (daysHeld < 30) return 0;     // Null
        if (daysHeld < 90) return 1;     // Seed
        if (daysHeld < 180) return 2;    // Node
        if (daysHeld < 365) return 3;    // Process
        if (daysHeld < 545) return 4;    // Thread
        if (daysHeld < 730) return 5;    // Cluster
        if (daysHeld < 910) return 6;    // Network
        if (daysHeld < 1095) return 7;   // Protocol
        return 8;                         // Singularity
    }

    // ========== TRANSFER PROTECTION ==========

    /// @notice Calculate the price to protect a token transfer based on its level
    /// @param tokenId The token ID to check
    /// @return Price in wei (or tokens if ERC20 is set)
    function getTransferProtectionPrice(uint256 tokenId) public view returns (uint256) {
        if (transferProtectionBasePrice == 0) {
            return 0; // Free protection if base price is 0
        }
        
        uint256 level = getTokenLevel(tokenId);
        
        // Level 0 (Null) gets 1x multiplier, Level 8 (Singularity) gets 8x
        // Formula: basePrice * (level + 1)
        uint256 multiplier = level + 1;
        return transferProtectionBasePrice * multiplier;
    }

    /// @notice Protect a token from having its hold count reset on next transfer (one-time use)
    /// @param tokenId The token ID to protect
    function protectTransfer(uint256 tokenId) external payable {
        require(ownerOf(tokenId) == msg.sender, "not token owner");
        require(!transferProtection[tokenId], "already protected");
        
        uint256 price = getTransferProtectionPrice(tokenId);
        _processProtectionPayment(price);
        
        transferProtection[tokenId] = true;
        emit TransferProtected(tokenId, getTokenLevel(tokenId), price);
    }

    /// @notice Process payment for transfer protection (internal helper)
    /// @param price Amount to be paid
    function _processProtectionPayment(uint256 price) private {
        if (transferProtectionToken != address(0)) {
            revert("ERC20 payment not yet implemented");
        }
        
        require(msg.value >= price, "insufficient payment");
        
        // Split payment 70/30
        uint256 primaryShare = (price * 70) / 100;
        pendingWithdrawals[primaryRecipient] += primaryShare;
        pendingWithdrawals[secondaryRecipient] += price - primaryShare;
        
        emit PaymentReceived(msg.sender, price, primaryShare, price - primaryShare);
        
        // Refund excess
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    /// @notice Set the base price for transfer protection (only owner)
    /// @param newBasePrice New base price in wei
    function setTransferProtectionBasePrice(uint256 newBasePrice) external onlyOwner {
        transferProtectionBasePrice = newBasePrice;
        emit TransferProtectionPriceUpdated(newBasePrice);
    }

    /// @notice Set the token used for transfer protection payment (only owner)
    /// @param token Address of ERC20 token (address(0) for ETH)
    function setTransferProtectionToken(address token) external onlyOwner {
        transferProtectionToken = token;
        emit TransferProtectionTokenUpdated(token);
    }

    /// @notice Setup royalty info (only owner, should be called after deployment)
    /// @dev Sets this contract as royalty receiver with 5% (500 bps), payments will be split via receive()
    function setupRoyalties() external onlyOwner {
        // Set 5% royalty (500 basis points) to this contract
        // Payments will be automatically split when received
        RoyaltyInfo memory royaltyInfo = RoyaltyInfo({
            royaltyAddress: address(this),
            royaltyBps: 500
        });
        this.setRoyaltyInfo(royaltyInfo);
    }

    /// @notice Withdraw pending balance for caller
    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "no pending withdrawal");
        
        pendingWithdrawals[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "withdrawal failed");
        
        emit PaymentWithdrawn(msg.sender, amount);
    }
    
    /// @notice Check pending withdrawal amount for an address
    /// @param account Address to check
    /// @return Pending withdrawal amount in wei
    function getPendingWithdrawal(address account) external view returns (uint256) {
        return pendingWithdrawals[account];
    }

    /// @notice Recover accidentally sent ERC20 tokens with 70/30 split
    /// @dev Only owner can recover tokens. Splits recovered tokens between recipients.
    /// @param token The ERC20 token contract address to recover
    function recoverERC20(address token) external onlyOwner {
        require(token != address(0), "invalid token address");
        
        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "no tokens to recover");
        
        // Split tokens 70/30 (same as ETH split)
        uint256 primaryShare = (balance * 70) / 100;
        uint256 secondaryShare = balance - primaryShare;
        
        // Transfer to recipients
        require(erc20.transfer(primaryRecipient, primaryShare), "primary transfer failed");
        require(erc20.transfer(secondaryRecipient, secondaryShare), "secondary transfer failed");
        
        emit ERC20Recovered(token, balance, primaryShare, secondaryShare);
    }

    /// @notice Update the primary recipient address (70% share)
    /// @dev Only owner can update. Transfers any pending withdrawals to new address.
    /// @param newRecipient The new primary recipient address
    function updatePrimaryRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "invalid recipient address");
        require(newRecipient != primaryRecipient, "same as current recipient");
        
        address oldRecipient = primaryRecipient;
        
        // Transfer any pending withdrawals to new recipient
        uint256 pendingAmount = pendingWithdrawals[oldRecipient];
        if (pendingAmount > 0) {
            pendingWithdrawals[oldRecipient] = 0;
            pendingWithdrawals[newRecipient] += pendingAmount;
        }
        
        primaryRecipient = newRecipient;
        emit PrimaryRecipientUpdated(oldRecipient, newRecipient);
    }

    // ========== REVEAL MECHANISM ==========

    /// @notice Set the reveal secret (only owner, can only be set once)
    /// @dev Can only be called when collection is sold out (7,503 tokens minted)
    /// @dev Automatically selects 6 random tokens to become special 1/1s
    /// @param secret The secret used to finalize DNA generation
    function adminSetWormSecret(bytes32 secret) external onlyOwner {
        require(wormSecret == bytes32(0), "secret already set");
        require(_totalMinted() == MAX_SUPPLY, "must be sold out to reveal");
        
        wormSecret = secret;
        
        // Select and assign 6 special 1/1 tokens
        _assignSpecialTokens(secret);
        
        emit WormSecretSet(secret);
    }

    /// @notice Internal function to select 6 random tokens and assign them to special variants
    /// @dev Uses wormSecret as entropy to deterministically select unique token IDs
    /// @param secret The wormSecret used for randomness
    function _assignSpecialTokens(bytes32 secret) private {
        require(!specialsAssigned, "specials already assigned");
        
        uint256 totalMinted = MAX_SUPPLY; // We know it's sold out at this point
        
        // Divide the token range into 6 segments to guarantee uniqueness
        // This avoids collision checking and ensures bounded gas cost
        uint256 segmentSize = totalMinted / 6; // 7503 / 6 = 1250 tokens per segment
        
        for (uint256 i = 0; i < 6; i++) {
            // Calculate segment boundaries
            uint256 segmentStart = i * segmentSize;
            uint256 segmentEnd = (i == 5) ? totalMinted : (i + 1) * segmentSize;
            
            // Generate random value using secret + index
            uint256 randomValue = uint256(
                keccak256(abi.encodePacked(secret, i))
            );
            
            // Select token ID from this segment (token IDs are 1-based in ERC721A)
            uint256 tokenId = segmentStart + (randomValue % (segmentEnd - segmentStart)) + 1;
            
            // Store the special token assignment
            // Index i maps to variant i (0→0, 1→1, 2→2, etc.)
            specialTokenIds[i] = tokenId;
            isSpecialToken[tokenId] = true;
            tokenToSpecialVariant[tokenId] = i;
        }
        
        specialsAssigned = true;
        emit SpecialsAssigned(specialTokenIds);
    }

    // ========== MINTING & TRANSFER HOOKS ==========

    /// @notice Hook called after token transfers (including mints and burns)
    /// @dev Generates DNA on mint, resets hold counter on transfer
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        // Generate DNA on mint
        if (from == address(0)) {
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = startTokenId + i;
                
                // Generate deterministic but unique DNA from minter + timestamp + tokenId
                dnaMap[tokenId] = keccak256(
                    abi.encodePacked(to, block.timestamp, tokenId)
                );
                
                // Initialize hold counter
                holdCount[tokenId] = block.timestamp;
                
                emit DNAGenerated(tokenId, dnaMap[tokenId]);
            }
        } 
        // Reset hold count on transfer (not mint/burn)
        else if (to != address(0)) {
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = startTokenId + i;
                
                // Check if transfer is protected
                if (!transferProtection[tokenId]) {
                    holdCount[tokenId] = block.timestamp;
                    emit HoldCountReset(tokenId);
                } else {
                    // One-time protection - disable after use
                    transferProtection[tokenId] = false;
                }
            }
        }
        
        super._afterTokenTransfers(from, to, startTokenId, quantity);
    }

    // ========== METADATA ==========

    /// @notice Get the token URI with metadata and image
    /// @param tokenId The token ID
    /// @return data URI containing JSON metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "token does not exist");
        
        // Post-reveal: check if special 1/1 first
        if (wormSecret != bytes32(0)) {
            // Check if this token is a special 1/1
            if (isSpecialToken[tokenId]) {
                // Return the special metadata from Special library
                return Special.traits(tokenToSpecialVariant[tokenId]);
            }
            
            // Normal generated token
            bytes32 seed = keccak256(abi.encodePacked(dnaMap[tokenId], wormSecret));
            return displayContract.tokenURIFromHash(seed, getTokenLevel(tokenId), tokenId);
        }
        
        // Pre-reveal: placeholder
        return PreReveal.tokenURIPreReveal(tokenId);
    }

    // ========== SPECIAL 1/1 VIEW FUNCTIONS ==========

    /// @notice Check if a token is a special 1/1
    /// @param tokenId The token ID to check
    /// @return True if the token is a special 1/1
    function isSpecial(uint256 tokenId) external view returns (bool) {
        return isSpecialToken[tokenId];
    }

    /// @notice Get the special variant index for a token (0-5)
    /// @param tokenId The token ID to check
    /// @return The variant index (0-5), reverts if not a special token
    function getSpecialVariant(uint256 tokenId) external view returns (uint256) {
        require(isSpecialToken[tokenId], "not a special token");
        return tokenToSpecialVariant[tokenId];
    }

    /// @notice Get all 6 special token IDs
    /// @return Array of 6 token IDs that are special 1/1s (returns [0,0,0,0,0,0] if not assigned yet)
    function getSpecialTokenIds() external view returns (uint256[6] memory) {
        return specialTokenIds;
    }

    // ========== PAYMENT HANDLING ==========

    /// @notice Receive ETH payments (royalties and protection fees) and split 70/30
    /// @dev Automatically splits incoming payments between primary and secondary recipients
    receive() external payable {
        if (msg.value > 0) {
            // Split payment 70/30
            uint256 primaryShare = (msg.value * 70) / 100;
            uint256 secondaryShare = msg.value - primaryShare;
            
            // Add to pending withdrawals
            pendingWithdrawals[primaryRecipient] += primaryShare;
            pendingWithdrawals[secondaryRecipient] += secondaryShare;
            
            emit PaymentReceived(msg.sender, msg.value, primaryShare, secondaryShare);
        }
    }
}
