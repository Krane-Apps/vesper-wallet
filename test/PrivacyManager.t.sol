// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PrivacyManager.sol";
import "../src/mocks/MockPrivacyPool.sol";

contract PrivacyManagerTest is Test {
    PrivacyManager pm;
    MockPrivacyPool privacyPool;
    address user = address(0xABCD);

    function setUp() public {
        console.log("PrivacyManagerTest setup");
        privacyPool = new MockPrivacyPool();
        pm = new PrivacyManager(address(privacyPool));
        console.log("PrivacyManager created");
    }

    function testDepositWithdraw() public {
        pm.depositPrivate(user, 100 ether);
        assertEq(
            privacyPool.privateBalance(user),
            100 ether,
            "Should have 100 in privacy pool"
        );

        pm.withdrawPrivate(user, 50 ether, "");
        assertEq(
            privacyPool.privateBalance(user),
            50 ether,
            "Should have 50 left after withdrawal"
        );
    }
}
