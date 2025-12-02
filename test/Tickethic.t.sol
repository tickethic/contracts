// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Tickethic} from "../contracts/Tickethic.sol";
import {Test} from "forge-std/Test.sol";

contract TickethicTest is Test {
    Tickethic private tickethicContract;
    address private artist1;
    address private artist2;
    address private organizator1;
    address private organizator2;

    function setUp() public {
        // Deploy Tickethic
        tickethicContract = new Tickethic();

        artist1 = makeAddr("artist1");
        artist2 = makeAddr("artist2");

        // Mint artists
        vm.prank(artist1);
        tickethicContract.createArtist("Artist1", "ipfs://artist1");
        tickethicContract.createArtist("Artist2", "ipfs://artist2", artist2);


        organizator1 = makeAddr("oragnizator1");
        organizator2 = makeAddr("oragnizator2");

        // Mint Organizator
        vm.prank(organizator1);
        tickethicContract.createOrganizator("Oragnizator1", "ipfs://o1");
        tickethicContract.createOrganizator("Oragnizator2", "ipfs://o2", organizator2);
    }

    function testHasArtistMintedWithRightAddress() public {
        assertEq(tickethicContract.getTotalArtists(), 2, "Should have 2 artists");

        // Act as artist1 and fetch its artist info
        vm.prank(artist1);
        (string memory name1, string memory metadataURI1) = tickethicContract.getMyArtistInfo();

        // Assert the data is correct
        assertEq(name1, "Artist1");
        assertEq(metadataURI1, "ipfs://artist1");

        (string memory name2, string memory metadataURI2) = tickethicContract.getArtistInfo(artist2);

        // Assert the data is correct
        assertEq(name2, "Artist2");
        assertEq(metadataURI2, "ipfs://artist2");
    }

    function testHasOrganizatorMintedWithRightAddress() public {
        assertEq(tickethicContract.getTotalOrganizators(), 2, "Should have 2 organizators");

        // Act as organizator1 and fetch its info
        vm.prank(organizator1);
        (string memory name1, string memory metadataURI1) = tickethicContract.getMyOrganizatorInfo();

        // Assert the data is correct
        assertEq(name1, "Oragnizator1");
        assertEq(metadataURI1, "ipfs://o1");

        (string memory name2, string memory metadataURI2) = tickethicContract.getOrganizatorInfo(organizator2);

        // Assert the data is correct
        assertEq(name2, "Oragnizator2");
        assertEq(metadataURI2, "ipfs://o2");
    }

    function testCreateEvent() public {
        address[] memory artists = new address[](2);
        artists[0] = artist1;
        artists[1] = artist2;

        uint256[] memory shares = new uint256[](2);
        shares[0] = 30;
        shares[1] = 40;

        uint256 date = block.timestamp + 1 days;
        string memory metadataURI = "ipfs://event1";
        uint256 ticketPrice = 0.001 ether;
        uint256 totalTickets = 100;

        vm.prank(organizator2);
        address eventAddr = tickethicContract.createEvent(
            artists,
            shares,
            date,
            metadataURI,
            ticketPrice,
            totalTickets
        );

        assertEq(tickethicContract.getAllEvents()[0], eventAddr);

        (
            address organizer,
            address[] memory evArtists,
            uint256[] memory evShares,
            uint256 evDate,
            string memory evMetadataURI,
            uint256 evTicketPrice,
            uint256 evTotalTickets
        ) = tickethicContract.getEventInfo(tickethicContract.getAllEvents()[0]);

        assertEq(organizer, organizator2);
        assertEq(evArtists[0], artist1);
        assertEq(evArtists[1], artist2);
        assertEq(evShares[0], 30);
        assertEq(evShares[1], 40);
        assertEq(evDate, date);
        assertEq(evMetadataURI, metadataURI);
        assertEq(evTicketPrice, ticketPrice);
        assertEq(evTotalTickets, totalTickets);
    }
} 

 