// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/SessionKeyManager.sol";

contract SessionKeyManagerTest is Test {
    SessionKeyManager skm;
    address owner = address(0xABCD);
    address sessionKey = address(0x5555);

    function setUp() public {
        console.log("SessionKeyManagerTest setup");
        skm = new SessionKeyManager(owner);
        vm.startPrank(owner);
        skm.addSessionKey(sessionKey, 500 ether, block.timestamp + 1 days);
        console.log(
            "Added session key with daily limit 500 and expiry in 1 day"
        );
        vm.stopPrank();
    }

    function testSessionKeySpendWithinLimit() public {
        bool can = skm.canSpend(sessionKey, 100 ether);
        assertTrue(can);
        skm.recordSpend(sessionKey, 100 ether);

        can = skm.canSpend(sessionKey, 400 ether);
        assertTrue(can);
        skm.recordSpend(sessionKey, 400 ether);

        // Now try 1 more ether:
        can = skm.canSpend(sessionKey, 1 ether);
        assertFalse(can, "Should not be able to exceed daily limit");
    }

    function testRevokeSessionKey() public {
        vm.startPrank(owner);
        skm.revokeSessionKey(sessionKey);
        console.log("Revoked session key");
        vm.stopPrank();
        bool can = skm.canSpend(sessionKey, 50 ether);
        assertFalse(can, "Should not be able to spend after revocation");
    }
}
