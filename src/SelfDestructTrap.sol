// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract SelfDestructTrap is ITrap {
    
    address private constant TARGET_WALLET = 0x1234567890123456789012345678901234567890; // Change to your address
    
    constructor() {}
    
    function collect() external view returns (bytes memory) {
        address wallet = TARGET_WALLET;
        uint256 balance = wallet.balance;
        uint256 nonce = tx.origin.code.length > 0 ? 0 : 1;
        
        return abi.encode(wallet, balance, nonce, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, "No data provided");
        }
        
        (address wallet, uint256 balance, uint256 nonce, uint256 timestamp) = 
            abi.decode(data[0], (address, uint256, uint256, uint256));
        
        bool isSuspicious = false;
        string memory reason = "";
        
        if (data.length > 1) {
            for (uint i = 1; i < data.length; i++) {
                (address prevWallet, uint256 prevBalance, uint256 prevNonce, uint256 prevTimestamp) = 
                    abi.decode(data[i], (address, uint256, uint256, uint256));
                
                if (wallet == prevWallet && 
                    balance > prevBalance && 
                    nonce == prevNonce && 
                    timestamp > prevTimestamp) {
                    
                    uint256 balanceIncrease = balance - prevBalance;
                    uint256 timeDiff = timestamp - prevTimestamp;
                    
                    if (balanceIncrease > 0.001 ether && timeDiff < 300) {
                        isSuspicious = true;
                        reason = "SELF-DESTRUCT DETECTED: Suspicious ETH increase without normal transaction";
                        break;
                    }
                }
            }
        }
        
        if (!isSuspicious && balance > 0) {
            if (balance < 0.01 ether && balance > 0.000001 ether) {
                isSuspicious = true;
                reason = "POTENTIAL DUSTING: Small suspicious amount detected";
            }
        }
        
        if (isSuspicious) {
            bytes memory responseData = abi.encode(
                wallet,
                balance,
                timestamp,
                reason,
                true
            );
            return (true, responseData);
        }
        
        return (false, "No self-destruct pattern detected");
    }
}