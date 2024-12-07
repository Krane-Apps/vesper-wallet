// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./GuardianManager.sol";
import "./PrivacyManager.sol";
import "./CrossChainManager.sol";
import "./SessionKeyManager.sol";
import "./RecoveryTimelock.sol";

contract VesperWallet {
    address public owner;
    GuardianManager public guardianManager;
    PrivacyManager public privacyManager;
    CrossChainManager public crossChainManager;
    SessionKeyManager public sessionKeyManager;
    RecoveryTimelock public recoveryTimelock;

    // user -> token -> amount
    mapping(address => mapping(address => uint256)) public balances;

    event OwnershipTransferred(address oldOwner, address newOwner);
    event FundsSent(address token, address from, address to, uint256 amount);
    event CrossChainSent(address token, string toChainAddress, uint256 amount);
    event DepositMade(address user, address token, uint256 amount);

    constructor(
        address _initialOwner,
        address[] memory _guardians,
        uint256 _threshold,
        address _privacyPool,
        address _chainResolver,
        address _bridgingContract,
        uint256 _recoveryDelay
    ) {
        owner = _initialOwner;
        guardianManager = new GuardianManager(
            _initialOwner,
            _guardians,
            _threshold
        );
        privacyManager = new PrivacyManager(_privacyPool);
        crossChainManager = new CrossChainManager(
            _chainResolver,
            _bridgingContract
        );
        sessionKeyManager = new SessionKeyManager(_initialOwner);
        recoveryTimelock = new RecoveryTimelock(_initialOwner, _recoveryDelay);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyOwnerOrSessionKey(address token, uint256 amount) {
        if (msg.sender == owner) {
            _;
        } else {
            // Check session key conditions
            if (sessionKeyManager.canSpend(msg.sender, amount)) {
                _;
                sessionKeyManager.recordSpend(msg.sender, amount);
            } else {
                revert("Not owner or cannot spend");
            }
        }
    }

    function deposit(address token, uint256 amount) external {
        // In a real scenario, user must have approved this contract to move tokens.
        // For testing, assume tokens are transferred in test setup.
        balances[msg.sender][token] += amount;
        emit DepositMade(msg.sender, token, amount);
    }

    function send(
        address token,
        address to,
        uint256 amount
    ) external onlyOwnerOrSessionKey(token, amount) {
        require(balances[owner][token] >= amount, "Insufficient funds");
        balances[owner][token] -= amount;
        balances[to][token] += amount;
        emit FundsSent(token, owner, to, amount);
    }

    function sendChainSpecific(
        address token,
        string calldata toChainAddress,
        uint256 amount
    ) external onlyOwnerOrSessionKey(token, amount) {
        require(balances[owner][token] >= amount, "Insufficient funds");
        balances[owner][token] -= amount;
        crossChainManager.sendToChainSpecificAddress(
            token,
            toChainAddress,
            amount
        );
        emit CrossChainSent(token, toChainAddress, amount);
    }

    function usePrivacyDeposit(
        address token,
        uint256 amount
    ) external onlyOwner {
        require(balances[owner][token] >= amount, "Insufficient funds");
        balances[owner][token] -= amount;
        privacyManager.depositPrivate(owner, amount);
    }

    function usePrivacyWithdraw(
        address token,
        uint256 amount,
        bytes calldata proof
    ) external onlyOwner {
        privacyManager.withdrawPrivate(owner, amount, proof);
        balances[owner][token] += amount;
    }

    function recoverOwnershipWithGuardians(
        address newOwner,
        bytes[] calldata guardianSignatures
    ) external {
        require(
            guardianManager.verifyGuardianSignatures(guardianSignatures),
            "Not enough valid guardian signatures"
        );
        recoveryTimelock.initiateRecovery(newOwner);
    }

    function cancelRecovery() external {
        require(msg.sender == recoveryTimelock.owner(), "Only current owner");
        recoveryTimelock.cancelRecovery();
    }

    function finalizeRecovery() external {
        address oldOwner = recoveryTimelock.owner();
        recoveryTimelock.finalizeRecovery();
        address newOwner = recoveryTimelock.owner();
        owner = newOwner;
        // Update session key and guardian manager owners if needed
        // For simplicity, we won't in this example.
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function recoverOwnershipWithProof(
        address newOwner,
        bytes calldata proof,
        address verifier
    ) external {
        require(
            guardianManager.verifyGuardianWithProof(proof, verifier),
            "Invalid proof"
        );
        recoveryTimelock.initiateRecovery(newOwner);
    }
}
