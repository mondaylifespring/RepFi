# RepFi: Decentralized Identity Lending Protocol

RepFi is a decentralized lending protocol built on the Stacks blockchain that uses on-chain reputation and identity to enable under-collateralized loans. By leveraging blockchain-based credit scoring and the Proof of Transfer (PoX) mechanism, RepFi creates a transparent and efficient lending ecosystem.

## Features

- **Reputation-Based Lending**: Credit scoring system based on on-chain activity
- **Smart Contract-Managed Loans**: Automated loan creation, repayment, and liquidation
- **Dynamic Interest Rates**: Interest rates adjusted based on credit score
- **Collateral Management**: Flexible collateralization ratios based on credit score
- **Credit Score Building**: Reward responsible borrowing behavior

## Technical Architecture

### Smart Contracts

The protocol consists of the following main components:

1. **User Profiles Contract**
   - Manages user credit scores
   - Tracks borrowing history
   - Handles reputation updates

2. **Lending Contract**
   - Processes loan requests
   - Manages collateral
   - Handles repayments
   - Executes liquidations

3. **Credit Scoring Contract**
   - Calculates credit scores
   - Updates user reputation
   - Manages score modifiers

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Stacks Wallet](https://www.hiro.so/wallet) for interacting with the protocol
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/repfi.git
cd repfi
```

2. Install dependencies:
```bash
clarinet install
```

3. Run tests:
```bash
clarinet test
```

### Contract Deployment

1. Configure your deployment settings in `Clarinet.toml`
2. Deploy to testnet:
```bash
clarinet deploy --testnet
```

## Usage

### Initialize User Profile

```clarity
(contract-call? .repfi initialize-profile)
```

### Request Loan

```clarity
(contract-call? .repfi request-loan u1000000 u1500000)
```

### Repay Loan

```clarity
(contract-call? .repfi repay-loan u1)
```

## Security

- All smart contracts have been thoroughly tested
- Implements secure collateral management
- Includes emergency pause functionality
- Regular security audits planned

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

