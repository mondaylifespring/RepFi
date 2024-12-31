# RepFi: Decentralized Identity Lending Protocol

RepFi is a decentralized lending protocol built on the Stacks blockchain that uses on-chain reputation and identity to enable collateralized loans with dynamic interest rates. By leveraging blockchain-based credit scoring, RepFi creates a transparent and efficient lending ecosystem.

## Core Features

- **Credit Score System**: Users start with a base score of 500, which can increase to 1000 based on repayment history
- **Dynamic Interest Rates**: Base rate of 10% that decreases based on credit score (minimum 5%)
- **Smart Collateral Management**: 150% collateralization ratio requirement
- **Loan Limits**: Maximum of 3 active loans per user
- **Reputation Building**: +10 points for successful repayments, -50 points for defaults

## Smart Contract Architecture

The protocol consists of the following main components:

### User Profile Management
- Credit score tracking (500-1000 range)
- Active loan counting
- Total borrowed/repaid amount tracking
- Automatic profile initialization

### Loan Management
- Automated loan creation
- Dynamic interest rate calculation
- Collateral verification
- Repayment processing
- Active loan status tracking

### Key Functions

1. **Profile Management**
```clarity
;; Initialize user profile
(define-public (initialize-profile))

;; Get user profile details
(define-read-only (get-user-profile (user principal)))
```

2. **Loan Operations**
```clarity
;; Request new loan
(define-public (request-loan (amount uint) (collateral uint)))

;; Repay existing loan
(define-public (repay-loan (loan-id uint)))

;; Get loan details
(define-read-only (get-loan-details (loan-id uint)))

;; Get user's active loans summary
(define-read-only (get-user-active-loans (user principal)))

;; Get specific loan status
(define-read-only (get-loan-status (loan-id uint)))
```

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

### Usage Examples

1. Initialize a new user profile:
```clarity
(contract-call? .repfi initialize-profile)
```

2. Request a loan (amount and collateral in microSTX):
```clarity
;; Request 1000 STX loan with 1500 STX collateral
(contract-call? .repfi request-loan u1000000000 u1500000000)
```

3. Check your profile:
```clarity
(contract-call? .repfi get-user-profile tx-sender)
```

4. Repay a loan:
```clarity
(contract-call? .repfi repay-loan u1)
```

5. View active loans:
```clarity
(contract-call? .repfi get-user-active-loans tx-sender)
```

## Protocol Parameters

- Initial Credit Score: 500
- Maximum Credit Score: 1000
- Base Interest Rate: 10%
- Minimum Interest Rate: 5%
- Collateral Ratio: 150%
- Maximum Active Loans: 3
- Credit Score Increase: +10 per repayment
- Credit Score Decrease: -50 per default

## Security Considerations

- All functions include proper authorization checks
- Credit score updates are controlled and bounded
- Collateral requirements are strictly enforced
- Active loan limits prevent over-leveraging
- Status tracking prevents duplicate repayments

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
