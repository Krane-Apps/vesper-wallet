// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IChainResolver.sol";
import "./interfaces/IBridging.sol";
import {AddressParser} from "./libraries/AddressParser.sol";

contract CrossChainManager {
    IChainResolver public chainResolver;
    IBridging public bridgingContract;

    constructor(address _chainResolver, address _bridgingContract) {
        chainResolver = IChainResolver(_chainResolver);
        bridgingContract = IBridging(_bridgingContract);
    }

    function sendToChainSpecificAddress(
        address token,
        string calldata fullAddr,
        uint256 amount
    ) external {
        (address parsedAddr, string memory chainIdStr) = AddressParser
            .parseChainSpecificAddress(fullAddr);
        (uint256 chainId, ) = chainResolver.resolveChain(chainIdStr);
        bridgingContract.bridgeTokens(token, amount, chainId, parsedAddr);
    }
}
