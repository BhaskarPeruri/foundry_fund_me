//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

/*
In Solidity, a mock contract is a second version of a contract that behaves similarly to the original. 
It's a design pattern that allows developers to control the mock contract more easily.

1.Deploy mocks when we are on a  local anvil chain
2.Keep track of contract address across different chains

SEPOLIA ETH/USD
Mainnet ETH/USD
*/

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator}  from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    /**
     * If we are on a local anvil, we deply mocks
     * Otherwise, grab the existing address from the live network
     */
    NetworkConfig public activeNetworkConfig;

    uint8 public constant  DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;   //ETH/USD pricefeed address
    }

    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        else{
             activeNetworkConfig = getOrCreateAnvilEthConfig();

        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        //all we need in sepolia is pricefeed address

        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
        

    }
    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        //all we need in Ethereum is pricefeed address

        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return ethConfig;
        

    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        //pricefeed address 

        /** 
         *  Mock contract is like a dummy contract and it works like a real contract but we own it  and we can control it.
         * First step is to deploy the mock
         *  Second step is to return the mock address
        */
       if(activeNetworkConfig.priceFeed!=address(0)){
            return activeNetworkConfig;
       }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(
            {priceFeed:address(mockPriceFeed)});
        
        return anvilConfig;
    }
}