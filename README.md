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
- ✅ Ticket sales with ETH escrowed until post-event distribution
- ✅ Optional **cash-only** events (no on-chain payment required)
- ✅ Configurable filming consent flow per ticket
- ✅ Ticket holder cancellations with automatic refunds to original wallet
- ✅ Automatic revenue distribution between artists and organizer once the event closes
- ✅ Ticket verification system
- ✅ Organizer and verifier management
- ✅ Comprehensive tests (14 passing tests)
- ✅ Automated deployment with Ignition

## Installation

```bash
npm install
```
## Sub module install
You might need to install submodule locally.

```bash
git submodule update --init --recursive
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

### Deployment (Ignition)

All contracts can be deployed with the Ignition module `ignition/modules`.

```bash
# Example for Polygon Amoy (make sure RPC_URL / PRIVATE_KEY envs are set)
npm run deploy:amoy
```

The module exposes parameters (organizer, artistIds, shares, ticket info, consent flags, etc.) via `m.getParameter(...)`, so you can supply real values without editing the file.

## Available Scripts

```bash
npm run test              # Run all Hardhat tests
npm run compile           # Compile contracts with Hardhat
npm run deploy:amoy       # Deploy full stack via Ignition to Amoy (dev)
npm run deploy:polygon    # Deploy full stack via Ignition to Polygon (prd)
```

## Contract Architecture

### Event.sol
The main contract that manages:
- Event creation
- Ticket sales (with escrow for on-chain payments)
- Cash-only mode for offline payments
- Ticketholder filming consent
- Refund / cancellation requests
- Post-event payment distribution
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

The project uses Hardhat Ignition for automated and reproducible deployment. The `Tickethic.ts` module deploys all contracts in the correct order with proper dependencies.

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