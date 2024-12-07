// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBridging {
    function bridgeTokens(
        address token,
        uint256 amount,
        uint256 targetChainId,
        address targetAddress
    ) external;
}
