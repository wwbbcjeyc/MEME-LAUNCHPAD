// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MockWBNB} from "../test/mocks/MockWBNB.sol";
import {MockPancakeRouter} from "../test/mocks/MockPancakeRouter.sol";
import {Deployer} from "./Deployer.sol";

contract DeployMockScript is Deployer {
    function setUp() public override {
        projectName = "mova_test/";
        environment = "dev";
        super.setUp();
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying Mock contracts...");
        console.log("Deployer:", deployer);
        console.log("-----------------------------------");

        vm.startBroadcast(deployerPrivateKey);

        deployMockWBNB();
        deployMockRouter();

        vm.stopBroadcast();
    }

    function deployMockWBNB() public returns (address) {
        MockWBNB wbnb = new MockWBNB();
        save("MockWBNB", address(wbnb));
        console.log("MockWBNB deployed at:", address(wbnb));
        return address(wbnb);
    }

    function deployMockRouter() public returns (address) {
        address wbnbAddr = getAddress("MockWBNB");
        require(wbnbAddr != address(0), "MockWBNB not deployed");

        MockPancakeRouter router = new MockPancakeRouter(wbnbAddr);
        save("MockRouter", address(router));
        console.log("MockRouter deployed at:", address(router));
        return address(router);
    }
}
