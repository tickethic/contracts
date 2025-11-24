// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Artist is ERC721URIStorage, Ownable {
    uint256 public nextArtistId = 1;

    struct ArtistInfo {
        string name;
        string metadataUri;
    }

    mapping(uint256 => ArtistInfo) public artistInfos;
    mapping(address => bool) public hasMintedArtist;

    constructor() ERC721("Artist", "ARTIST") Ownable(msg.sender) {}

    function mintArtist(string memory artistName, string memory artistMetadataUri) external returns (uint256) {
        require(!hasMintedArtist[msg.sender], "Address has already minted an artist");
        uint256 artistId = nextArtistId++;
        _safeMint(msg.sender, artistId);
        _setTokenURI(artistId, artistMetadataUri);
        artistInfos[artistId] = ArtistInfo(artistName, artistMetadataUri);
        hasMintedArtist[msg.sender] = true;
        return artistId;
    }
}
