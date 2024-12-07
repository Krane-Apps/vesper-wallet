// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IPrivacyPool.sol";

contract PrivacyManager {
    IPrivacyPool public privacyPool;

    constructor(address _privacyPool) {
        privacyPool = IPrivacyPool(_privacyPool);
    }

    function depositPrivate(address user, uint256 amount) external {
        privacyPool.deposit(user, amount);
    }

    function withdrawPrivate(
        address user,
        uint256 amount,
        bytes calldata proof
    ) external {
        privacyPool.withdraw(user, amount, proof);
    }
}
