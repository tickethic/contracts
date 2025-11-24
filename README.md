# Tickethic - Event Ticketing System

A decentralized event ticketing system built with Solidity and Hardhat 3 Beta.

## Project Overview

This project includes:

- **Artist.sol** - Contract for managing artists (ERC721 NFT)
- **Ticket.sol** - Contract for event tickets (ERC721 NFT)
- **Organizator.sol** - Contract for managing organizers
- **Event.sol** - Main contract for managing events and ticketing
- **Solidity Tests** - Comprehensive tests with Foundry
- **Ignition Deployment** - Automated deployment with Hardhat Ignition

## Features

- ✅ Event creation and management
- ✅ Ticket sales with ETH payments
- ✅ Automatic revenue distribution between artists and organizer
- ✅ Ticket verification system
- ✅ Organizer and verifier management
- ✅ Comprehensive tests (14 passing tests)
- ✅ Automated deployment with Ignition

## Installation

```bash
npm install
```

## Compilation
**Needs to be fixed**

```bash
npx hardhat compile
```

## Testing
**Needs to be fixed**

```bash
# All tests
npx hardhat test

# Solidity tests only
npx hardhat test solidity
```

## Deployment

### Automated Deployment via GitHub Actions

The project uses GitHub Actions workflows for automated deployments based on branch:

- **`develop` branch** → Automatically deploys to **Amoy (Polygon testnet)** via `deploy-dev.yml` workflow
- **`main` branch** → Automatically deploys to **Polygon mainnet** via `deploy-prd.yml` workflow

Both workflows are triggered on:
- Push to their respective branches
- Manual workflow dispatch
- Release creation

### Manual Deployment

#### Local Deployment
Start a local Hardhat node and deploy the contracts:
```bash
npx hardhat node
```
```bash
npx hardhat ignition deploy ignition/modules/amoy.ts --network localhost
```

#### Deployment on Amoy (Polygon testnet)

```bash
# Configure environment variables
export AMOY_RPC_URL="your_rpc_url"
export AMOY_PRIVATE_KEY="your_private_key"

# Deploy
npx hardhat ignition deploy ignition/modules/amoy.ts --network amoy
```

## Available Scripts

```bash
npm run test          # Run all tests
npm run compile       # Compile contracts
npm run deploy:amoy   # Deploy on Amoy testnet
```

## Contract Architecture

### Event.sol
The main contract that manages:
- Event creation
- Ticket sales
- Payment distribution
- Verification system

### Artist.sol
ERC721 contract to represent artists with metadata.

### Ticket.sol
ERC721 contract for event tickets.

### Organizator.sol
Contract for managing authorized organizers.

## Testing

The project includes 14 comprehensive tests that cover:
- ✅ Event creation
- ✅ Ticket purchasing
- ✅ Payment distribution
- ✅ Verification system
- ✅ Error handling
- ✅ Access controls

## Deployment with Ignition

The project uses Hardhat Ignition for automated and reproducible deployment. The `ignition/modules/amoy.ts` module deploys all contracts in the correct order with proper dependencies.

Deployment modules are organized by network:
- `ignition/modules/amoy.ts` - Deployment configuration for Amoy testnet

## Configuration

The project is configured for:
- Solidity 0.8.28
- Hardhat 3 Beta
- OpenZeppelin Contracts 5.4.0
- Foundry for Solidity testing
- Viem for Ethereum interactions

## Supported Networks

- `localhost` - Local Hardhat network
- `amoy` - Polygon Amoy testnet

## Security

- All contracts use OpenZeppelin for security
- Comprehensive tests for all use cases
- Appropriate access controls
- User input validation