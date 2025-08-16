// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyCatCoin.sol";

contract MyCatCoinTest is Test {
    MyCatCoin public myCatCoin;
    address public owner;
    address public user1;
    uint256 public initialSupply;

    function setUp() public {
        myCatCoin = new MyCatCoin();
        owner = msg.sender;
        user1 = address(1);
        initialSupply = myCatCoin.totalSupply();
    }

    function test_InitialSupply() public {
        assertEq(myCatCoin.balanceOf(owner), initialSupply, "Owner should have the initial supply");
    }

    function test_Transfer() public {
        uint256 amount = 100 * (10 ** myCatCoin.decimals());
        myCatCoin.transfer(user1, amount);
        
        assertEq(myCatCoin.balanceOf(owner), initialSupply - amount, "Owner balance should be reduced");
        assertEq(myCatCoin.balanceOf(user1), amount, "User1 should receive the tokens");
    }

    function test_ApproveAndTransferFrom() public {
        uint256 approveAmount = 500 * (10 ** myCatCoin.decimals());
        uint256 transferAmount = 100 * (10 ** myCatCoin.decimals());
        
        vm.prank(owner);
        myCatCoin.approve(user1, approveAmount);
        
        assertEq(myCatCoin.allowance(owner, user1), approveAmount, "Allowance should be set correctly");
        
        vm.prank(user1);
        myCatCoin.transferFrom(owner, user1, transferAmount);
        
        assertEq(myCatCoin.balanceOf(owner), initialSupply - transferAmount, "Owner balance should be reduced after transferFrom");
        assertEq(myCatCoin.balanceOf(user1), transferAmount, "User1 should have the transferred tokens");
        assertEq(myCatCoin.allowance(owner, user1), approveAmount - transferAmount, "Allowance should be reduced");
    }

    function testFail_TransferFromWithoutApproval() public {
        uint256 amount = 100 * (10 ** myCatCoin.decimals());
        
        vm.prank(user1);
        myCatCoin.transferFrom(owner, user1, amount);
    }
}
