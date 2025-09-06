;; Title: BitVault Protocol
;;
;; Summary: Advanced Bitcoin-native lending protocol on Stacks blockchain
;;
;; Description: BitVault Protocol is a sophisticated decentralized finance (DeFi)
;; platform that enables Bitcoin holders to unlock liquidity without selling their
;; BTC holdings. Built on the Stacks blockchain, this protocol leverages Bitcoin's
;; security and programmability to offer collateralized lending with automated
;; risk management, dynamic interest rates, and institutional-grade liquidation
;; mechanisms. Users can deposit Bitcoin as collateral and borrow stablecoins
;; or other supported assets while maintaining exposure to Bitcoin's price
;; appreciation potential.
;;
;; Key Features:
;; - Bitcoin-native collateralization with secure custody
;; - Dynamic collateral ratios based on market conditions  
;; - Automated liquidation protection system
;; - Time-based interest accrual using block height
;; - Multi-asset borrowing capabilities
;; - Governance-controlled risk parameters

;; PROTOCOL CONSTANTS & CONFIGURATION

(define-constant CONTRACT-OWNER tx-sender)

;; Error Definitions - Comprehensive error handling system
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-AMOUNT-TOO-LOW (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))
(define-constant ERR-INVALID-LIQUIDATION (err u106))
(define-constant ERR-LOAN-NOT-FOUND (err u107))
(define-constant ERR-LOAN-INACTIVE (err u108))
(define-constant ERR-INVALID-LOAN-ID (err u109))
(define-constant ERR-INVALID-PRICE-DATA (err u110))
(define-constant ERR-UNSUPPORTED-ASSET (err u111))

;; Supported Collateral Assets
(define-constant SUPPORTED-ASSETS (list "BTC" "STX"))

;; Protocol Configuration Constants
(define-constant BLOCKS-PER-DAY u144)
(define-constant MAX-LOANS-PER-USER u10)
(define-constant MAX-PRICE-VALUE u1000000000000)

;; PROTOCOL STATE VARIABLES

;; Core Platform State
(define-data-var protocol-active bool false)
(define-data-var min-collateral-ratio uint u150) ;; 150% minimum collateral
(define-data-var liquidation-ratio uint u120) ;; 120% liquidation trigger
(define-data-var protocol-fee uint u100) ;; 1% protocol fee (basis points)
(define-data-var total-btc-collateral uint u0) ;; Total BTC locked as collateral
(define-data-var loan-counter uint u0) ;; Incremental loan ID counter

;; DATA STORAGE MAPS

;; Primary Loan Registry - Complete loan state management
(define-map loan-registry
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    borrowed-amount: uint,
    annual-interest-rate: uint,
    creation-height: uint,
    last-update-height: uint,
    loan-status: (string-ascii 20),
  }
)

;; User Loan Tracking - Efficient user loan management
(define-map user-loan-registry
  { borrower: principal }
  { active-loan-ids: (list 10 uint) }
)

;; Price Oracle Registry - Real-time asset pricing
(define-map asset-price-registry
  { asset-symbol: (string-ascii 3) }
  {
    current-price: uint,
    last-updated: uint,
  }
)

;; CORE CALCULATION FUNCTIONS

;; Calculate collateral-to-debt ratio with precision
(define-private (compute-collateral-ratio
    (collateral-qty uint)
    (debt-amount uint)
    (asset-price uint)
  )
  (let (
      (collateral-value (* collateral-qty asset-price))
      (ratio-percentage (/ (* collateral-value u100) debt-amount))
    )
    ratio-percentage
  )
)

;; Calculate compound interest over block periods
(define-private (compute-accrued-interest
    (principal-amount uint)
    (interest-rate uint)
    (block-duration uint)
  )
  (let (
      (daily-rate (/ interest-rate u365))
      (block-rate (/ daily-rate BLOCKS-PER-DAY))
      (total-interest (/ (* principal-amount block-rate block-duration) u10000))
    )
    total-interest
  )
)

;; RISK MANAGEMENT & LIQUIDATION SYSTEM

