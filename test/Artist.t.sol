// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Artist} from "../contracts/Artist.sol";
import {Test} from "forge-std/Test.sol";

contract ArtistTest is Test {
    function testSafeMintArtist() public {
        address user = address(0x123);
        Artist artistContract = new Artist();
        vm.prank(user);
        artistContract.mintArtist(user, "Test Artist", "ipfs://testartist");
        (string memory name, string memory metadataUri) = artistContract.getArtistInfo(user);
        assertEq(name, "Test Artist");
        assertEq(metadataUri, "ipfs://testartist");
    }
}
