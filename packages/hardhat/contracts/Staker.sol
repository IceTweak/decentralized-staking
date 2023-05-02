// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

error InvalidStakeAmount(string message);

contract Staker {

  event Stake(address indexed from, uint256 amount);

  ExampleExternalContract public exampleExternalContract;
  uint256 public constant threshold = 1 ether;
  mapping ( address => uint256 ) public balances;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() payable public {
    if (msg.value == 0) {
      revert InvalidStakeAmount({ message: "More than 0 wei needed!" });
    }

    if (balances[msg.sender] == 0) {
      balances[msg.sender] = msg.value;
    } else {
      balances[msg.sender] += msg.value;
    }

    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
