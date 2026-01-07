// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./seadrop/ERC721SeaDrop.sol";
import "./seadrop/interfaces/ISeaDropTokenContractMetadata.sol";
import "./Display.sol";
import "./PreReveal.sol";

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

    // ========== EVENTS ==========
    event DNAGenerated(uint256 indexed tokenId, bytes32 dna);
    event WormSecretSet(bytes32 secret);
    event HoldCountReset(uint256 indexed tokenId);
    event TransferProtected(uint256 indexed tokenId, uint256 level, uint256 pricePaid);
    event TransferProtectionPriceUpdated(uint256 newBasePrice);
    event TransferProtectionTokenUpdated(address indexed token);
    event PaymentReceived(address indexed from, uint256 amount, uint256 primaryShare, uint256 secondaryShare);
    event PaymentWithdrawn(address indexed recipient, uint256 amount);

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
        uint256 level = getTokenLevel(tokenId);
        
        // Handle payment
        if (transferProtectionToken == address(0)) {
            // ETH payment
            require(msg.value >= price, "insufficient payment");
            
            // Split payment 70/30
            uint256 primaryShare = (price * 70) / 100;
            uint256 secondaryShare = price - primaryShare;
            
            // Add to pending withdrawals
            pendingWithdrawals[primaryRecipient] += primaryShare;
            pendingWithdrawals[secondaryRecipient] += secondaryShare;
            
            emit PaymentReceived(msg.sender, price, primaryShare, secondaryShare);
            
            // Refund excess
            if (msg.value > price) {
                payable(msg.sender).transfer(msg.value - price);
            }
        } else {
            // ERC20 payment (future implementation)
            revert("ERC20 payment not yet implemented");
        }
        
        transferProtection[tokenId] = true;
        
        emit TransferProtected(tokenId, level, price);
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

    // ========== REVEAL MECHANISM ==========

    /// @notice Set the reveal secret (only owner, can only be set once)
    /// @param secret The secret used to finalize DNA generation
    function adminSetWormSecret(bytes32 secret) external onlyOwner {
        require(wormSecret == bytes32(0), "secret already set");
        wormSecret = secret;
        emit WormSecretSet(secret);
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
        
        // Post-reveal: generate from DNA + secret
        if (wormSecret != bytes32(0)) {
            bytes32 seed = keccak256(abi.encodePacked(dnaMap[tokenId], wormSecret));
            return displayContract.tokenURIFromHash(seed, getTokenLevel(tokenId), tokenId);
        }
        
        // Pre-reveal: placeholder
        return PreReveal.tokenURIPreReveal(tokenId);
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
