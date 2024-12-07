// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RecoveryTimelock {
    address public owner;
    address public proposedOwner;
    uint256 public recoveryStart;
    uint256 public recoveryDelay; // e.g. 1 day

    event RecoveryInitiated(address proposedOwner, uint256 startTime);
    event RecoveryCanceled();
    event OwnerChanged(address oldOwner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _owner, uint256 _recoveryDelay) {
        owner = _owner;
        recoveryDelay = _recoveryDelay;
    }

    function initiateRecovery(address newOwner) external onlyOwner {
        proposedOwner = newOwner;
        recoveryStart = block.timestamp;
        emit RecoveryInitiated(newOwner, block.timestamp);
    }

    function cancelRecovery() external onlyOwner {
        proposedOwner = address(0);
        recoveryStart = 0;
        emit RecoveryCanceled();
    }

    function finalizeRecovery() external {
        require(proposedOwner != address(0), "No pending recovery");
        require(
            block.timestamp >= recoveryStart + recoveryDelay,
            "Not enough time passed"
        );
        address oldOwner = owner;
        owner = proposedOwner;
        proposedOwner = address(0);
        emit OwnerChanged(oldOwner, owner);
    }
}
