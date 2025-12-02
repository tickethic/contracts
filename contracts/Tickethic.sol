// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Artist.sol";
import "./Organizator.sol";
import "./Event.sol";
import "./Ticket.sol";

contract Tickethic is Ownable {
    // Single Artist NFT contract that holds all artists
    Artist private artistContract = new Artist();

    constructor() Ownable(msg.sender) {
        // optional: you could mint an initial artist here if you want
    }

    /// @dev Mint a new Artist NFT for msg.sender in the shared Artist contract
    /// @param artistName The artist name
    /// @param artistMetadataURI Metadata URI for the artist
    /// @return artistId ID of the newly minted artist
    function createArtist(
        string memory artistName,
        string memory artistMetadataURI
    ) external returns (uint256 artistId) {
        artistId = artistContract.mintArtist(msg.sender, artistName, artistMetadataURI);
    }

    /// @dev Mint a new Artist NFT in the shared Artist contract
    /// @param owner The artist address
    /// @param artistName The artist name
    /// @param artistMetadataURI Metadata URI for the artist
    /// @return artistId ID of the newly minted artist
    function createArtist(
        string memory artistName,
        string memory artistMetadataURI,
        address owner
    ) external returns (uint256 artistId) {
        artistId = artistContract.mintArtist(owner, artistName, artistMetadataURI);
    }

    /// @dev Return the list of all artist IDs
     /// @return addresses List of the artist addresses
    function getAllArtistAddresses() external view returns (address[] memory addresses) {
        return artistContract.getAllArtistAddresses();
    }

    /// @dev Return the Artist NFT of your-self, if you own one.
    /// @return name The artist name
    /// @return metadataURI The artist metadata URI
    function getMyArtistInfo() external view returns (string memory name, string memory metadataURI) {
        return artistContract.getArtistInfo(msg.sender);
    }

    /// @dev Return the Artist contract of the address
    /// @param artistAddress The artist address
    /// @return name The artist name
    /// @return metadataURI The artist metadata URI
    function getArtistInfo(address artistAddress) external view returns (string memory name, string memory metadataURI) {
        return artistContract.getArtistInfo(artistAddress);
    }
}