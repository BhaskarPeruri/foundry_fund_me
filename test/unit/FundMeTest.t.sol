//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundmeTest is Test{

    FundMe fundMe;
    DeployFundMe deployFundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //10000 0000 0000 0000 0
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{

        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        vm.deal(USER, STARTING_BALANCE); //giving balance for the USER 
    }

    function testMinimumDollarIsFive() public  view {

        assertEq(fundMe.MINIMUM_USD(), 5e18);
  
    }
    function testOwnerIsMsgSender()public view {
        console.log("msg.semder is ",msg.sender);
        console.log("fundme i_owner is ",fundMe.getOwner());
        console.log("address(this) is", address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();  //hey the next line should revert
        fundMe.fund(); //sending  0 value
    }

/**
 * Testing whether the s_addressToAmountFunded  mapping  is correctly updating or not
 */
    function testFundUpdatesFundedDataStructure() public{

        vm.prank(USER);// the next tx will sent by the USER

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
   /**
    * Checking whether the s_funders array currently working or not
    */ 
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); //passed 0 as index since USER is the first sending the tx.

        assertEq(funder,USER);
    }

    modifier funded{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    /**
     * Testing whether the onlyOwner modifier correctly working or not
     */

    function testOnlyOwnerCanWithdraw() public funded{
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded{
        //Arranging TESTS
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        console.log("startingOwnerBalance ",  fundMe.getOwner().balance); //79228162514264337593543950335
        console.log("startingFundMeBalance ",  address(fundMe).balance); // 10000 0000 0000 0000 0


        //ACT
        vm.prank(fundMe.getOwner()); //pranking as the owner of the FundMe contract
        fundMe.withdraw();

       //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

         console.log("endingOwnerBalance ",  fundMe.getOwner().balance); // 79228162514364337593543950335
        console.log("endingFundMeBalance ",  address(fundMe).balance); // 0


        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance +startingOwnerBalance ,
                endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            console.log("for ",i," FundMeBalance ",  address(fundMe).balance);
            
        }

        /**
         * the balance of fundMe contract is 
         * since we have funded  the fundME contract with 0.1 ether(10^17)
         * and so for first iteration 0.1 + 0.1 = 0.2 =>2*10^17
         *  for  1  FundMeBalance  200000000000000000
            for  2  FundMeBalance  300000000000000000
            for  3  FundMeBalance  400000000000000000
            for  4  FundMeBalance  500000000000000000
            for  5  FundMeBalance  600000000000000000
            for  6  FundMeBalance  700000000000000000
            for  7  FundMeBalance  800000000000000000
            for  8  FundMeBalance  900000000000000000
            for  9  FundMeBalance  1000000000000000000

            79228162514264337593543950335
          +           1000000000000000000 (10^18)
            -------------------------------
          = 79228162515264337593543950335
         */

        uint256  startingOwnerBalance = fundMe.getOwner().balance;
        uint256  startingFundMeBalance = address(fundMe).balance;

        // console.log("startingOwnerBalance ",  fundMe.getOwner().balance); 
        // console.log("startingFundMeBalance ",  address(fundMe).balance);  //10000 0000 0000 0000 00  = 1 ether

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // console.log(" after withdraw startingOwnerBalance ",  fundMe.getOwner().balance); 

        assert(address(fundMe).balance == 0);
        assert( startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // console.log("for ",i," FundMeBalance ",  address(fundMe).balance);
            
        }

        uint256  startingOwnerBalance = fundMe.getOwner().balance;
        uint256  startingFundMeBalance = address(fundMe).balance;

        console.log("startingOwnerBalance ",  fundMe.getOwner().balance); 
        console.log("startingFundMeBalance ",  address(fundMe).balance);  //10000 0000 0000 0000 00  = 1 ether

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        console.log(" after withdraw startingOwnerBalance ",  fundMe.getOwner().balance); 

        assert(address(fundMe).balance == 0);
        assert( startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }


}
