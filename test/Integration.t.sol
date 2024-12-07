// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/VesperWallet.sol";
import "../src/mocks/MockToken.sol";
import "../src/mocks/MockPrivacyPool.sol";
import "../src/mocks/BridgingMock.sol";
import "../src/mocks/ChainResolverMock.sol";
import "../src/GuardianManager.sol";
import "../src/SessionKeyManager.sol";
import "../src/RecoveryTimelock.sol";

contract IntegrationTest is Test {
    VesperWallet wallet;
    MockToken token;
    address owner = address(0xABCD);
    address sessionKey = address(0x5555);
    address[] guardians = [address(0x1111), address(0x2222)];
    uint256 threshold = 2;

    MockPrivacyPool privacyPool;
    BridgingMock bridging;
    ChainResolverMock chainResolver;

    function setUp() public {
        console.log("IntegrationTest setup");
        privacyPool = new MockPrivacyPool();
        bridging = new BridgingMock();
        chainResolver = new ChainResolverMock();
        wallet = new VesperWallet(
            owner,
            guardians,
            threshold,
            address(privacyPool),
            address(chainResolver),
            address(bridging),
            1 days
        );

        token = new MockToken(address(this));
        token.transfer(owner, 1000 ether);
        console.log("Owner received 1000 tokens");
    }

    function testFullFlow() public {
        vm.startPrank(owner);
        wallet.deposit(address(token), 500 ether);
        console.log("Owner deposited 500 tokens");

        // Add session key
        SessionKeyManager skm = wallet.sessionKeyManager();
        skm.addSessionKey(sessionKey, 200 ether, block.timestamp + 1 days);
        console.log("Added session key with daily limit 200 ether");

        // Use session key to send tokens
        vm.stopPrank();
        vm.startPrank(sessionKey);
        bool can = skm.canSpend(sessionKey, 100 ether);
        console.log("Session key can spend 100:", can);
        assertTrue(can, "Session key should be able to spend 100");
        skm.recordSpend(sessionKey, 100 ether);
        wallet.send(address(token), address(0xBEEF), 100 ether);
        console.log("Session key sent 100 tokens to BEEF");
        vm.stopPrank();

        // Check balances
        assertEq(
            wallet.balances(owner, address(token)),
            400 ether,
            "Owner should have 400 left"
        );
        assertEq(
            wallet.balances(address(0xBEEF), address(token)),
            100 ether,
            "BEEF got 100"
        );

        // Now back to owner, use privacy pool
        vm.startPrank(owner);
        wallet.usePrivacyDeposit(address(token), 50 ether);
        console.log("Owner deposited 50 into privacy pool");
        wallet.usePrivacyWithdraw(address(token), 20 ether, "");
        console.log("Owner withdrew 20 from privacy pool");
        assertEq(
            wallet.balances(owner, address(token)),
            370 ether,
            "Owner should have 370 now"
        );
        console.log("Owner now has 370 ether in wallet");

        // Initiate recovery to a new owner
        address newOwner = address(0x9999);
        bytes[] memory dummySigs = new bytes[](2);
        wallet.recoverOwnershipWithGuardians(newOwner, dummySigs);
        console.log("Recovery initiated to newOwner, waiting 1 day");
        vm.stopPrank();

        // Advance time and finalize
        vm.warp(block.timestamp + 1 days);
        wallet.finalizeRecovery();
        console.log("Recovery finalized, owner should now be newOwner");
        assertEq(wallet.owner(), newOwner, "Ownership should be transferred");
    }
}
