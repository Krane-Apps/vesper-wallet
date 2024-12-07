# Vesper Wallet

Vesper Wallet is a conceptual smart contract wallet system for Ethereum and its Layer-2 networks. It focuses on:

- **Cross-chain simplicity:** Send and receive funds directly using chain-specific addresses (e.g., `0xABC...@optimism.eth`) without complex bridging steps.
- **Robust security:** Utilize social recovery with a network of guardians, session keys with daily limits, and timelocked recovery to protect against key loss or compromises.
- **Privacy options:** Integrate with a privacy pool to deposit, withdraw, and manage assets discreetly.
- **Extendibility:** Designed to adapt as standards evolve, supporting ENS lookups, zero-knowledge verification, and emerging bridging protocols.

**Note:**  
This codebase is an example implementation. It uses mocks and simplified logic for demonstration purposes and is not production-ready.

## Features

- Social recovery with configurable guardian threshold
- Session keys for limited, daily spending
- Basic privacy pool integration
- Cross-chain sending with a mock resolver and bridging contract

## Setup

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation).
2. Clone the repository and enter the project directory.
3. Run `forge test` to execute the test suite.

## Next Steps

- Integrate real ZK proofs for privacy.
- Connect to real bridging solutions.
- Add ENS-based chain resolution and improved recovery mechanics.
