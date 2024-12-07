// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/VesperWallet.sol";
import "../src/mocks/MockToken.sol";
import "../src/mocks/MockPrivacyPool.sol";
import "../src/mocks/BridgingMock.sol";
import "../src/mocks/ChainResolverMock.sol";

contract VesperWalletTest is Test {
    VesperWallet wallet;
    MockToken token;
    address owner = address(0xABCD);
    address[] guardians = [address(0x1111), address(0x2222)];
    uint256 threshold = 2;
    MockPrivacyPool privacyPool;
    BridgingMock bridging;
    ChainResolverMock chainResolver;

    function setUp() public {
        console.log("Setting up VesperWalletTest...");
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
        // give owner some tokens
        token.transfer(owner, 1000 ether);
        console.log("Setup complete. Owner has 1000 tokens.");
    }

    function testDepositAndSend() public {
        console.log("testDepositAndSend start");
        vm.startPrank(owner);
        wallet.deposit(address(token), 500 ether);
        assertEq(
            wallet.balances(owner, address(token)),
            500 ether,
            "Owner should have 500 in wallet"
        );
        console.log("Owner deposited 500 tokens into wallet");

        wallet.send(address(token), address(0xBEEF), 100 ether);
        console.log("Owner sent 100 tokens to BEEF");
        assertEq(
            wallet.balances(owner, address(token)),
            400 ether,
            "Owner should have 400 left"
        );
        assertEq(
            wallet.balances(address(0xBEEF), address(token)),
            100 ether,
            "BEEF should have 100 now"
        );
        vm.stopPrank();
        console.log("testDepositAndSend done");
    }

    function testUsePrivacyDepositAndWithdraw() public {
        vm.startPrank(owner);
        wallet.deposit(address(token), 200 ether);
        console.log(
            "Deposited 200 tokens. Now depositing into privacy pool..."
        );
        wallet.usePrivacyDeposit(address(token), 100 ether);
        console.log("Deposited 100 into privacy pool");
        assertEq(
            wallet.balances(owner, address(token)),
            100 ether,
            "Owner should have 100 left in wallet"
        );
        assertEq(
            privacyPool.privateBalance(owner),
            100 ether,
            "Privacy pool should hold 100 for owner"
        );

        // Mock proof as empty bytes
        wallet.usePrivacyWithdraw(address(token), 50 ether, "");
        console.log("Withdrew 50 from privacy pool");
        assertEq(
            privacyPool.privateBalance(owner),
            50 ether,
            "Should have 50 left in privacy pool"
        );
        assertEq(
            wallet.balances(owner, address(token)),
            150 ether,
            "Owner back to 150 in wallet"
        );

        vm.stopPrank();
    }

    function testCrossChainSend() public {
        vm.startPrank(owner);
        wallet.deposit(address(token), 300 ether);
        console.log("Deposited 300 tokens to wallet");
        // Use a valid 20-byte address before '@':
        wallet.sendChainSpecific(
            address(token),
            "0xCAFE000000000000000000000000000000000000@optimism.eth",
            100 ether
        );
        console.log("Sent 100 tokens to optimism chain");
        assertEq(
            wallet.balances(owner, address(token)),
            200 ether,
            "Owner should have 200 left"
        );
        vm.stopPrank();
    }
}
