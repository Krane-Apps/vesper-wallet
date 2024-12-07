// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/RecoveryTimelock.sol";

contract RecoveryTimelockTest is Test {
    RecoveryTimelock rt;
    address owner = address(0xABCD);
    address newOwner = address(0x1234);

    function setUp() public {
        console.log("RecoveryTimelockTest setup");
        rt = new RecoveryTimelock(owner, 1 days);
        console.log("RecoveryTimelock created with 1 day delay");
    }

    function testRecoveryProcess() public {
        vm.startPrank(owner);
        rt.initiateRecovery(newOwner);
        console.log("Recovery initiated for newOwner");
        vm.warp(block.timestamp + 1 days);
        rt.finalizeRecovery();
        console.log("Recovery finalized");
        assertEq(rt.owner(), newOwner, "Owner should now be newOwner");
        vm.stopPrank();
    }

    function testCancelRecovery() public {
        vm.startPrank(owner);
        rt.initiateRecovery(newOwner);
        console.log("Recovery initiated");
        rt.cancelRecovery();
        console.log("Recovery canceled");
        vm.stopPrank();
        vm.warp(block.timestamp + 1 days);
        // can't finalize now since proposedOwner reset to 0
        // finalizing should fail
        vm.expectRevert();
        rt.finalizeRecovery();
    }
}
