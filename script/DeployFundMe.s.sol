// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import{Script} from "forge-std/Script.sol";
import{FundMe} from "../src/FundMe.sol";
import{HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{

   
    function run() external returns(FundMe){

        // anything you send before broadcast is not a "real" transaction
        HelperConfig  helperConfig = new HelperConfig();
        // (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();  //following line of code is also same
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();


        vm.startBroadcast();
        //After broadcast is a real transaction
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return  fundMe;
    }

   
}