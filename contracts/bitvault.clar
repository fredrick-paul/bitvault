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