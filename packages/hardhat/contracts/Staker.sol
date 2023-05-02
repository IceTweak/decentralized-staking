// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

error InvalidStakeAmount(string message);
error DeadlineNotMet();
error NotOpenToWithdraw();
error InsufficientBalance();
error FailedWithdrawTx();

contract Staker {

  event Stake(address indexed from, uint256 amount);

  ExampleExternalContract public exampleExternalContract;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  bool public openToWithdraw;
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
  function execute() public {
    if (block.timestamp < deadline) {
      revert DeadlineNotMet();
    }

    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openToWithdraw = true;
    }
    
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public {
    if (!openToWithdraw) {
      revert NotOpenToWithdraw();
    }

    if (balances[msg.sender] == 0) {
      revert InsufficientBalance();
    }

    // Call returns a boolean value indicating success or failure.
    (bool sent, bytes memory data) = msg.sender.call
    {
      value: balances[msg.sender]
    }("");

    if (!sent) {
      revert FailedWithdrawTx();
    }

    // Clear balances after withdraw
    delete balances[msg.sender];
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
