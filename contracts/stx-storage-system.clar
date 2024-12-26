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

;; Compute Node Functions
(define-public (register-compute-node (available-cores uint) (price-per-core uint))
  (let 
    ((node-id (var-get next-node-id)))
    (map-insert compute-nodes
      { node-id: node-id }
      {
        owner: tx-sender,
        available-cores: available-cores,
        price-per-core: price-per-core
      })
    (var-set next-node-id (+ node-id u1))
    (ok node-id)))

(define-public (update-compute-node (node-id uint) (available-cores uint) (price-per-core uint))
  (let 
    ((node (unwrap! (map-get? compute-nodes { node-id: node-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get owner node)) err-owner-only)
    (ok (map-set compute-nodes
      { node-id: node-id }
      {
        owner: tx-sender,
        available-cores: available-cores,
        price-per-core: price-per-core
      }))))

;; Lease Functions
(define-public (lease-storage (node-id uint) (space-to-rent uint) (lease-duration uint))
  (let 
    ((node (unwrap! (map-get? storage-nodes { node-id: node-id }) err-not-found))
     (lease-id (var-get next-lease-id)))
    (asserts! (<= space-to-rent (get available-space node)) err-insufficient-space)
    (let 
      ((payment (* space-to-rent (get price-per-gb node))))
      (try! (stx-transfer? payment tx-sender (get owner node)))
      (map-insert storage-leases
        { lease-id: lease-id }
        {
          client: tx-sender,
          node-id: node-id,
          space-rented: space-to-rent,
          lease-start-block: block-height,
          lease-end-block: (+ block-height lease-duration),
          payment-amount: payment
        })
      (var-set next-lease-id (+ lease-id u1))
      (ok lease-id))))

(define-public (lease-compute (node-id uint) (cores-to-rent uint) (lease-duration uint))
  (let 
    ((node (unwrap! (map-get? compute-nodes { node-id: node-id }) err-not-found))
     (lease-id (var-get next-lease-id)))
    (asserts! (<= cores-to-rent (get available-cores node)) err-insufficient-space)
    (let 
      ((payment (* cores-to-rent (get price-per-core node))))
      (try! (stx-transfer? payment tx-sender (get owner node)))
      (map-insert compute-leases
        { lease-id: lease-id }
        {
          client: tx-sender,
          node-id: node-id,
          cores-rented: cores-to-rent,
          lease-start-block: block-height,
          lease-end-block: (+ block-height lease-duration),
          payment-amount: payment
        })
      (var-set next-lease-id (+ lease-id u1))
      (ok lease-id))))

;; Read-only Functions
(define-read-only (get-storage-node (node-id uint))
  (map-get? storage-nodes { node-id: node-id }))

(define-read-only (get-compute-node (node-id uint))
  (map-get? compute-nodes { node-id: node-id }))

(define-read-only (get-storage-lease (lease-id uint))
  (map-get? storage-leases { lease-id: lease-id }))

(define-read-only (get-compute-lease (lease-id uint))
  (map-get? compute-leases { lease-id: lease-id }))
