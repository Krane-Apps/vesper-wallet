// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/VesperWallet.sol";
import "../src/mocks/MockPrivacyPool.sol";
import "../src/mocks/BridgingMock.sol";
import "../src/mocks/ChainResolverMock.sol";

contract DeployScript is Script {
    function run() external {
        address deployer = msg.sender;
        address[] memory guardians = new address[](2);
        guardians[0] = address(0x1111);
        guardians[1] = address(0x2222);
        uint256 threshold = 2;

        vm.startBroadcast(deployer);
        MockPrivacyPool privacyPool = new MockPrivacyPool();
        BridgingMock bridging = new BridgingMock();
        ChainResolverMock chainResolver = new ChainResolverMock();

        VesperWallet wallet = new VesperWallet(
            deployer,
            guardians,
            threshold,
            address(privacyPool),
            address(chainResolver),
            address(bridging),
            1 days
        );
        vm.stopBroadcast();
    }
}
