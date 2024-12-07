// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/CrossChainManager.sol";
import "../src/mocks/BridgingMock.sol";
import "../src/mocks/ChainResolverMock.sol";
import "../src/mocks/MockToken.sol";

contract CrossChainManagerTest is Test {
    CrossChainManager ccm;
    BridgingMock bridging;
    ChainResolverMock chainResolver;
    MockToken token;
    address deployer = address(this);

    function setUp() public {
        console.log("CrossChainManagerTest setup");
        bridging = new BridgingMock();
        chainResolver = new ChainResolverMock();
        ccm = new CrossChainManager(address(chainResolver), address(bridging));
        token = new MockToken(deployer);
        console.log("Setup complete");
    }

    function testSendToChainSpecific() public {
        console.log("Testing cross chain send");
        // For demonstration: chain specific address "0xCAFE...@optimism.eth"
        ccm.sendToChainSpecificAddress(
            address(token),
            "0xCAFE000000000000000000000000000000000000@optimism.eth",
            50 ether
        );
        console.log("Sent 50 ether to optimism chain");
        // Just checking no revert. Actual bridging is mocked.
    }
}
