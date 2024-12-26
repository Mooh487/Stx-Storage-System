;; Decentralized Storage System Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-space (err u102))
(define-constant err-insufficient-funds (err u103))

;; Define storage data structures
(define-map storage-nodes 
  { node-id: uint }
  {
    owner: principal,
    available-space: uint,
    price-per-gb: uint
  })

(define-map compute-nodes
  { node-id: uint }
  {
    owner: principal,
    available-cores: uint,
    price-per-core: uint
  })

(define-map storage-leases
  { lease-id: uint }
  {
    client: principal,
    node-id: uint,
    space-rented: uint,
    lease-start-block: uint,
    lease-end-block: uint,
    payment-amount: uint
  })

(define-map compute-leases
  { lease-id: uint }
  {
    client: principal,
    node-id: uint,
    cores-rented: uint,
    lease-start-block: uint,
    lease-end-block: uint,
    payment-amount: uint
  })

;; Define data variables for tracking
(define-data-var next-node-id uint u1)
(define-data-var next-lease-id uint u1)

;; Storage Node Functions
(define-public (register-storage-node (available-space uint) (price-per-gb uint))
  (let 
    ((node-id (var-get next-node-id)))
    (map-insert storage-nodes
      { node-id: node-id }
      {
        owner: tx-sender,
        available-space: available-space,
        price-per-gb: price-per-gb
      })
    (var-set next-node-id (+ node-id u1))
    (ok node-id)))

(define-public (update-storage-node (node-id uint) (available-space uint) (price-per-gb uint))
  (let 
    ((node (unwrap! (map-get? storage-nodes { node-id: node-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get owner node)) err-owner-only)
    (ok (map-set storage-nodes
      { node-id: node-id }
      {
        owner: tx-sender,
        available-space: available-space,
        price-per-gb: price-per-gb
      }))))

