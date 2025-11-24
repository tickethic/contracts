// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Artist} from "./Artist.sol";
import {Ticket} from "./Ticket.sol";
import {Organizator} from "./Organizator.sol";

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
    event TicketRefunded(uint256 indexed
