// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SessionKeyManager {
    struct SessionKey {
        address key;
        uint256 dailyLimit;
        uint256 expiresAt;
        uint256 spentToday;
        uint256 lastReset;
    }

    address public owner;
    mapping(address => SessionKey) public sessionKeys;

    event SessionKeyAdded(address key, uint256 dailyLimit, uint256 expiresAt);
    event SessionKeyRevoked(address key);
    event SessionKeySpent(address key, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function addSessionKey(
        address key,
        uint256 dailyLimit,
        uint256 expiresAt
    ) external onlyOwner {
        sessionKeys[key] = SessionKey({
            key: key,
            dailyLimit: dailyLimit,
            expiresAt: expiresAt,
            spentToday: 0,
            lastReset: block.timestamp
        });
        emit SessionKeyAdded(key, dailyLimit, expiresAt);
    }

    function revokeSessionKey(address key) external onlyOwner {
        delete sessionKeys[key];
        emit SessionKeyRevoked(key);
    }

    function canSpend(address key, uint256 amount) external returns (bool) {
        SessionKey storage sk = sessionKeys[key];
        if (sk.key == address(0)) return false;
        if (block.timestamp > sk.expiresAt) return false;
        // Reset daily limit if day passed
        if (block.timestamp - sk.lastReset > 1 days) {
            sk.spentToday = 0;
            sk.lastReset = block.timestamp;
        }
        return sk.spentToday + amount <= sk.dailyLimit;
    }

    function recordSpend(address key, uint256 amount) external {
        SessionKey storage sk = sessionKeys[key];
        require(sk.key != address(0), "Not session key");
        if (block.timestamp - sk.lastReset > 1 days) {
            sk.spentToday = 0;
            sk.lastReset = block.timestamp;
        }
        sk.spentToday += amount;
        emit SessionKeySpent(key, amount);
    }
}
