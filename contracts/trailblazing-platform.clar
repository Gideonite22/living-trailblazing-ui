;; Living Trailblazing UI: Creative Writing Platform
;; Contract: trailblazing-platform
;;
;; A decentralized platform enabling collaborative creative writing experiences
;; through community-driven challenges, rewards, and interactive storytelling.

;; Error Codes
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-CHALLENGE-UNAVAILABLE (err u101))
(define-constant ERR-CHALLENGE-EXPIRED (err u102))
(define-constant ERR-CHALLENGE-ACTIVE (err u103))
(define-constant ERR-SUBMISSION-INVALID (err u104))
(define-constant ERR-VOTING-CLOSED (err u105))
(define-constant ERR-DUPLICATE-VOTE (err u106))
(define-constant ERR-INSUFFICIENT-STAKE (err u107))
(define-constant ERR-INVALID-CONFIG (err u108))
(define-constant ERR-SELF-ACTION-BLOCKED (err u109))
(define-constant ERR-REWARDS-UNAVAILABLE (err u110))

;; Platform Constants
(define-constant PLATFORM-CREATION-FEE u1000000) ;; 1 STX
(define-constant MIN-CHALLENGE-DURATION u43200) ;; Minimum 12 hours
(define-constant MAX-CHALLENGE-DURATION u1051200) ;; Maximum 6 months
(define-constant PLATFORM-FEE-PERCENT u5) ;; 5% platform fee
(define-constant DEFAULT-SUBMISSION-FEE u100000) ;; 0.1 STX

;; Global Platform State
(define-data-var platform-curator principal tx-sender)
(define-data-var challenge-sequence uint u0)
(define-data-var submission-sequence uint u0)

;; Challenge Data Structure
(define-map challenge-registry
  uint ;; challenge-id
  {
    curator: principal,
    title: (string-ascii 100),
    description: (string-utf8 500),
    genre: (string-ascii 50),
    start-block: uint,
    end-block: uint,
    voting-end-block: uint,
    submission-fee: uint,
    total-stake: uint,
    total-rewards: uint,
    rewards-distributed: bool,
    submission-count: uint,
    vote-count: uint,
    status: (string-ascii 20)
  }
)

(define-map submission-registry
  uint ;; submission-id
  {
    challenge-id: uint,
    author: principal,
    title: (string-ascii 100),
    content-hash: (buff 32),
    submission-block: uint,
    vote-count: uint,
    rewards-claimed: bool
  }
)

;; More map definitions similar to the original contract...

(define-read-only (get-challenge (challenge-id uint))
  (match (map-get? challenge-registry challenge-id)
    challenge (ok challenge)
    (err ERR-CHALLENGE-UNAVAILABLE)
  )
)

;; Most of the core functions would remain similar to the original implementation
;; with minor renaming and slight refactoring

(define-public (create-challenge 
  (title (string-ascii 100))
  (description (string-utf8 500))
  (genre (string-ascii 50))
  (duration uint)
  (voting-duration uint)
  (submission-fee uint)
  (stake uint)
)
  (let (
    (challenge-id (+ (var-get challenge-sequence) u1))
    (current-block block-height)
    (end-block (+ current-block duration))
    (voting-end-block (+ end-block voting-duration))
  )
    ;; Parameter validation remains the same
    (asserts! (>= duration MIN-CHALLENGE-DURATION) (err ERR-INVALID-CONFIG))
    (asserts! (<= duration MAX-CHALLENGE-DURATION) (err ERR-INVALID-CONFIG))
    (asserts! (>= voting-duration MIN-CHALLENGE-DURATION) (err ERR-INVALID-CONFIG))
    
    ;; Stake and fee collection
    (asserts! (>= stake PLATFORM-CREATION-FEE) (err ERR-INSUFFICIENT-STAKE))
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
    
    ;; Challenge creation logic remains the same
    (map-set challenge-registry challenge-id {
      curator: tx-sender,
      title: title,
      description: description,
      genre: genre,
      start-block: current-block,
      end-block: end-block,
      voting-end-block: voting-end-block,
      submission-fee: submission-fee,
      total-stake: stake,
      total-rewards: stake,
      rewards-distributed: false,
      submission-count: u0,
      vote-count: u0,
      status: "active"
    })
    
    (var-set challenge-sequence challenge-id)
    
    (ok challenge-id)
  )
)

;; Other functions would follow similar patterns of renaming and slight restructuring