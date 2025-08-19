// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SelfDestructTrap.sol";

contract SelfDestructTrapTest is Test {
    SelfDestructTrap public trap;
    address constant TARGET_WALLET = 0x1234567890123456789012345678901234567890;
    
    function setUp() public {
        trap = new SelfDestructTrap();
    }
    
    function testCollect() public view {
        bytes memory data = trap.collect();
        
        (address wallet, uint256 balance,, uint256 timestamp) = 
            abi.decode(data, (address, uint256, uint256, uint256));
        
        assertEq(wallet, TARGET_WALLET);
        assertEq(balance, TARGET_WALLET.balance);
        assertGt(timestamp, 0);
    }
    
    function testShouldRespondNoData() public view {
        bytes[] memory emptyData = new bytes[](0);
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(emptyData);
        
        assertFalse(shouldRespond);
        assertEq(string(response), "No data provided");
    }
    
    function testShouldRespondNormalBalance() public view {
        bytes memory currentData = abi.encode(
            TARGET_WALLET,
            1 ether,
            1,
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = currentData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(string(response), "No self-destruct pattern detected");
    }
    
    function testShouldRespondSelfDestructDetected() public view {
        uint256 currentTime = 1000;
        
        bytes memory prevData = abi.encode(
            TARGET_WALLET,
            1 ether,
            1,
            currentTime - 100
        );
        
        bytes memory currentData = abi.encode(
            TARGET_WALLET,
            1.1 ether,
            1,
            currentTime
        );
        
        bytes[] memory data = new bytes[](2);
        data[0] = currentData;
        data[1] = prevData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertTrue(shouldRespond);
        
        (address wallet, uint256 balance,, string memory reason, bool isThreat) = 
            abi.decode(response, (address, uint256, uint256, string, bool));
        
        assertEq(wallet, TARGET_WALLET);
        assertEq(balance, 1.1 ether);
        assertTrue(isThreat);
        assertEq(reason, "SELF-DESTRUCT DETECTED: Suspicious ETH increase without normal transaction");
    }
    
    function testShouldRespondDustingDetected() public view {
        bytes memory dustingData = abi.encode(
            TARGET_WALLET,
            0.001 ether,
            1,
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = dustingData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertTrue(shouldRespond);
        
        (address wallet, uint256 balance,, string memory reason, bool isThreat) = 
            abi.decode(response, (address, uint256, uint256, string, bool));
        
        assertEq(wallet, TARGET_WALLET);
        assertEq(balance, 0.001 ether);
        assertTrue(isThreat);
        assertEq(reason, "POTENTIAL DUSTING: Small suspicious amount detected");
    }
    
    function testShouldRespondNoSelfDestructWithNormalIncrease() public view {
        uint256 currentTime = 1000;
        
        bytes memory prevData = abi.encode(
            TARGET_WALLET,
            1 ether,
            1,
            currentTime - 100
        );
        
        bytes memory currentData = abi.encode(
            TARGET_WALLET,
            1.1 ether,
            2,
            currentTime
        );
        
        bytes[] memory data = new bytes[](2);
        data[0] = currentData;
        data[1] = prevData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(string(response), "No self-destruct pattern detected");
    }
    
    function testShouldRespondSmallIncreaseNoAlert() public view {
        uint256 currentTime = 1000;
        
        bytes memory prevData = abi.encode(
            TARGET_WALLET,
            1 ether,
            1,
            currentTime - 100
        );
        
        bytes memory currentData = abi.encode(
            TARGET_WALLET,
            1.0005 ether,
            1,
            currentTime
        );
        
        bytes[] memory data = new bytes[](2);
        data[0] = currentData;
        data[1] = prevData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(string(response), "No self-destruct pattern detected");
    }
    
    function testShouldRespondLongTimeNoAlert() public view {
        uint256 currentTime = 1000;
        
        bytes memory prevData = abi.encode(
            TARGET_WALLET,
            1 ether,
            1,
            currentTime - 400
        );
        
        bytes memory currentData = abi.encode(
            TARGET_WALLET,
            1.1 ether,
            1,
            currentTime
        );
        
        bytes[] memory data = new bytes[](2);
        data[0] = currentData;
        data[1] = prevData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(string(response), "No self-destruct pattern detected");
    }
    
    function testMultipleDataPoints() public view {
        uint256 currentTime = 1000;
        
        bytes memory data1 = abi.encode(TARGET_WALLET, 1 ether, 1, currentTime - 300);
        bytes memory data2 = abi.encode(TARGET_WALLET, 1.05 ether, 1, currentTime - 200);
        bytes memory data3 = abi.encode(TARGET_WALLET, 1.15 ether, 1, currentTime - 100);
        bytes memory currentData = abi.encode(TARGET_WALLET, 1.15 ether, 1, currentTime);
        
        bytes[] memory data = new bytes[](4);
        data[0] = currentData;
        data[1] = data3;
        data[2] = data2;
        data[3] = data1;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertTrue(shouldRespond);
        
        (,,, string memory reason,) = abi.decode(response, (address, uint256, uint256, string, bool));
        assertEq(reason, "SELF-DESTRUCT DETECTED: Suspicious ETH increase without normal transaction");
    }
}