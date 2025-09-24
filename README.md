# BitVault Protocol

[![Clarity Version](https://img.shields.io/badge/Clarity-v3-brightgreen)](https://docs.stacks.co/clarity/)
[![Stacks Blockchain](https://img.shields.io/badge/Blockchain-Stacks-orange)](https://stacks.co/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](https://github.com/fredrick-paul/bitvault)

## Overview

**BitVault Protocol** is an advanced Bitcoin-native lending protocol built on the Stacks blockchain that enables Bitcoin holders to unlock liquidity without selling their BTC holdings. The protocol leverages Bitcoin's security and programmability to offer collateralized lending with automated risk management, dynamic interest rates, and institutional-grade liquidation mechanisms.

### Key Value Proposition

- **Maintain Bitcoin Exposure**: Borrow against Bitcoin collateral while retaining price appreciation potential
- **Bitcoin-Native Security**: Built on Stacks, inheriting Bitcoin's security model
- **Institutional Grade**: Professional risk management and liquidation systems
- **Automated Operations**: Time-based interest accrual and automated liquidation protection

## 🚀 Features

### Core Protocol Features

- **🔒 Bitcoin-Native Collateralization**: Secure custody and management of Bitcoin collateral
- **📊 Dynamic Collateral Ratios**: Market condition-based collateral requirements
- **⚡ Automated Liquidation System**: Proactive liquidation protection mechanisms
- **⏰ Time-Based Interest Accrual**: Block height-based interest calculations
- **🌐 Multi-Asset Support**: Borrowing capabilities across multiple supported assets
- **🎯 Governance Controls**: Adjustable risk parameters and protocol configuration

### Risk Management

- **Minimum Collateral Ratio**: 150% (configurable by governance)
- **Liquidation Threshold**: 120% (configurable by governance)
- **Real-Time Monitoring**: Continuous loan health assessment
- **Oracle Integration**: Reliable price feed mechanisms

## 🏗️ Architecture

### Smart Contract Structure

```text
BitVault Protocol
├── Core State Management
│   ├── Protocol Configuration
│   ├── Loan Registry
│   └── User Management
├── Risk Management System
│   ├── Collateral Calculation Engine
│   ├── Liquidation Assessment
│   └── Interest Accrual Logic
├── Oracle Integration
│   ├── Price Feed Management
│   └── Asset Support Registry
└── Governance Functions
    ├── Parameter Updates
    └── Protocol Administration
```

### Data Models

#### Loan Registry

```clarity
{
  borrower: principal,
  collateral-amount: uint,
  borrowed-amount: uint,
  annual-interest-rate: uint,
  creation-height: uint,
  last-update-height: uint,
  loan-status: (string-ascii 20)
}
```

#### Asset Price Registry

```clarity
{
  current-price: uint,
  last-updated: uint
}
```

## 🛠️ Development Setup

### Prerequisites

- [Clarinet CLI](https://github.com/hirosystems/clarinet) >= 2.0.0
- Node.js >= 18.0.0
- TypeScript >= 5.0.0

### Installation

```bash
# Clone the repository
git clone https://github.com/fredrick-paul/bitvault.git
cd bitvault

# Install dependencies
npm install

# Install Clarinet (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://install.clarinet.so | sh
```

### Project Structure

```text
bitvault/
├── contracts/
│   └── bitvault.clar          # Main protocol contract
├── tests/
│   └── bitvault.test.ts       # Comprehensive test suite
├── settings/
│   ├── Devnet.toml           # Development network config
│   ├── Testnet.toml          # Testnet configuration
│   └── Mainnet.toml          # Mainnet configuration
├── Clarinet.toml             # Clarinet project configuration
├── package.json              # Node.js dependencies
├── tsconfig.json            # TypeScript configuration
└── vitest.config.js         # Testing framework config
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage and cost analysis
npm run test:report

# Watch mode for development
npm run test:watch

# Check contract syntax and analysis
clarinet check
```

### Contract Validation

```bash
# Format contracts
clarinet fmt --in-place

# Run static analysis
clarinet check --costs

# Generate documentation
clarinet docs
```

## 📋 Protocol Operations

### Core Functions

#### Initialization

```clarity
;; Initialize the protocol (owner only)
(initialize-protocol)
```

#### Collateral Management

```clarity
;; Deposit collateral
(deposit-collateral (collateral-amount uint))

;; Create new loan
(originate-loan (collateral-amount uint) (requested-loan-amount uint))

;; Repay loan
(repay-loan-full (loan-id uint) (repayment-amount uint))
```

#### Protocol Risk Management

```clarity
;; Update collateral requirements (governance)
(update-collateral-requirements (new-min-ratio uint))

;; Update liquidation parameters (governance)
(update-liquidation-parameters (new-liquidation-ratio uint))

;; Update asset prices (oracle)
(update-asset-price (asset-symbol (string-ascii 3)) (new-price uint))
```

### Read-Only Functions

#### Loan Information

```clarity
;; Get loan details
(get-loan-info (loan-id uint))

;; Get user's active loans
(get-user-active-loans (borrower principal))

;; Calculate loan health ratio
(calculate-loan-health (loan-id uint))
```

#### Protocol Metrics

```clarity
;; Get protocol statistics
(get-protocol-metrics)

;; Get asset price
(get-asset-price (asset-symbol (string-ascii 3)))

;; Get supported assets
(get-supported-assets)
```

## 🔢 Protocol Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Minimum Collateral Ratio | 150% | Minimum required collateral for new loans |
| Liquidation Threshold | 120% | Ratio at which loans become eligible for liquidation |
| Protocol Fee | 1% | Fee charged on loan origination |
| Max Loans Per User | 10 | Maximum concurrent loans per address |
| Blocks Per Day | 144 | Stacks blockchain block production rate |

## 📊 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | ERR-UNAUTHORIZED | Caller not authorized for operation |
| 101 | ERR-INSUFFICIENT-COLLATERAL | Collateral amount insufficient for loan |
| 102 | ERR-AMOUNT-TOO-LOW | Amount below minimum threshold |
| 103 | ERR-INVALID-AMOUNT | Invalid amount provided |
| 104 | ERR-ALREADY-INITIALIZED | Protocol already initialized |
| 105 | ERR-NOT-INITIALIZED | Protocol not initialized |
| 106 | ERR-INVALID-LIQUIDATION | Invalid liquidation attempt |
| 107 | ERR-LOAN-NOT-FOUND | Loan ID does not exist |
| 108 | ERR-LOAN-INACTIVE | Loan is not in active state |
| 109 | ERR-INVALID-LOAN-ID | Loan ID out of valid range |
| 110 | ERR-INVALID-PRICE-DATA | Price data validation failed |
| 111 | ERR-UNSUPPORTED-ASSET | Asset not supported by protocol |

## 🔐 Security Considerations

### Access Control

- **Owner-Only Functions**: Protocol initialization, parameter updates, price feeds
- **User-Specific Operations**: Loan management restricted to loan owners
- **Input Validation**: Comprehensive validation for all user inputs

### Risk Mitigation

- **Collateral Requirements**: Over-collateralization to protect against volatility
- **Liquidation Mechanisms**: Automated liquidation to prevent protocol insolvency
- **Price Oracle Security**: Validation of price data integrity
- **Rate Limiting**: Maximum loans per user to prevent abuse

### Best Practices

- **Immutable Logic**: Core protocol logic cannot be changed post-deployment
- **Transparent Operations**: All protocol state changes are publicly verifiable
- **Fail-Safe Defaults**: Conservative default parameters for risk management

## 📈 Protocol Metrics & Analytics

### Key Performance Indicators

- **Total Value Locked (TVL)**: Total BTC collateral in the protocol
- **Loan Utilization**: Active loans vs. available collateral
- **Liquidation Rate**: Percentage of loans requiring liquidation
- **Interest Revenue**: Total interest collected by the protocol

### Monitoring Tools

- Real-time loan health monitoring
- Collateral ratio tracking
- Price feed reliability metrics
- Protocol utilization analytics

## 🚀 Deployment

### Network Configurations

#### Devnet Deployment

```bash
# Deploy to devnet
clarinet deployments generate --devnet
clarinet deployments apply --devnet
```

#### Testnet Deployment

```bash
# Deploy to testnet
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

#### Mainnet Deployment

```bash
# Deploy to mainnet (production)
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

## 🤝 Contributing

We welcome contributions to BitVault Protocol! Please follow these guidelines:

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write comprehensive tests for new functionality
4. Ensure all tests pass (`npm test`)
5. Run contract validation (`clarinet check`)
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Create a Pull Request

### Code Standards

- Follow Clarity best practices and conventions
- Maintain comprehensive test coverage (>90%)
- Include detailed inline documentation
- Validate all contracts before submission

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
