// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Tickethic} from "../contracts/Tickethic.sol";
import {Test} from "forge-std/Test.sol";

contract TickethicTest is Test {
    Tickethic private tickethicContract;
    address private artist1;
    address private artist2;
    address private artist3;

    function setUp() public {
        // Deploy Artist and Ticket contracts
        tickethicContract = new Tickethic();

        artist1 = makeAddr("artist1");
        artist2 = makeAddr("artist2");
        artist3 = makeAddr("artist3");

        // Mint 3 artists
        vm.prank(artist1);
        tickethicContract.createArtist("Artist1", "ipfs://artist1");
        vm.prank(artist2);
        tickethicContract.createArtist("Artist2", "ipfs://artist2");
        tickethicContract.createArtist("Artist3", "ipfs://artist3", artist3);
    }

    function testHasArtistMintedWithRightAddress() public {
        assertEq(tickethicContract.getAllArtistAddresses().length, 3, "Should have 3 artists");

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

        // Act as artist3 and fetch its artist info
        vm.prank(artist3);
        (string memory name3, string memory metadataURI3) = tickethicContract.getMyArtistInfo();

        // Assert the data is correct
        assertEq(name3, "Artist3");
        assertEq(metadataURI3, "ipfs://artist3");
    }
} 

 