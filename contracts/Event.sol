// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Artist.sol";
import "./Organizator.sol";

contract Event is Ownable {
    Organizator public organizatorContract;
    Artist public artistContract;

    // immutable event config
    address public organizer;          // organizer wallet (receiver of remaining funds)
    address[] public artists;          // list of artist addresses
    uint256[] public artistShares;     // shares in %, same order as artists

    uint256 public date;
    string public metadataURI;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public soldTickets;

    constructor(
        address _organizer,
        address[] memory _artists,
        uint256[] memory _artistShares,
        uint256 _date,
        string memory _metadataURI,
        uint256 _ticketPrice,
        uint256 _totalTickets,
        Organizator _organizatorContract,
        Artist _artistContract
    ) Ownable(_organizer) {
        require(_organizer != address(0), "Invalid organizer");
        require(_organizatorContract.isOrganizator(_organizer), "Organizator is not registered. Please create an organizator account.");
        require(_artists.length == _artistShares.length, "Artists and shares length mismatch");
        require(_artists.length > 0, "No artists");
        require(_ticketPrice > 0, "Ticket price must be > 0");
        require(_totalTickets > 0, "Total tickets must be > 0");

        uint256 totalShare = 0;
        for (uint256 i = 0; i < _artistShares.length; i++) {
            require(_artistContract.isArtist(_artists[i]), "Artist is not registered. Please create an artist account.");
            totalShare += _artistShares[i];
        }
        require(totalShare <= 100, "Total artist shares should be <= 100");

        organizer = _organizer;
        artists = _artists;
        artistShares = _artistShares;

        date = _date;
        metadataURI = _metadataURI;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;

        organizatorContract = _organizatorContract;
        artistContract = _artistContract;
    }

    function buyTicket(uint256 _quantity) external payable {
        require(block.timestamp < date, "Event already happened");
        require(_quantity > 0, "Quantity must be > 0");
        require(soldTickets + _quantity <= totalTickets, "Not enough tickets left");
        require(msg.value == ticketPrice * _quantity, "Incorrect ETH sent");

        soldTickets += _quantity;

        uint256 totalSent = 0;

        // split payment among artists according to their share
        for (uint256 i = 0; i < artists.length; i++) {
            uint256 artistAmount = (msg.value * artistShares[i]) / 100;
            if (artistAmount > 0) {
                totalSent += artistAmount;
                payable(artists[i]).transfer(artistAmount);
            }
        }

        // remainder goes to organizer
        uint256 organizerAmount = msg.value - totalSent;
        if (organizerAmount > 0) {
            payable(organizer).transfer(organizerAmount);
        }
    }


    function getArtists() external view returns (address[] memory) {
        return artists;
    }

    function getArtistShares() external view returns (uint256[] memory) {
        return artistShares;
    }
}