// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GuardianManager.sol";

contract GuardianManagerTest is Test {
    GuardianManager gm;
    address owner = address(0xABCD);
    address g1 = address(0x1111);
    address g2 = address(0x2222);

    function setUp() public {
        console.log("GuardianManagerTest setup");
        address[] memory g = new address[](2);
        g[0] = g1;
        g[1] = g2;
        gm = new GuardianManager(owner, g, 2);
        console.log(
            "Guardian manager created with 2 guardians and threshold 2"
        );
    }

    function testAddAndRemoveGuardian() public {
        vm.startPrank(owner);
        address g3 = address(0x3333);
        gm.addGuardian(g3);
        console.log("Added g3 as guardian");
        assertTrue(gm.isGuardian(g3), "g3 should be a guardian");

        gm.removeGuardian(g3);
        console.log("Removed g3");
        assertFalse(gm.isGuardian(g3), "g3 should no longer be guardian");
        vm.stopPrank();
    }

    function testChangeThreshold() public {
        vm.startPrank(owner);
        gm.changeThreshold(1);
        console.log("Threshold changed to 1");
        vm.stopPrank();
    }

    function testVerifyGuardianSignatures() public view {
        // Mock test. Just ensure function runs.
        bytes[] memory sigs = new bytes[](2);
        assertTrue(
            gm.verifyGuardianSignatures(sigs),
            "With 2 sigs and threshold 2, should be true"
        );
    }
}
