// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Artist} from "./Artist.sol";
import {Ticket} from "./Ticket.sol";
import {Organizator} from "./Organizator.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Event is Ownable, ReentrancyGuard {
    address public organizer;
    uint256 public date;
    string public metadataUri;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public soldTickets;

    mapping(uint256 => bool) public usedTickets;

    Artist public artistContract;
    uint256[] public artistIds;
    uint256[] public artistShares;
    uint256 public organizerShare;

    Ticket public ticketContract;

    Organizator public organizatorContract;
    bool public cashOnly;
    bool public requiresConsent;

    enum ConsentStatus {
        Unset,
        Yes,
        No
    }

    mapping(uint256 => ConsentStatus) public ticketConsent;
    mapping(uint256 => address) public ticketBuyer;
    mapping(uint256 => uint256) public ticketPayment;
    mapping(uint256 => bool) public refundedTickets;

    uint256 public escrowBalance;
    bool public fundsDistributed;

    // Verificators management
    mapping(address => bool) public verificators;
    event VerificatorAdded(address indexed verificator);
    event VerificatorRemoved(address indexed verificator);
    event TicketPurchased(address indexed buyer, uint256 indexed tokenId, bool consent);
    event TicketRefunded(uint256 indexed tokenId, address indexed buyer);
    event FundsDistributed(uint256 totalAmount);

    constructor(
        address _artistContract,
        uint256[] memory _artistIds,
        uint256[] memory _artistShares,
        address _organizer,
        uint256 _date,
        string memory _metadataUri,
        uint256 _ticketPrice,
        uint256 _totalTickets,
        address _ticketContract,
        address _organizatorContract,
        bool _cashOnly,
        bool _requiresConsent
    ) Ownable(_organizer) {
        require(_artistIds.length == _artistShares.length, "Artists and shares length mismatch");
        uint256 totalShare = 0;
        for (uint256 i = 0; i < _artistShares.length; i++) {
            totalShare += _artistShares[i];
        }
        require(totalShare <= 100, "Total artist share > 100");
        require(_ticketPrice > 0 || _cashOnly, "Ticket price required unless cash only");

        organizatorContract = Organizator(_organizatorContract);
        require(organizatorContract.isOrganizator(_organizer), "Organizer not registered");

        artistContract = Artist(_artistContract);
        artistIds = _artistIds;
        artistShares = _artistShares;
        organizer = _organizer;
        date = _date;
        metadataUri = _metadataUri;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        organizerShare = 100 - totalShare;
        ticketContract = Ticket(_ticketContract);
        cashOnly = _cashOnly;
        requiresConsent = _requiresConsent;
    // Optionally, organizer is a verificator by default
    verificators[_organizer] = true;
    }

    function buyTicket(uint256 _quantity, bool _consent) external payable nonReentrant {
        require(block.timestamp < date, "Event already happened");
        require(_quantity > 0, "Quantity must be greater than 0");
        require(soldTickets + _quantity <= totalTickets, "Not enough tickets available");

        if (cashOnly) {
            require(msg.value == 0, "Cash events do not accept ETH");
        } else {
            require(msg.value == ticketPrice * _quantity, "Incorrect ETH sent");
        }

        // Mint multiple tickets
        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = ticketContract.mintTicket(msg.sender, metadataUri);
            ticketBuyer[tokenId] = msg.sender;
            if (requiresConsent) {
                ticketConsent[tokenId] = _consent ? ConsentStatus.Yes : ConsentStatus.No;
            }
            if (!cashOnly) {
                ticketPayment[tokenId] = ticketPrice;
            }
            emit TicketPurchased(msg.sender, tokenId, _consent);
        }
        soldTickets += _quantity;

        if (!cashOnly) {
            escrowBalance += msg.value;
        }
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can manage verificators");
        _;
    }

    function addVerificator(address verificator) external onlyOrganizer {
        verificators[verificator] = true;
        emit VerificatorAdded(verificator);
    }

    function removeVerificator(address verificator) external onlyOrganizer {
        verificators[verificator] = false;
        emit VerificatorRemoved(verificator);
    }

    modifier onlyVerificator() {
        require(verificators[msg.sender], "Not a verificator");
        _;
    }

    function checkIn(uint256 tokenId) external onlyVerificator {
        require(!usedTickets[tokenId], "Already used");
        require(!refundedTickets[tokenId], "Ticket refunded");
        require(ticketContract.ownerOf(tokenId) != address(0), "Invalid ticket");
        usedTickets[tokenId] = true;
    }

    function isValid(uint256 tokenId) external view returns (bool) {
        return !usedTickets[tokenId] && !refundedTickets[tokenId];
    }

    function getArtistIds() external view returns (uint256[] memory) {
        return artistIds;
    }

    function getArtistShares() external view returns (uint256[] memory) {
        return artistShares;
    }
    
    function getTicketContract() external view returns (address) {
        return address(ticketContract);
    }

    function requestRefund(uint256 tokenId) external nonReentrant {
        require(!cashOnly, "Cash refunds unavailable");
        require(block.timestamp < date, "Event already happened");
        require(!usedTickets[tokenId], "Ticket already used");
        require(!refundedTickets[tokenId], "Already refunded");

        address buyer = ticketBuyer[tokenId];
        require(buyer == msg.sender, "Only buyer can refund");
        require(ticketContract.ownerOf(tokenId) == msg.sender, "Not ticket owner");

        uint256 payment = ticketPayment[tokenId];
        require(payment > 0, "No refundable payment");
        require(escrowBalance >= payment, "Insufficient escrow");

        refundedTickets[tokenId] = true;
        soldTickets -= 1;
        ticketPayment[tokenId] = 0;
        escrowBalance -= payment;

        ticketContract.burnTicket(tokenId);
        payable(msg.sender).transfer(payment);

        emit TicketRefunded(tokenId, msg.sender);
    }

    function distributeFunds() external onlyOrganizer nonReentrant {
        require(!cashOnly, "Cash events handled off-chain");
        require(block.timestamp >= date, "Event not finished");
        require(!fundsDistributed, "Funds already distributed");

        uint256 balance = escrowBalance;
        require(balance > 0, "No funds to distribute");
        fundsDistributed = true;
        escrowBalance = 0;

        uint256 totalSent = 0;
        for (uint256 i = 0; i < artistIds.length; i++) {
            address artistOwner = artistContract.ownerOf(artistIds[i]);
            uint256 artistAmount = (balance * artistShares[i]) / 100;
            totalSent += artistAmount;
            payable(artistOwner).transfer(artistAmount);
        }

        uint256 organizerAmount = balance - totalSent;
        payable(organizer).transfer(organizerAmount);

        emit FundsDistributed(balance);
    }
}