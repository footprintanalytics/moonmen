// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MoonMen is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    mapping(bytes => bool) public signatureUsed;

    uint public constant MAX_SUPPLY = 807;
    uint public constant MAX_RESERVE = 0;
    uint public constant MAX_MINT = 1;
    uint public constant PRICE = 0 ether;

    string public baseTokenURI;

    address private signerAddress = 0x24a5950977af7A02eec4c31abF193CBdD936B798;

    constructor(string memory baseURI) ERC721("Moon Men", "MOONMEN") {
        setBaseURI(baseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function recoverSigner(bytes32 hash, bytes memory signature) public pure returns (address) {
        bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return ECDSA.recover(messageDigest, signature);
    }

    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIds.current();
        require(totalMinted.add(MAX_RESERVE) < MAX_SUPPLY, "Not enough NFTs left to reserve");
        for (uint i = 0; i < MAX_RESERVE; i++) _mintSingleNFT();
    }

    function mintNFTs(uint _count, bytes32 hash, bytes memory signature) public payable {
        uint totalMinted = _tokenIds.current();
        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(_count > 0 && _count <= MAX_MINT, "Cannot mint specified number of NFTs.");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");
        require(recoverSigner(hash, signature) == signerAddress, "Address is not allowlisted");
        require(!signatureUsed[signature], "Signature has already been used.");
        for (uint i = 0; i < _count; i++) _mintSingleNFT();
        signatureUsed[signature] = true;
    }

    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}
