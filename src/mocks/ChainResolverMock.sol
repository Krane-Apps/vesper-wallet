// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IChainResolver.sol";

contract ChainResolverMock is IChainResolver {
    function resolveChain(
        string calldata chainIdentifier
    ) external pure returns (uint256 chainId, string memory rpcEndpoint) {
        if (
            keccak256(bytes(chainIdentifier)) ==
            keccak256(bytes("optimism.eth"))
        ) {
            return (10, "https://optimism.rpc");
        } else if (
            keccak256(bytes(chainIdentifier)) ==
            keccak256(bytes("arbitrum.eth"))
        ) {
            return (42161, "https://arbitrum.rpc");
        } else {
            // Default to Ethereum mainnet
            return (1, "https://mainnet.rpc");
        }
    }
}
