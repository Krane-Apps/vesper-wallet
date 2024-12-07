// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPrivacyPool {
    function deposit(address user, uint256 amount) external;

    function withdraw(
        address user,
        uint256 amount,
        bytes calldata proof
    ) external;
}
