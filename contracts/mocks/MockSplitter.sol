// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Mock payment splitter contract for testing
/// @dev Demonstrates how a splitter can be integrated with CypherWorms
contract MockSplitter {
    address payable public primaryRecipient;
    address payable public secondaryRecipient;
    uint256 public primaryBps; // Basis points (e.g., 7000 = 70%)
    
    mapping(address => uint256) public pendingWithdrawals;
    
    event PaymentReceived(address indexed from, uint256 amount);
    event PaymentSplit(uint256 primaryAmount, uint256 secondaryAmount);
    event Withdrawn(address indexed recipient, uint256 amount);
    
    constructor(
        address payable _primaryRecipient,
        address payable _secondaryRecipient,
        uint256 _primaryBps
    ) {
        require(_primaryRecipient != address(0), "Invalid primary");
        require(_secondaryRecipient != address(0), "Invalid secondary");
        require(_primaryBps <= 10000, "Invalid bps");
        
        primaryRecipient = _primaryRecipient;
        secondaryRecipient = _secondaryRecipient;
        primaryBps = _primaryBps;
    }
    
    /// @notice Receive and split payments
    receive() external payable {
        if (msg.value > 0) {
            uint256 primaryAmount = (msg.value * primaryBps) / 10000;
            uint256 secondaryAmount = msg.value - primaryAmount;
            
            pendingWithdrawals[primaryRecipient] += primaryAmount;
            pendingWithdrawals[secondaryRecipient] += secondaryAmount;
            
            emit PaymentReceived(msg.sender, msg.value);
            emit PaymentSplit(primaryAmount, secondaryAmount);
        }
    }
    
    /// @notice Withdraw pending balance
    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawal");
        
        pendingWithdrawals[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }
    
    /// @notice Get pending withdrawal for address
    function getPendingWithdrawal(address account) external view returns (uint256) {
        return pendingWithdrawals[account];
    }
}
