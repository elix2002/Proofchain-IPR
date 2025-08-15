 Proofchain-IPR Smart Contract

 Overview

**Proofchain-IPR** is a Clarity smart contract for registering, transferring, updating, and revoking intellectual property (IP) records on the Stacks blockchain. Each IP record is uniquely identified by a content hash and can include metadata such as an IPFS CID, description, or license information.

 Features

- **Admin Management**
  - The contract deployer is the initial admin.
  - Admin rights can be transferred to another principal.

- **IP Registration**
  - Register a new IP hash with metadata.
  - Prevents duplicate or inactive registrations.

- **IP Transfer**
  - Only the current owner can transfer ownership of an IP record.

- **Metadata Update**
  - Owners can update the metadata of their IP records.

- **Revocation**
  - Owners can revoke (deactivate) their IP records.

- **Read-Only Helpers**
  - Fetch full IP record by hash.
  - Check if a hash is registered and active.

 Data Structures

- **Admin**
  - `admin` (principal): Stores the current admin.

- **IP Records**
  - `ip-records` (map):  
    - `hash` (string-ascii 64): Unique identifier for the IP.
    - `owner` (principal): Current owner of the IP.
    - `metadata` (string-ascii 128): Metadata or IPFS CID.
    - `registered-at` (uint): Block height when registered (currently set to `u0`).
    - `active` (bool): Indicates if the record is active.

 Events

- `ip-registered-event`
- `ip-transferred-event`
- `ip-revoked-event`
- `ip-metadata-updated-event`

Events are emitted using the `print` function for contract activity tracking.

 Usage

 Admin Functions

- **Get Admin**
  ```clarity
  (get-admin)
  ```
- **Transfer Admin**
  ```clarity
  (transfer-admin new-admin)
  ```

 IP Functions

- **Register IP**
  ```clarity
  (register-ip hash metadata)
  ```
- **Transfer IP**
  ```clarity
  (transfer-ip hash new-owner)
  ```
- **Update Metadata**
  ```clarity
  (update-metadata hash new-metadata)
  ```
- **Revoke IP**
  ```clarity
  (revoke-ip hash)
  ```

 Read-Only Functions

- **Get Record**
  ```clarity
  (get-record hash)
  ```
- **Check Registration**
  ```clarity
  (is-registered hash)
  ```

 Notes

- Only the owner can transfer, update, or revoke an IP record.
- Metadata can be used for IPFS CIDs, descriptions, or license info.
- Revoked records remain in the contract but are marked inactive.
