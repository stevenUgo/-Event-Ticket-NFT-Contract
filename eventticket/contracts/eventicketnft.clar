;; Event Ticket NFT Contract

;; Constants
(define-constant event-organizer tx-sender)
(define-constant err-organizer-only (err u300))
(define-constant err-not-ticket-holder (err u301))
(define-constant err-ticket-not-found (err u302))
(define-constant err-ticket-already-used (err u303))
(define-constant err-event-not-active (err u304))
(define-constant err-invalid-input (err u305))
(define-constant err-empty-string (err u306))
(define-constant err-invalid-date (err u307))
(define-constant err-invalid-price (err u308))

;; Define the non-fungible token
(define-non-fungible-token event-ticket uint)

;; Data Variables
(define-data-var current-ticket-id uint u0)

;; Data Maps
(define-map ticket-information uint 
  {
    event-name: (string-ascii 150),
    venue-location: (string-ascii 100),
    event-date: uint,
    ticket-tier: (string-ascii 50),
    is-used: bool,
    purchase-price: uint
  }
)

(define-map event-status (string-ascii 150) bool)

;; Input validation helpers
(define-private (is-valid-event-name (input (string-ascii 150)))
  (> (len input) u0)
)

(define-private (is-valid-venue (input (string-ascii 100)))
  (> (len input) u0)
)

(define-private (is-valid-tier (input (string-ascii 50)))
  (> (len input) u0)
)

(define-private (is-valid-principal (input principal))
  (not (is-eq input 'SP000000000000000000002Q6VF78))
)

(define-private (is-valid-date (input uint))
  (> input stacks-block-height)
)

;; SIP-009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get current-ticket-id)))

;; SIP-009: Get the token URI
(define-read-only (get-token-uri (ticket-id uint))
  (ok none))

;; SIP-009: Get the owner of a ticket
(define-read-only (get-owner (ticket-id uint))
  (ok (nft-get-owner? event-ticket ticket-id)))

;; SIP-009: Transfer ticket
(define-public (transfer (ticket-id uint) (sender principal) (recipient principal))
  (let
    (
      (ticket-info (unwrap! (map-get? ticket-information ticket-id) err-ticket-not-found))
    )
    (asserts! (is-valid-principal sender) err-invalid-input)
    (asserts! (is-valid-principal recipient) err-invalid-input)
    (asserts! (not (is-eq sender recipient)) err-invalid-input)
    (asserts! (> ticket-id u0) err-invalid-input)
    (asserts! (is-eq tx-sender sender) err-not-ticket-holder)
    (asserts! (is-eq (get is-used ticket-info) false) err-ticket-already-used)
    (try! (nft-transfer? event-ticket ticket-id sender recipient))
    (ok true)
  )
)

;; Create new event ticket
(define-public (create-ticket (event-name (string-ascii 150)) (venue-location (string-ascii 100)) (event-date uint) (ticket-tier (string-ascii 50)) (purchase-price uint) (buyer principal))
  (let
    (
      (ticket-id (+ (var-get current-ticket-id) u1))
    )
    (asserts! (is-eq tx-sender event-organizer) err-organizer-only)
    (asserts! (is-valid-event-name event-name) err-empty-string)
    (asserts! (is-valid-venue venue-location) err-empty-string)
    (asserts! (is-valid-tier ticket-tier) err-empty-string)
    (asserts! (is-valid-principal buyer) err-invalid-input)
    (asserts! (is-valid-date event-date) err-invalid-date)
    (asserts! (>= purchase-price u0) err-invalid-price)
    (try! (nft-mint? event-ticket ticket-id buyer))
    (map-set ticket-information ticket-id
      {
        event-name: event-name,
        venue-location: venue-location,
        event-date: event-date,
        ticket-tier: ticket-tier,
        is-used: false,
        purchase-price: purchase-price
      }
    )
    (var-set current-ticket-id ticket-id)
    (ok ticket-id)
  )
)

;; Get ticket information
(define-read-only (get-ticket-information (ticket-id uint))
  (map-get? ticket-information ticket-id)
)

;; Use ticket for event entry
(define-public (use-ticket (ticket-id uint))
  (let
    (
      (ticket-owner (unwrap! (nft-get-owner? event-ticket ticket-id) err-ticket-not-found))
      (current-info (unwrap! (map-get? ticket-information ticket-id) err-ticket-not-found))
      (event-active (default-to false (map-get? event-status (get event-name current-info))))
    )
    (asserts! (> ticket-id u0) err-invalid-input)
    (asserts! (is-eq tx-sender ticket-owner) err-not-ticket-holder)
    (asserts! (is-eq (get is-used current-info) false) err-ticket-already-used)
    (asserts! event-active err-event-not-active)
    (map-set ticket-information ticket-id
      (merge current-info
        {
          is-used: true
        }
      )
    )
    (ok true)
  )
)

;; Activate event
(define-public (activate-event (event-name (string-ascii 150)))
  (begin
    (asserts! (is-eq tx-sender event-organizer) err-organizer-only)
    (asserts! (is-valid-event-name event-name) err-empty-string)
    (map-set event-status event-name true)
    (ok true)
  )
)
