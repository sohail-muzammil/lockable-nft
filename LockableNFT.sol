// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LockableNFT is ERC721, Ownable, ReentrancyGuard {
    uint256 private _tokenIdCounter;
    // set your nft price here
    uint256 public MINT_PRICE; // Dynamic mint price

    mapping(uint256 => uint256) private _lockedEth;
    mapping(address => uint256[]) private _mintedTokens;

    event MintPriceUpdated(uint256 newPrice);
    event Minted(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 valueLocked
    );
    event Burned(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 valueReleased
    );
    // set name and symbol of your nft contract here
    constructor(
        uint256 initialMintPrice
    ) ERC721("LockableNFT", "LNFT") Ownable(msg.sender) {
        MINT_PRICE = initialMintPrice; // Set the initial mint price
    }

    /**
     * @dev Mint an NFT and lock exactly 0.1 ETH with it.
     * @notice The sender must send exactly 0.1 ETH to mint.
     */
    function mint() external payable nonReentrant {
        require(msg.value == MINT_PRICE, "Mint price must be exactly 0.1 ETH");
        uint256 newTokenId = _tokenIdCounter;
        _tokenIdCounter++;
        // Ensure the ETH for this tokenId is not already locked
        require(_lockedEth[newTokenId] == 0, "Token ID already has locked ETH");
        _lockedEth[newTokenId] = msg.value;
        _safeMint(msg.sender, newTokenId);
        _mintedTokens[msg.sender].push(newTokenId); // Track the minted token for the address

        emit Minted(msg.sender, newTokenId, msg.value); // Emit the Minted event
    }

    /**
     * @dev Burn an NFT and release locked ETH to the owner.
     * @param tokenId The ID of the NFT to burn.
     */
    function burn(uint256 tokenId) external nonReentrant {
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own the NFT to burn it"
        );
        uint256 lockedAmount = _lockedEth[tokenId];
        require(lockedAmount > 0, "No ETH locked for this NFT");
        // Clear locked ETH
        _lockedEth[tokenId] = 0;
        _removeMintedToken(msg.sender, tokenId);
        // Burn the NFT
        _burn(tokenId);
        // Send ETH back to the owner
        (bool success, ) = msg.sender.call{value: lockedAmount}("");
        require(success, "ETH transfer failed");

        emit Burned(msg.sender, tokenId, lockedAmount); // Emit the Burned event
    }

    /**
     * @dev Set a new mint price.
     * @param newPrice The new mint price in wei.
     */
    function setMintPrice(uint256 newPrice) external onlyOwner {
        require(newPrice > 0, "Mint price must be greater than 0");
        MINT_PRICE = newPrice;

        emit MintPriceUpdated(newPrice);
    }

    /**
     * @dev View locked ETH for a specific NFT.
     * @param tokenId The ID of the NFT.
     */
    function getLockedEthForNft(
        uint256 tokenId
    ) external view returns (uint256) {
        return _lockedEth[tokenId];
    }

    /**
     * @dev View ID for a specific NFT Against Owner Address.
     * @param owner The ID of the NFT.
     */
    function getMintedNftId(
        address owner
    ) external view returns (uint256[] memory) {
        return _mintedTokens[owner];
    }

    function _removeMintedToken(address owner, uint256 tokenId) private {
        uint256[] storage tokens = _mintedTokens[owner];
        uint256 length = tokens.length;

        for (uint256 i = 0; i < length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[length - 1];
                tokens.pop(); // Remove the last element
                break;
            }
        }
    }

    /**
     * @dev Get the total ETH locked in the contract for all NFTs.
     */
    function getTotalLockedEth() public view returns (uint256) {
        uint256 totalLocked = 0;
        for (uint256 i = 0; i < _tokenIdCounter; i++) {
            totalLocked += _lockedEth[i];
        }
        return totalLocked;
    }

    /**
     * @dev Override required for ERC721 and Ownable.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
