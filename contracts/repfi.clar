;; RepFi - Decentralized Identity Lending Protocol
;; A reputation-based lending system built on Stacks

;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-BALANCE (err u2))
(define-constant ERR-INVALID-AMOUNT (err u3))
(define-constant ERR-LOW-CREDIT-SCORE (err u4))
(define-constant MAX-CREDIT-SCORE u1000)
(define-constant MIN-CREDIT-SCORE u0)

;; Data Variables
(define-data-var minimum-credit-score uint u500)
(define-data-var collateral-ratio uint u150) ;; 150% collateralization ratio
(define-data-var next-loan-id uint u0)

;; Data Maps
(define-map user-profiles
    principal
    {
        credit-score: uint,
        total-borrowed: uint,
        total-repaid: uint,
        active-loans: uint,
        last-repayment: uint
    }
)

(define-map loans
    uint
    {
        borrower: principal,
        amount: uint,
        collateral: uint,
        due-date: uint,
        status: (string-ascii 20),
        interest-rate: uint
    }
)

;; Initialize user profile
(define-public (initialize-profile)
    (let ((sender tx-sender))
        (ok (map-set user-profiles
            sender
            {
                credit-score: u500,
                total-borrowed: u0,
                total-repaid: u0,
                active-loans: u0,
                last-repayment: u0
            }
        ))
    )
)

;; Request loan
(define-public (request-loan (amount uint) (collateral uint))
    (let (
        (sender tx-sender)
        (user-data (unwrap! (map-get? user-profiles sender) ERR-NOT-AUTHORIZED))
        )
        
        ;; Check credit score
        (asserts! (>= (get credit-score user-data) (var-get minimum-credit-score))
            ERR-LOW-CREDIT-SCORE)
        
        ;; Check collateral ratio
        (asserts! (>= (* collateral u100) (* amount (var-get collateral-ratio)))
            ERR-INSUFFICIENT-BALANCE)
        
        ;; Create loan
        (ok (create-loan sender amount collateral))
    )
)

;; Private function to create loan
(define-private (create-loan (borrower principal) (amount uint) (collateral uint))
    (let ((loan-id (+ (var-get next-loan-id) u1)))
        (map-set loans
            loan-id
            {
                borrower: borrower,
                amount: amount,
                collateral: collateral,
                due-date: (+ block-height u1440), ;; Due in ~10 days
                status: "active",
                interest-rate: u500 ;; 5% interest rate
            }
        )
        (var-set next-loan-id loan-id)
        loan-id
    )
)

;; Repay loan
(define-public (repay-loan (loan-id uint))
    (let (
        (loan (unwrap! (map-get? loans loan-id) ERR-NOT-AUTHORIZED))
        (sender tx-sender)
        )
        
        ;; Verify sender is borrower
        (asserts! (is-eq sender (get borrower loan)) ERR-NOT-AUTHORIZED)
        
        ;; Update loan status and user profile
        (begin
            (map-set loans loan-id (merge loan { status: "repaid" }))
            (unwrap! (update-user-profile sender true) ERR-NOT-AUTHORIZED)
            (ok true)
        )
    )
)

;; Private function to update user profile
(define-private (update-user-profile (user principal) (positive bool))
    (let (
        (profile (unwrap! (map-get? user-profiles user) ERR-NOT-AUTHORIZED))
        (current-score (get credit-score profile))
        (new-score (if positive
            (if (>= (+ current-score u10) MAX-CREDIT-SCORE)
                MAX-CREDIT-SCORE
                (+ current-score u10))
            (if (<= (- current-score u50) MIN-CREDIT-SCORE)
                MIN-CREDIT-SCORE
                (- current-score u50))))
        )
        (begin
            (map-set user-profiles
                user
                (merge profile { credit-score: new-score })
            )
            (ok new-score)
        )
    )
)

;; Getter for user profile
(define-read-only (get-user-profile (user principal))
    (map-get? user-profiles user)
)

;; Getter for loan details
(define-read-only (get-loan-details (loan-id uint))
    (map-get? loans loan-id)
)