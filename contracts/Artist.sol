// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Artist is ERC721URIStorage, Ownable {
    uint256 public nextId = 1;

    struct ArtistInfo {
        uint256 id;
        string name;
        string metadataURI;
    }

    mapping(address => ArtistInfo) public artistInfos;
    address[] private artistAddresses;

    constructor() ERC721("Artist", "ARTIST") Ownable(msg.sender) {}

    function mintArtist(
        address artistAddress,
        string memory artistName,
        string memory artistMetadataURI
    ) external returns (uint256) {
        require(!hasAddressMintedArtist(artistAddress), "Address has already minted an artist");
        
        uint256 id = nextId++;
        _safeMint(artistAddress, id);
        _setTokenURI(id, artistMetadataURI);
        artistInfos[artistAddress] = ArtistInfo(id, artistName, artistMetadataURI);
        artistAddresses.push(artistAddress);
        
        return id;
    }

    function getArtistInfo(address artistAddress) external view returns (string memory name, string memory metadataURI) {
        ArtistInfo storage info = artistInfos[artistAddress];
        return (info.name, info.metadataURI);
    }


    /**
     * @dev Get all artist addresses that have been minted
     * @return Array of all artist addresses
     */
    function getAllArtistAddresses() external view returns (address[] memory) {
        return artistAddresses;
    } 

    /**
     * @dev Get all artist IDs that have been minted
     * @return Array of all artist IDs
     */
    function getAllArtistIds() external view returns (uint256[] memory) {
        uint256 totalArtists = nextId - 1;
        uint256[] memory allArtists = new uint256[](totalArtists);
        
        for (uint256 i = 1; i < nextId; i++) {
            allArtists[i - 1] = i;
        }
        
        return allArtists;
    }

    /**
     * @dev Get total number of artists minted
     * @return Total number of artists
     */
    function getTotalArtists() external view returns (uint256) {
        return nextId - 1;
    }

    /**
     * @dev Check if an address has already minted an artist
     * @param userAddress The address to check
     * @return True if the address has minted an artist, false otherwise
     */
    function hasAddressMintedArtist(address userAddress) internal view returns (bool) {
        ArtistInfo storage info = artistInfos[userAddress];
        return bytes(info.name).length != 0;
    }
}