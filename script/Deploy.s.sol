// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/GoldToken.sol";
import "../src/GameShop.sol";
import "../src/LootChain.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        // 1. Déployer GoldToken
        GoldToken gold = new GoldToken();
        console.log("GoldToken deploye a :", address(gold));

        // 2. Déployer LootChain
        LootChain lootChain = new LootChain();
        console.log("LootChain deploye a :", address(lootChain));

        // 3. Déployer GameShop
        GameShop shop = new GameShop(address(gold), address(lootChain));
        console.log("GameShop deploye a  :", address(shop));

        // 4. Donner le rôle MINTER à GameShop
        lootChain.grantRole(lootChain.MINTER_ROLE(), address(shop));
        console.log("Role MINTER accorde a GameShop");

        vm.stopBroadcast();
    }
}
