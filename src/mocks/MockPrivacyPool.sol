// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IPrivacyPool.sol";

contract MockPrivacyPool is IPrivacyPool {
    mapping(address => uint256) public privateBalance;

    function deposit(address user, uint256 amount) external {
        privateBalance[user] += amount;
    }

    function withdraw(address user, uint256 amount, bytes calldata) external {
        require(privateBalance[user] >= amount, "Not enough in privacy pool");
        privateBalance[user] -= amount;
    }
}
