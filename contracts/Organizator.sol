// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Organizator is ERC721URIStorage, Ownable {
    uint256 public nextId = 1;

    struct OrganizatorInfo {
        uint256 id;
        string name;
        string metadataURI;
    }

    mapping(address => OrganizatorInfo) public infos;
    address[] public addresses;

    constructor() ERC721("Organizator", "ORGANIZATOR") Ownable(msg.sender) {}

    function mint(
        address owner,
        string memory name,
        string memory metadataURI
    ) external returns (uint256) {
        require(!isOrganizator(owner), "Address has already minted an organizator.");
        
        uint256 id = nextId++;
        _safeMint(owner, id);
        _setTokenURI(id, metadataURI);
        infos[owner] = OrganizatorInfo(id, name, metadataURI);
        addresses.push(owner);
        
        return id;
    }

    function getInfo(address owner) external view returns (string memory name, string memory metadataURI) {
        OrganizatorInfo storage info = infos[owner];
        return (info.name, info.metadataURI);
    }

    function isOrganizator(address owner) public view returns (bool) {
        OrganizatorInfo storage info = infos[owner];
        return bytes(info.name).length != 0;
    }

    /**
     * @dev Get all addresses that have been minted
     * @return Array of all addresses
     */
    function getAllAddresses() external view returns (address[] memory) {
        return addresses;
    } 

    /**
     * @dev Get total number minted
     * @return Total number
     */
    function getTotal() external view returns (uint256) {
        return nextId - 1;
    }
}