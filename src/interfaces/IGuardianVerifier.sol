// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IGuardianVerifier {
    function verify(bytes calldata proof) external view returns (bool);
}
