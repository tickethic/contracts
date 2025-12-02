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
    Organizator private organizatorContract = new Organizator();

    address[] private events;
    mapping(address => uint256) public eventDate;

    constructor() Ownable(msg.sender) {
        // optional: you could mint an initial artist here if you want
    }

    /// @dev Mint a new Organizator NFT for msg.sender
    /// @param name The organizator name
    /// @param metadataURI Metadata URI for the organizator
    /// @return id ID of the newly minted organizator
    function createOrganizator(
        string memory name,
        string memory metadataURI
    ) external returns (uint256 id) {
        id = organizatorContract.mint(msg.sender, name, metadataURI);
    }

    // @dev Mint a new Organizator NFT for msg.sender
    /// @param name The organizator name
    /// @param metadataURI Metadata URI for the organizator
    /// @return id ID of the newly minted organizator
    function createOrganizator(
        string memory name,
        string memory metadataURI,
        address owner
    ) external returns (uint256 id) {
        id = organizatorContract.mint(owner, name, metadataURI);
    }

    /// @dev Return the list of all organizator addresses
    /// @return addresses List of the organizator addresses
    function getAllOrganizatorAddresses() external view returns (address[] memory addresses) {
        return organizatorContract.getAllAddresses();
    }

    /// @dev Return the Organizator NFT info of your-self, if you own one.
    /// @return name The organizator name
    /// @return metadataURI The organizator metadata URI
    function getMyOrganizatorInfo() external view returns (string memory name, string memory metadataURI) {
        return organizatorContract.getInfo(msg.sender);
    }

    /// @dev Return the Organizator contract of the address
    /// @param owner The organizator address
    /// @return name The organizator name
    /// @return metadataURI The artiOrganizatorst metadata URI
    function getOrganizatorInfo(address owner) external view returns (string memory name, string memory metadataURI) {
        return organizatorContract.getInfo(owner);
    }

    /// @dev Get total number of organizators minted
    /// @return Total number of organizators
    function getTotalOrganizators() external view returns (uint256) {
        return organizatorContract.getTotal();
    }

    /// @dev Mint a new Artist NFT for msg.sender 
    /// @param name The artist name
    /// @param metadataURI Metadata URI for the artist
    /// @return id ID of the newly minted artist
    function createArtist(
        string memory name,
        string memory metadataURI
    ) external returns (uint256 id) {
        id = artistContract.mintArtist(msg.sender, name, metadataURI);
    }

    /// @dev Get total number of artists minted
    /// @return Total number of artists
    function getTotalArtists() external view returns (uint256) {
        return artistContract.getTotal();
    }

    /// @dev Mint a new Artist NFT in the shared Artist contract
    /// @param owner The artist address
    /// @param name The artist name
    /// @param metadataURI Metadata URI for the artist
    /// @return artistId ID of the newly minted artist
    function createArtist(
        string memory name,
        string memory metadataURI,
        address owner
    ) external returns (uint256 artistId) {
        artistId = artistContract.mintArtist(owner, name, metadataURI);
    }

    /// @dev Return the list of all artist addresses
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

    /// @dev Create a new Event contract.
    /// @param _artists The list of artist addresses participating in the event.
    /// @param _artistShares The list of artist revenue shares (in percent, must sum <= 100).
    /// @param _date The timestamp of the event.
    /// @param _metadataURI Metadata URI describing the event.
    /// @param _ticketPrice The price of a single ticket in wei.
    /// @param _totalTickets The total number of tickets available.
    /// @return eventAddress The address of the newly created Event contract.
    function createEvent(
        address[] memory _artists,
        uint256[] memory _artistShares,
        uint256 _date,
        string memory _metadataURI,
        uint256 _ticketPrice,
        uint256 _totalTickets
    ) external returns (address eventAddress) {
        Event newEvent = new Event(
            msg.sender,
            _artists,
            _artistShares,
            _date,
            _metadataURI,
            _ticketPrice,
            _totalTickets,
            organizatorContract,
            artistContract
        );
        eventAddress = address(newEvent);

        events.push(eventAddress);
        eventDate[eventAddress] = _date;
    }

    /// @dev Get all event addresses ever created.
    function getAllEvents() external view returns (address[] memory) {
        return events;
    }

    /// @dev Get all upcoming events (date >= now).
    function getUpcomingEvents() external view returns (address[] memory) {
        uint256 count;
        uint256 len = events.length;

        // first pass: count
        for (uint256 i = 0; i < len; i++) {
            if (eventDate[events[i]] >= block.timestamp) {
                count++;
            }
        }

        // second pass: collect
        address[] memory result = new address[](count);
        uint256 idx;
        for (uint256 i = 0; i < len; i++) {
            if (eventDate[events[i]] >= block.timestamp) {
                result[idx++] = events[i];
            }
        }

        return result;
    }

    /// @dev Get all past events (date < now).
    function getPastEvents() external view returns (address[] memory) {
        uint256 count;
        uint256 len = events.length;

        for (uint256 i = 0; i < len; i++) {
            if (eventDate[events[i]] < block.timestamp) {
                count++;
            }
        }

        address[] memory result = new address[](count);
        uint256 idx;
        for (uint256 i = 0; i < len; i++) {
            if (eventDate[events[i]] < block.timestamp) {
                result[idx++] = events[i];
            }
        }

        return result;
    }


    function getEventInfo(
        address eventAddress
    ) external view
        returns (
            address organizer,
            address[] memory artists,
            uint256[] memory artistShares,
            uint256 date,
            string memory metadataURI,
            uint256 ticketPrice,
            uint256 totalTickets
        )
    {
        Event ev = Event(eventAddress);

        organizer = ev.organizer();
        artists = ev.getArtists();
        artistShares = ev.getArtistShares();
        date = ev.date();
        metadataURI = ev.metadataURI();
        ticketPrice = ev.ticketPrice();
        totalTickets = ev.totalTickets();
    }
}