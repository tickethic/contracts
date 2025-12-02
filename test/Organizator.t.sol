// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Organizator} from "../contracts/Organizator.sol";
import {Test} from "forge-std/Test.sol";

contract OrganizatorTest is Test {
    function testSafeMintOrganizator() public {
        address user = address(0x123);
        Organizator organizatorContract = new Organizator();
        vm.prank(user);
        organizatorContract.mint(user, "Test", "ipfs://test");
        (string memory name, string memory metadataUri) = organizatorContract.getInfo(user);
        assertEq(name, "Test");
        assertEq(metadataUri, "ipfs://test");
    }
}
