# README - Human Pass

## Introduction

**Human Pass** is a decentralized proof-of-humanity project using a **Soulbound Token (SBT)** to issue an authenticity certificate that attests to the humanity of its users. This certificate is non-transferable and is automatically revoked after a certain period (currently set to 3 months). The project aims to be **open source**, accessible to everyone, and built on values of inclusion, transparency, and security.

## Project Objective

The goal of Human Pass is to:

- Verify the humanity of users in a fun and fair way.
- Provide a reliable and tamper-proof certification system without compromising anonymity.
- Prevent abuse and bots in systems where human uniqueness is crucial.

## Key Features

1. **Soulbound Token (SBT)**: The humanity certificate is permanently attached to the user's wallet.
2. **Gamified Cognitive Test**: An engaging mini-game based on cognitive challenges is used to validate the user's human identity.
3. **Automatic Expiration**: The certificate has a limited validity period and must be renewed every 3 months.
4. **Non-transferability**: The SBT cannot be transferred or exchanged, ensuring its authenticity.
5. **Open Source**: The project is open to community contributions to ensure continuous improvement.

## Use Cases

- Decentralized voting systems.
- Online platforms requiring human authenticity verification.
- Fraud prevention in DAO or community projects.
- Access management for exclusive spaces or events.

## Project Structure

The project is organized into several modules:

1. **Smart Contract**: Solidity component for managing SBTs.
2. **Frontend**: User interface to complete the cognitive test and generate the certificate.
3. **Backend**: System for verification and blockchain interaction.
4. **Unit Tests**: Scripts to verify the security and performance of the contracts.
5. **Documentation**: Installation guide, user manual, and contributor guide.

## Prerequisites

- **Node.js** and **npm** for installing dependencies.
- **Hardhat** for smart contract development and deployment.
- A blockchain-compatible wallet (e.g., **Metamask**).

## Installation

1. Clone the repository:
   ```bash
   git clone <repository_URL>
   ```
2. Navigate into the directory:
   ```bash
   cd Human-Pass
   ```
3. Install dependencies into the folders /backend and /frontend:
   ```bash
   npm install
   ```

## Contributions

Contributions are welcome! If you want to propose improvements or report an issue:

1. Fork the project.
2. Create a branch for your modifications.
3. Submit a **pull request**.

## Security

The Human Pass approach relies on thorough testing of smart contracts and transparent audit management to ensure user security and privacy.

## License

This project is licensed under the **MIT** license. You are free to use, modify, and distribute it, provided that the license is included in any copy or distribution.
