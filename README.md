# Decentralized Storage and Compute Leasing Contract

This contract provides a decentralized mechanism for registering and managing storage and compute nodes, as well as leasing these resources to clients in exchange for STX payments. The contract is designed to ensure secure interactions between resource providers and clients while facilitating decentralized transactions.

## Features
- **Storage Node Registration and Management:**
  - Register storage nodes with available space and price-per-GB.
  - Update existing storage node details.

- **Compute Node Registration and Management:**
  - Register compute nodes with available cores and price-per-core.
  - Update existing compute node details.

- **Lease Management:**
  - Lease storage space or compute cores for a specified duration.
  - Automatic STX payment transfers for leases.

- **Read-Only Queries:**
  - Retrieve information about storage nodes, compute nodes, and active leases.

## Data Structures
### Maps
- **`storage-nodes`:** Tracks storage nodes with details:
  - `owner`: The principal that owns the node.
  - `available-space`: Space available for leasing.
  - `price-per-gb`: Price per GB for leasing.

- **`compute-nodes`:** Tracks compute nodes with details:
  - `owner`: The principal that owns the node.
  - `available-cores`: Number of cores available for leasing.
  - `price-per-core`: Price per core for leasing.

- **`storage-leases`:** Tracks active storage leases:
  - `client`: Principal renting the space.
  - `node-id`: Associated storage node ID.
  - `space-rented`: Amount of space rented.
  - `lease-start-block`: Starting block of the lease.
  - `lease-end-block`: Ending block of the lease.
  - `payment-amount`: Total payment for the lease.

- **`compute-leases`:** Tracks active compute leases:
  - `client`: Principal renting the cores.
  - `node-id`: Associated compute node ID.
  - `cores-rented`: Number of cores rented.
  - `lease-start-block`: Starting block of the lease.
  - `lease-end-block`: Ending block of the lease.
  - `payment-amount`: Total payment for the lease.

### Variables
- **`next-node-id`:** Counter to generate unique IDs for nodes.
- **`next-lease-id`:** Counter to generate unique IDs for leases.

## Functions

### Public Functions
#### Storage Node Functions
- **`register-storage-node (available-space uint) (price-per-gb uint)`**
  Registers a new storage node.
  - **Returns:** Node ID.

- **`update-storage-node (node-id uint) (available-space uint) (price-per-gb uint)`**
  Updates details of an existing storage node.
  - **Errors:**
    - `err-not-found`: Node not found.
    - `err-owner-only`: Only the owner can update the node.

#### Compute Node Functions
- **`register-compute-node (available-cores uint) (price-per-core uint)`**
  Registers a new compute node.
  - **Returns:** Node ID.

- **`update-compute-node (node-id uint) (available-cores uint) (price-per-core uint)`**
  Updates details of an existing compute node.
  - **Errors:**
    - `err-not-found`: Node not found.
    - `err-owner-only`: Only the owner can update the node.

#### Lease Functions
- **`lease-storage (node-id uint) (space-to-rent uint) (lease-duration uint)`**
  Leases storage space for a specified duration.
  - **Returns:** Lease ID.
  - **Errors:**
    - `err-not-found`: Node not found.
    - `err-insufficient-space`: Requested space exceeds available space.
    - `err-insufficient-funds`: Payment transfer failed.

- **`lease-compute (node-id uint) (cores-to-rent uint) (lease-duration uint)`**
  Leases compute cores for a specified duration.
  - **Returns:** Lease ID.
  - **Errors:**
    - `err-not-found`: Node not found.
    - `err-insufficient-space`: Requested cores exceed available cores.
    - `err-insufficient-funds`: Payment transfer failed.

### Read-Only Functions
- **`get-storage-node (node-id uint)`**
  Retrieves details of a storage node.
  - **Returns:** Storage node data or `none` if not found.

- **`get-compute-node (node-id uint)`**
  Retrieves details of a compute node.
  - **Returns:** Compute node data or `none` if not found.

- **`get-storage-lease (lease-id uint)`**
  Retrieves details of a storage lease.
  - **Returns:** Storage lease data or `none` if not found.

- **`get-compute-lease (lease-id uint)`**
  Retrieves details of a compute lease.
  - **Returns:** Compute lease data or `none` if not found.

## Error Codes
- **`err-owner-only (u100):`** Action restricted to the owner of the node.
- **`err-not-found (u101):`** Node or lease not found.
- **`err-insufficient-space (u102):`** Requested resources exceed available capacity.
- **`err-insufficient-funds (u103):`** Payment transfer failed.

## Usage Example
1. **Register a Storage Node:**
   ```clarity
   (register-storage-node u500 u10) ;; Registers a node with 500GB at 10 STX per GB.
   ```

2. **Lease Storage:**
   ```clarity
   (lease-storage u1 u50 u144) ;; Leases 50GB from node ID 1 for 144 blocks.
   ```

3. **Query Node Information:**
   ```clarity
   (get-storage-node u1) ;; Retrieves details of node ID 1.
   ```

4. **Query Lease Information:**
   ```clarity
   (get-storage-lease u1) ;; Retrieves details of lease ID 1.
   ```

## Security
- Ensures only node owners can update their nodes.
- Validates resource availability and payment before processing leases.
- Utilizes STX transfers to facilitate secure and transparent payments.

## Future Enhancements
- Add functionality to terminate leases prematurely.
- Implement resource usage monitoring.
- Extend support for dynamic pricing or auction-based leasing.

