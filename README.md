```markdown
# LockableNFT Smart Contract

The **LockableNFT** smart contract is an ERC-721 implementation that allows users to mint NFTs by locking ETH as collateral. This locked ETH can be reclaimed by burning the NFT, making each token intrinsically valuable and backed by liquidity.

---

## Features

- **Minting with ETH Locking**: Users mint NFTs by locking a specified amount of ETH.
- **Burning to Unlock ETH**: Owners can burn their NFTs to release the locked ETH.
- **Dynamic Pricing**: The contract owner can adjust the mint price.
- **Tracking**: Owners can view their minted NFTs and check the locked ETH for specific tokens.
- **Security**: Implements OpenZeppelin's `ReentrancyGuard` and `Ownable` for enhanced security.

---

## Contract Details

### Constructor

- **`constructor(uint256 initialMintPrice)`**
  Initializes the contract with:
  - `initialMintPrice`: The starting price for minting an NFT.

---

### Key Functions

#### Minting

- **`mint()`**
  Mints a new NFT and locks ETH.
  - **Requirements**:
    - Sender must send exactly the specified mint price.
    - Token ID must not already have locked ETH.
  - **Emits**:
    - `Minted(address indexed owner, uint256 indexed tokenId, uint256 valueLocked)`

#### Burning

- **`burn(uint256 tokenId)`**
  Burns an NFT and releases the locked ETH to the owner.
  - **Requirements**:
    - Caller must own the NFT.
    - Locked ETH must be greater than 0.
  - **Emits**:
    - `Burned(address indexed owner, uint256 indexed tokenId, uint256 valueReleased)`

#### Admin Functionality

- **`setMintPrice(uint256 newPrice)`**
  Updates the mint price. Only callable by the owner.
  - **Emits**:
    - `MintPriceUpdated(uint256 newPrice)`

#### View Functions

- **`getLockedEthForNft(uint256 tokenId)`**
  Returns the amount of ETH locked for a specific token ID.

- **`getMintedNftId(address owner)`**
  Returns an array of token IDs minted by the specified address.

- **`getTotalLockedEth()`**
  Returns the total amount of ETH locked across all NFTs.

---

## Events

- **`MintPriceUpdated(uint256 newPrice)`**
  Emitted when the mint price is updated.

- **`Minted(address indexed owner, uint256 indexed tokenId, uint256 valueLocked)`**
  Emitted when a new NFT is minted.

- **`Burned(address indexed owner, uint256 indexed tokenId, uint256 valueReleased)`**
  Emitted when an NFT is burned and ETH is released.

---

## Security Features

- **Reentrancy Protection**: Prevents reentrant attacks using OpenZeppelin's `ReentrancyGuard`.
- **Ownership Control**: The `Ownable` implementation restricts critical functions to the contract owner.

---

## Dependencies

This contract uses OpenZeppelin libraries:
- [`@openzeppelin/contracts/token/ERC721/ERC721`](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721)
- [`@openzeppelin/contracts/access/Ownable`](https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable)
- [`@openzeppelin/contracts/security/ReentrancyGuard`](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard)

---

## Deployment

1. Deploy the contract with the desired initial mint price (in wei).
2. Update the mint price as needed using `setMintPrice()`.

---

## Example Usage

### Minting

```solidity
contractInstance.mint({ value: MINT_PRICE });
```

### Burning

```solidity
contractInstance.burn(tokenId);
```

### Querying Locked ETH

```solidity
contractInstance.getLockedEthForNft(tokenId);
```

---

## License

This project is licensed under the MIT License.
