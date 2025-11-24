// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Artist} from "./Artist.sol";
import {Ticket} from "./Ticket.sol";
import {Organizator} from "./Organizator.sol";
import {Event} from "./Event.sol";

contract EventManager {
    Artist public artistContract;
    Ticket public ticketContract;
    Organizator public organizatorContract;

    mapping(uint256 => address) public events;
    uint256 public nextEventId = 1;

    event EventCreated(uint256 indexed eventId, address indexed eventAddress, address indexed organizer);

    constructor(address _artistContract, address _ticketContract, address _organizatorContract) {
        artistContract = Artist(_artistContract);
        ticketContract = Ticket(_ticketContract);
        organizatorContract = Organizator(_organizatorContract);
    }

    function createEvent(
        uint256[] memory _artistIds,
        uint256[] memory _artistShares,
        address _organizer,
        uint256 _date,
        string memory _metadataUri,
        uint256 _ticketPrice,
        uint256 _totalTickets,
        bool _cashOnly,
        bool _requiresConsent
    ) external returns (uint256 eventId, address eventAddress) {
        require(_artistIds.length > 0, "At least one artist required");
        require(_artistIds.length == _artistShares.length, "Artists and shares length mismatch");
        require(_organizer != address(0), "Invalid organizer address");
        require(_date > block.timestamp, "Event date must be in the future");
        require(bytes(_metadataUri).length > 0, "Metadata URI required");
        require(_ticketPrice > 0 || _cashOnly, "Ticket price required unless cash only");
        require(_totalTickets > 0, "Total tickets must be greater than 0");

        uint256 totalShare = 0;
        for (uint256 i = 0; i < _artistShares.length; i++) {
            totalShare += _artistShares[i];
        }
        require(totalShare <= 100, "Total artist share cannot exceed 100%");

        require(organizatorContract.isOrganizator(_organizer), "Organizer not registered");

        for (uint256 i = 0; i < _artistIds.length; i++) {
            try artistContract.ownerOf(_artistIds[i]) returns (address) {
                // OK
            } catch {
                revert("Artist does not exist");
            }
        }

        Ticket newTicketContract = new Ticket(address(this));
        Event newEvent = new Event(
            address(artistContract),
            _artistIds,
            _artistShares,
            _organizer,
            _date,
            _metadataUri,
            _ticketPrice,
            _totalTickets,
            address(newTicketContract),
            address(organizatorContract),
            _cashOnly,
            _requiresConsent
        );

        newTicketContract.transferOwnership(address(newEvent));

        eventId = nextEventId++;
        events[eventId] = address(newEvent);

        emit EventCreated(eventId, address(newEvent), _organizer);

        return (eventId, address(newEvent));
    }

    function getEventAddress(uint256 _eventId) external view returns (address) {
        require(_eventId > 0 && _eventId < nextEventId, "Event does not exist");
        return events[_eventId];
    }
}
