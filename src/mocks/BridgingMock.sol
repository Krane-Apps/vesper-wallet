// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IBridging.sol";

contract BridgingMock is IBridging {
    event BridgeTokens(
        address token,
        uint256 amount,
        uint256 targetChainId,
        address targetAddress
    );

    function bridgeTokens(
        address token,
        uint256 amount,
        uint256 targetChainId,
        address targetAddress
    ) external {
        // In a real scenario, the bridging contract would lock tokens and release them on the target chain.
        // Here we just emit an event.
        emit BridgeTokens(token, amount, targetChainId, targetAddress);
    }
}
