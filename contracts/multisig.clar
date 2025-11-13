;; Import the SIP-010 fungible token trait

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant MAX_SIGNERS u100)
(define-constant MIN_SIGNATURES_REQUIRED u1)

;; Errors
(define-constant ERR_OWNER_ONLY (err u500))
(define-constant ERR_ALREADY_INITIALIZED (err u501))
(define-constant ERR_TOO_MANY_SIGNERS (err u502))
(define-constant ERR_TOO_FEW_SIGNATURES_REQUIRED (err u503))
(define-constant ERR_NOT_A_SIGNER (err u504))
(define-constant ERR_INVALID_TX_TYPE (err u505))
(define-constant ERR_NO_TOKEN_CONTRACT_FOR_SIP010_TRANSFER (err u506))
(define-constant ERR_INVALID_TXN_ID (err u507))
(define-constant ERR_INVALID_AMOUNT (err u508))
(define-constant ERR_MIN_THRESHOLD_NOT_MET (err u509))
(define-constant ERR_INVALID_TOKEN_CONTACT (err u510))
(define-constant ERR_NOT_INITIALIZED (err u511))
(define-constant ERR_UNEXPECTED (err u999))

;; Storage Vars 
(define-data-var initialized bool false)
(define-data-var signers (list 100 principal) (list))
(define-data-var threshold uint u0)

(define-data-var txn-id uint u0)
(define-map transactions
    { id: uint }
    {
        type: uint,
        amount: uint,
        recipient: principal,
        token: (optional principal),
        executed: bool,
    }
)

(define-map txn-signers
    {
        id: uint,
        member: principal,
    }
    { has-signed: bool }
)

;; Public functions 
;; Initialize the contract with the given signers and threshold
;; Can only be called once by the contract owner

(define-public (initialize
        (new-signers (list 100 principal))
        (min-threshold uint)
    )
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
        (asserts! (is-eq (var-get initialized) false) ERR_ALREADY_INITIALIZED)
        (asserts! (<= (len new-signers) MAX_SIGNERS) ERR_TOO_MANY_SIGNERS)
        (asserts! (>= min-threshold MIN_SIGNATURES_REQUIRED)
            ERR_MIN_THRESHOLD_NOT_MET
        )
        (var-set signers new-signers)
        (var-set threshold min-threshold)
        (var-set initialized true)
        (ok true)
    )
)

;; Submit a new transaction to the multisig contract
;; can only be called by a signer
;; The transaction can be a transfer of STX or a SIP-010 transfer of a fungible token
;; The transaction can be of type 0 (STX transfer) or type 1 (SIP-010)
;; If the transaction is not executed immediately, but added to the transactions map
;; The transaction ID is returned

(define-public (submit-txn
        (type uint)
        (amount uint)
        (recipient principal)
        (token (optional principal))
    )
    (let ((id (var-get txn-id)))
        ;; Check if the contract is initialized
        (asserts! (is-eq (var-get initialized) true) ERR_NOT_INITIALIZED)
        ;; Check if the sender is a signer
        (asserts! (is-some (index-of? (var-get signers) tx-sender))
            ERR_NOT_A_SIGNER
        )
        ;; Check if the amount is greater than 0
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        ;; Check if the type is valid (0 for STX transfer, 1 for SIP-010 transfer)
        (asserts! (or (is-eq type u0) (is-eq type u1)) ERR_INVALID_TX_TYPE)
        ;; Check if the token is provided for SIP-010 transfers
        (if (is-eq type u1)
            (asserts! (is-some token) ERR_NO_TOKEN_CONTRACT_FOR_SIP010_TRANSFER)
            (asserts! true ERR_UNEXPECTED)
        )
        ;; Update the transactions map with the new transaction
        (map-set transactions { id: id } {
            type: type,
            amount: amount,
            recipient: recipient,
            token: token,
            executed: false,
        })
        ;; Increment the transaction ID
        (var-set txn-id (+ id u1))
        ;; Print the transaction details
        (print {
            action: "submit txn",
            type: type,
            amount: amount,
            recipient: recipient,
            token: token,
            submitter: tx-sender,
        })
        (ok id)
    )
)

;; Execute a SIP-010 transfer transaction
;; can only be a called by a signer
;; the transaction must have been submitted by a signer
;; the transaction must have been signed by the required number of signers
;; the transaction is executed by transferring the fungible token to the recipient 

(define-public (execute-token-transfer-txn
        (id uint)
        (token <ft-trait>)
        (signatures (list 100 (buff 65)))
    )
    (ok true)
)

;; Execute an STX transfer tranaction
;; Can only be called by a signer 
;; The transaction must have been submitted by a signer
;; The transaction must have been signed by the required number of signers
;; The transaction is executed by transferring the STX to the recipient
;; The transaction ID is returned

(define-public (execute-stx-transfer-txn
        (id uint)
        (signatures (list 100 (buff 65)))
    )
    (ok true)
)

;; Read only functions
;; Hash a transaction
;; Returns the hash of the transaction

(define-read-only (hash-txn (id uint))
    (ok true)
)

;; Extract the signer from a signature
;; Returns the signer 
(define-read-only (extract-signer
        (msg-hash (buff 32))
        (signature (buff 65))
    )
    (ok true)
)

;; Private Functions
;; Count the number of valid unique signatures for a transaction
;; Returns the number of valid unique signatures for a transaction
;; Returns the number of valid unique signatures

(define-private (count-valid-unique-signature
        (signature (buff 65))
        (accumulator {
            id: uint,
            hash: (buff 32),
            count: uint,
        })
    )
    (ok true)
)
