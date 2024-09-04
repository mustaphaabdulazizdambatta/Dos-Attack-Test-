// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/denial-of-service/DoS.sol";  // Ensure this path is correct;

contract DoSTest is Test {
    DoS public dosContract;

    function setUp() public {
        dosContract = new DoS();
    }

    function testEnterWithFewEntrants() public {
        dosContract.enter();
        assertEq(getEntrant(0), address(this));
    }

    function testEnterGasLimitDoS() public {
    for (uint256 i = 0; i < 1000; i++) {
        address entrant = address(uint160(i + 1));
        vm.prank(entrant);
        dosContract.enter();
    }

    try dosContract.enter() {
        emit log("Test failed: Expected this to fail due to gas limit exceeded.");
    } catch Error(string memory reason) {
        emit log(reason);
    } catch (bytes memory /*lowLevelData*/) {
        emit log("Caught low-level error due to gas limit exceeded.");
    }
}

    // Helper function to access the entrants array using storage slot manipulation
    function getEntrant(uint256 index) public view returns (address) {
        bytes32 slot = keccak256(abi.encodePacked(uint256(0))); // Assuming 'entrants' is at storage slot 0
        bytes32 hashedIndex = keccak256(abi.encodePacked(slot, index));
        return address(uint160(uint256(vm.load(address(dosContract), hashedIndex))));
    }
}
