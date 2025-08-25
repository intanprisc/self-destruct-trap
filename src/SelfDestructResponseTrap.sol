// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SelfDestructResponseTrap {
    
    struct ThreatAlert {
        address wallet;
        uint256 balance;
        uint256 timestamp;
        string reason;
        bool isThreat;
    }
    
    ThreatAlert[] public alerts;
    mapping(address => bool) public flaggedWallets;
    
    event SelfDestructDetected(
        address indexed wallet,
        uint256 balance,
        uint256 timestamp,
        string reason
    );
    
    constructor() {}
    
    function receiveResponse(bytes memory responseData) external {
        if (responseData.length > 0) {
            (address wallet, uint256 balance, uint256 timestamp, string memory reason, bool isThreat) = 
                abi.decode(responseData, (address, uint256, uint256, string, bool));
            
            if (isThreat) {
                require(!flaggedWallets[wallet], "Already flagged");

                alerts.push(ThreatAlert({
                    wallet: wallet,
                    balance: balance,
                    timestamp: timestamp,
                    reason: reason,
                    isThreat: isThreat
                }));
                
                flaggedWallets[wallet] = true;
                
                emit SelfDestructDetected(wallet, balance, timestamp, reason);
            }
        }
    }
    
    function isWalletFlagged(address wallet) external view returns (bool) {
        return flaggedWallets[wallet];
    }
    
    function getAlertsCount() external view returns (uint256) {
        return alerts.length;
    }
}
