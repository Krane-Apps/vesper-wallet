// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IChainResolver {
    function resolveChain(
        string calldata chainIdentifier
    ) external view returns (uint256 chainId, string memory rpcEndpoint);
}
