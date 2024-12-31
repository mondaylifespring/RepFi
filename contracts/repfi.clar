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
(define-constant BASE-INTEREST-RATE u1000) ;; 10% base rate
(define-constant MAX-ACTIVE-LOANS u3)

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

;; Calculate interest rate based on credit score
(define-private (calculate-interest-rate (credit-score uint))
    (let (
        (score-factor (/ (* credit-score u100) MAX-CREDIT-SCORE))
        (rate-reduction (/ (* score-factor u500) u100)) ;; Up to 5% reduction
        )
        (if (>= rate-reduction BASE-INTEREST-RATE)
            u500 ;; Minimum 5% interest rate
            (- BASE-INTEREST-RATE rate-reduction))
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
        
        ;; Check active loans limit
        (asserts! (< (get active-loans user-data) MAX-ACTIVE-LOANS)
            ERR-NOT-AUTHORIZED)
        
        ;; Create loan
        (create-loan sender amount collateral)
    )
)

;; Private function to create loan
(define-private (create-loan (borrower principal) (amount uint) (collateral uint))
    (let (
        (loan-id (+ (var-get next-loan-id) u1))
        (user-data (unwrap! (map-get? user-profiles borrower) ERR-NOT-AUTHORIZED))
        (interest-rate (calculate-interest-rate (get credit-score user-data)))
        )
        (begin
            (map-set loans
                loan-id
                {
                    borrower: borrower,
                    amount: amount,
                    collateral: collateral,
                    due-date: (+ block-height u1440), ;; Due in ~10 days
                    status: "active",
                    interest-rate: interest-rate
                }
            )
            ;; Update user's active loans count
            (map-set user-profiles
                borrower
                (merge user-data { 
                    active-loans: (+ (get active-loans user-data) u1),
                    total-borrowed: (+ (get total-borrowed user-data) amount)
                })
            )
            (var-set next-loan-id loan-id)
            (ok loan-id)
        )
    )
)

;; Get all active loans for a user
(define-read-only (get-user-active-loans (user principal))
    (let (
        (user-data (unwrap! (map-get? user-profiles user) ERR-NOT-AUTHORIZED))
        (active-count (get active-loans user-data))
        )
        (ok {
            active-loan-count: active-count,
            total-borrowed: (get total-borrowed user-data),
            total-repaid: (get total-repaid user-data)
        })
    )
)

;; Get specific loan status
(define-read-only (get-loan-status (loan-id uint))
    (match (map-get? loans loan-id)
        loan (ok {
            status: (get status loan),
            amount: (get amount loan),
            interest-rate: (get interest-rate loan),
            due-date: (get due-date loan)
        })
        ERR-NOT-AUTHORIZED
    )
)

;; Repay loan
(define-public (repay-loan (loan-id uint))
    (let (
        (loan (unwrap! (map-get? loans loan-id) ERR-NOT-AUTHORIZED))
        (sender tx-sender)
        (user-data (unwrap! (map-get? user-profiles sender) ERR-NOT-AUTHORIZED))
        )
        
        ;; Verify sender is borrower
        (asserts! (is-eq sender (get borrower loan)) ERR-NOT-AUTHORIZED)
        
        ;; Update loan status and user profile
        (begin
            (map-set loans loan-id (merge loan { status: "repaid" }))
            (map-set user-profiles
                sender
                (merge user-data { 
                    active-loans: (- (get active-loans user-data) u1),
                    total-repaid: (+ (get total-repaid user-data) (get amount loan))
                })
            )
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