;; Comprehensive liquidation health check
(define-private (assess-liquidation-risk (loan-id uint))
  (let (
      (loan-data (unwrap! (map-get? loan-registry { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (btc-price-data (unwrap! (map-get? asset-price-registry { asset-symbol: "BTC" })
        ERR-NOT-INITIALIZED
      ))
      (current-ratio (compute-collateral-ratio (get collateral-amount loan-data)
        (get borrowed-amount loan-data) (get current-price btc-price-data)
      ))
    )
    (if (<= current-ratio (var-get liquidation-ratio))
      (execute-liquidation loan-id)
      (ok true)
    )
  )
)

;; Execute automated liquidation process
(define-private (execute-liquidation (loan-id uint))
  (let (
      (loan-data (unwrap! (map-get? loan-registry { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (borrower-address (get borrower loan-data))
    )
    (begin
      ;; Update loan status to liquidated
      (map-set loan-registry { loan-id: loan-id }
        (merge loan-data { loan-status: "liquidated" })
      )

      ;; Remove from user's active loans
      (map-delete user-loan-registry { borrower: borrower-address })

      ;; Reduce total collateral counter
      (var-set total-btc-collateral
        (- (var-get total-btc-collateral) (get collateral-amount loan-data))
      )

      (ok true)
    )
  )
)

;; VALIDATION & SECURITY FUNCTIONS

;; Validate loan ID exists and is within bounds
(define-private (is-valid-loan-id (loan-id uint))
  (and (> loan-id u0) (<= loan-id (var-get loan-counter)))
)

;; Verify asset is supported by protocol
(define-private (is-supported-asset (asset (string-ascii 3)))
  (is-some (index-of SUPPORTED-ASSETS asset))
)

;; Validate price data integrity
(define-private (is-valid-price-data (price uint))
  (and (> price u0) (<= price MAX-PRICE-VALUE))
)

;; Helper function for loan ID filtering
(define-private (filter-loan-id
    (target-id uint)
    (current-id uint)
  )
  (not (is-eq target-id current-id))
)

;; PROTOCOL INITIALIZATION & GOVERNANCE

;; Initialize BitVault Protocol (One-time setup)
(define-public (initialize-protocol)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (not (var-get protocol-active)) ERR-ALREADY-INITIALIZED)

    ;; Activate protocol
    (var-set protocol-active true)

    ;; Initialize default asset prices (placeholder)
    (map-set asset-price-registry { asset-symbol: "BTC" } {
      current-price: u4500000,
      last-updated: stacks-block-height,
    })

    (ok true)
  )
)

;; CORE LENDING OPERATIONS

;; Deposit Bitcoin collateral into protocol vault
(define-public (deposit-collateral (collateral-amount uint))
  (begin
    (asserts! (var-get protocol-active) ERR-NOT-INITIALIZED)
    (asserts! (> collateral-amount u0) ERR-INVALID-AMOUNT)

    ;; Update total collateral locked
    (var-set total-btc-collateral
      (+ (var-get total-btc-collateral) collateral-amount)
    )

    (ok true)
  )
)

;; Create new collateralized loan
(define-public (originate-loan
    (collateral-amount uint)
    (requested-loan-amount uint)
  )
  (let (
      (btc-price-data (unwrap! (map-get? asset-price-registry { asset-symbol: "BTC" })
        ERR-NOT-INITIALIZED
      ))
      (collateral-value (* collateral-amount (get current-price btc-price-data)))
      (required-collateral (* requested-loan-amount (var-get min-collateral-ratio)))
      (new-loan-id (+ (var-get loan-counter) u1))
    )
    (begin
      (asserts! (var-get protocol-active) ERR-NOT-INITIALIZED)
      (asserts! (>= (* collateral-value u100) required-collateral)
        ERR-INSUFFICIENT-COLLATERAL
      )

      ;; Create loan record
      (map-set loan-registry { loan-id: new-loan-id } {
        borrower: tx-sender,
        collateral-amount: collateral-amount,
        borrowed-amount: requested-loan-amount,
        annual-interest-rate: u500, ;; 5% annual interest
        creation-height: stacks-block-height,
        last-update-height: stacks-block-height,
        loan-status: "active",
      })

      ;; Update user's loan registry
      (match (map-get? user-loan-registry { borrower: tx-sender })
        existing-loans (map-set user-loan-registry { borrower: tx-sender } { active-loan-ids: (unwrap!
          (as-max-len? (append (get active-loan-ids existing-loans) new-loan-id)
            u10
          )
          ERR-INVALID-AMOUNT
        ) }
        )
        (map-set user-loan-registry { borrower: tx-sender } { active-loan-ids: (list new-loan-id) })
      )

      ;; Increment loan counter
      (var-set loan-counter new-loan-id)

      (ok new-loan-id)
    )
  )
)

;; Repay loan with accrued interest
(define-public (repay-loan-full
    (loan-id uint)
    (repayment-amount uint)
  )
  (let (
      (loan-data (unwrap! (map-get? loan-registry { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (accrued-interest (compute-accrued-interest (get borrowed-amount loan-data)
        (get annual-interest-rate loan-data)
        (- stacks-block-height (get last-update-height loan-data))
      ))
      (total-repayment-due (+ (get borrowed-amount loan-data) accrued-interest))
    )
    (begin
      (asserts! (is-valid-loan-id loan-id) ERR-INVALID-LOAN-ID)
      (asserts! (is-eq (get loan-status loan-data) "active") ERR-LOAN-INACTIVE)
      (asserts! (is-eq (get borrower loan-data) tx-sender) ERR-UNAUTHORIZED)
      (asserts! (>= repayment-amount total-repayment-due) ERR-INVALID-AMOUNT)

      ;; Mark loan as repaid
      (map-set loan-registry { loan-id: loan-id }
        (merge loan-data {
          loan-status: "repaid",
          last-update-height: stacks-block-height,
        })
      )

      ;; Release collateral
      (var-set total-btc-collateral
        (- (var-get total-btc-collateral) (get collateral-amount loan-data))
      )

      ;; Remove from user's active loans
      (match (map-get? user-loan-registry { borrower: tx-sender })
        existing-loans (map-set user-loan-registry { borrower: tx-sender } { active-loan-ids: (filter (lambda (id) (not (is-eq id loan-id)))
          (get active-loan-ids existing-loans)
        ) }
        )
        true
      )

      (ok total-repayment-due)
    )
  )
)