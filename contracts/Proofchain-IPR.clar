;; ProofChain.clar
;; ProofChain - Intellectual Property Registrar (v1.0)
;; Author: (your name)
;; Simple, readable, Clarinet-friendly

;; Owner is stored as a data var so the deployer becomes initial owner.
(define-data-var admin principal tx-sender)

;; Record map: keyed by the content hash (string-ascii 64)
(define-map ip-records
  { hash: (string-ascii 64) }
  {
    owner: principal,
    metadata: (string-ascii 128), ;; optional metadata or IPFS CID
    registered-at: uint,          ;; block-height when registered
    active: bool
  }
)

;; Events
;; Events (use print-event for Clarity v1)
(define-constant ip-registered-event "ip-registered")
(define-constant ip-transferred-event "ip-transferred")
(define-constant ip-revoked-event "ip-revoked")
(define-constant ip-metadata-updated-event "ip-metadata-updated")
;; Usage: (print-event event-name event-data)

;; ----------------------------
;; Admin helpers
;; ----------------------------

(define-read-only (get-admin)
  (ok (var-get admin))
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err "NOT_ADMIN"))
  (var-set admin new-admin)
    (ok new-admin)
  )
)

;; ----------------------------
;; Core functions
;; ----------------------------

;; Register a new IP hash. `hash` should be the SHA-256 (or other) fingerprint of the work.
;; `metadata` can hold an IPFS CID, short description, or license string.
(define-public (register-ip (hash (string-ascii 64)) (metadata (string-ascii 128)))
  (begin
    ;; ensure not already registered or currently active
    (match (map-get? ip-records {hash: hash})
      some-record
      (if (get active some-record)
          (err "ALREADY_REGISTERED")
          ;; If inactive (revoked), allow re-register only by original admin or allow re-register by anyone?
          ;; Here we disallow re-register by anyone to preserve immutability; to allow, remove this branch.
          (err "ALREADY_EXISTS_INACTIVE")
      )
      ;; none => create record
      (begin
        (map-set ip-records {hash: hash}
          {
            owner: tx-sender,
            metadata: metadata,
            registered-at: u0,
            active: true
          })
  (print {event: ip-registered-event, hash: hash, owner: tx-sender, registered-at: u0})
        (ok (tuple (hash hash) (owner tx-sender)))
      )
    )
  )
)

;; Transfer ownership of a registered IP (only current owner can transfer)
(define-public (transfer-ip (hash (string-ascii 64)) (new-owner principal))
  (match (map-get? ip-records {hash: hash})
    some-record
    (let ((current-owner (get owner some-record)) (is-active (get active some-record)))
      (begin
        (asserts! is-active (err "NOT_ACTIVE"))
        (asserts! (is-eq tx-sender current-owner) (err "NOT_OWNER"))
  (map-set ip-records {hash: hash}
          {
            owner: new-owner,
            metadata: (get metadata some-record),
            registered-at: (get registered-at some-record),
            active: true
          })
  (print {event: ip-transferred-event, hash: hash, from: current-owner, to: new-owner})
        (ok new-owner)
      )
    )
    (err "NOT_FOUND")
  )
)

;; Owner can update metadata (e.g., point to IPFS with updated CID)
(define-public (update-metadata (hash (string-ascii 64)) (new-metadata (string-ascii 128)))
  (match (map-get? ip-records {hash: hash})
    some-record
    (let ((current-owner (get owner some-record)) (is-active (get active some-record)))
      (begin
        (asserts! is-active (err "NOT_ACTIVE"))
        (asserts! (is-eq tx-sender current-owner) (err "NOT_OWNER"))
  (map-set ip-records {hash: hash}
          {
            owner: current-owner,
            metadata: new-metadata,
            registered-at: (get registered-at some-record),
            active: true
          })
  (print {event: ip-metadata-updated-event, hash: hash, owner: current-owner, metadata: new-metadata})
        (ok new-metadata)
      )
    )
    (err "NOT_FOUND")
  )
)

;; Revoke a registration (owner-only). This doesn't delete the record; it marks as inactive.
(define-public (revoke-ip (hash (string-ascii 64)))
  (match (map-get? ip-records {hash: hash})
    some-record
    (let ((current-owner (get owner some-record)) (is-active (get active some-record)))
      (begin
        (asserts! is-active (err "ALREADY_INACTIVE"))
        (asserts! (is-eq tx-sender current-owner) (err "NOT_OWNER"))
  (map-set ip-records {hash: hash}
          {
            owner: current-owner,
            metadata: (get metadata some-record),
            registered-at: (get registered-at some-record),
            active: false
          })
  (print {event: ip-revoked-event, hash: hash, owner: current-owner})
        (ok "REVOKED")
      )
    )
    (err "NOT_FOUND")
  )
)

;; ----------------------------
;; Read-only helpers
;; ----------------------------

;; Fetch full record by hash
(define-read-only (get-record (hash (string-ascii 64)))
  (map-get? ip-records {hash: hash})
)

;; Check whether a hash is registered and active

(define-read-only (is-registered (hash (string-ascii 64)))
  (match (map-get? ip-records {hash: hash})
    some-record (ok (get active some-record))
    (ok false)
  )
)
