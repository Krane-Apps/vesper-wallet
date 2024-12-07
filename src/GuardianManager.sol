// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IGuardianVerifier.sol";

contract GuardianManager {
    address public owner;
    address[] public guardians;
    mapping(address => bool) public isGuardian;
    uint256 public threshold;

    event GuardianAdded(address guardian);
    event GuardianRemoved(address guardian);
    event ThresholdChanged(uint256 newThreshold);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        address _owner,
        address[] memory _guardians,
        uint256 _threshold
    ) {
        owner = _owner;
        for (uint i = 0; i < _guardians.length; i++) {
            guardians.push(_guardians[i]);
            isGuardian[_guardians[i]] = true;
        }
        threshold = _threshold;
    }

    function addGuardian(address g) external onlyOwner {
        guardians.push(g);
        isGuardian[g] = true;
        emit GuardianAdded(g);
    }

    function removeGuardian(address g) external onlyOwner {
        require(isGuardian[g], "Not guardian");
        isGuardian[g] = false;
        for (uint i = 0; i < guardians.length; i++) {
            if (guardians[i] == g) {
                guardians[i] = guardians[guardians.length - 1];
                guardians.pop();
                break;
            }
        }
        emit GuardianRemoved(g);
    }

    function changeThreshold(uint256 newThresh) external onlyOwner {
        require(newThresh <= guardians.length, "Invalid threshold");
        threshold = newThresh;
        emit ThresholdChanged(newThresh);
    }

    function verifyGuardianSignatures(
        bytes[] calldata guardianSignatures
    ) external view returns (bool) {
        // Placeholder: In reality, you would verify the signatures.
        // Assume that the caller ensures these are valid guardian signatures.
        return guardianSignatures.length >= threshold;
    }

    function verifyGuardianWithProof(
        bytes calldata proof,
        address verifier
    ) external view returns (bool) {
        return IGuardianVerifier(verifier).verify(proof);
    }
}
