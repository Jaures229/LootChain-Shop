// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GoldToken.sol";
import "../src/GameShop.sol";
import "../src/LootChain.sol";

contract GameShopTest is Test {

    GoldToken public gold;
    LootChain public lootChain;
    GameShop  public shop;

    address public owner   = address(this);
    address public player1 = makeAddr("player1");

    uint256 constant DECIMALS = 10 ** 18;

    function setUp() public {
        // Déployer les contrats
        gold      = new GoldToken();
        lootChain = new LootChain();
        shop      = new GameShop(address(gold), address(lootChain));

        // Donner le rôle MINTER à GameShop
        lootChain.grantRole(lootChain.MINTER_ROLE(), address(shop));

        // Donner 500 GOLD à player1
        gold.rewardPlayer(player1, 500 * DECIMALS);
    }

    // ─── Tests de base ────────────────────────────────────────

    function test_Shop_A10ItemsAuDepart() public view {
        assertEq(shop.itemCount(), 10);
    }

    function test_Shop_ItemsDisponibles() public view {
        GameShop.ShopItem[] memory items = shop.getShopItems();
        for (uint256 i = 0; i < items.length; i++) {
            assertTrue(items[i].available);
        }
    }

    // ─── Tests buyItem ────────────────────────────────────────

    function test_BuyItem_MintNFTauJoueur() public {
        // Player1 approuve le shop à dépenser ses GOLD
        vm.prank(player1);
        gold.approve(address(shop), 50 * DECIMALS);

        // Player1 achète l'item 0 (Sword of Embers = 50 GOLD)
        vm.prank(player1);
        uint256 tokenId = shop.buyItem(0);

        // Vérifie que le NFT appartient à player1
        assertEq(lootChain.ownerOf(tokenId), player1);
    }

    function test_BuyItem_BruleGOLD() public {
        uint256 balanceAvant = gold.balanceOf(player1);

        vm.prank(player1);
        gold.approve(address(shop), 50 * DECIMALS);

        vm.prank(player1);
        shop.buyItem(0); // Sword of Embers = 50 GOLD

        // Vérifie que les GOLD ont été brûlés
        assertEq(gold.balanceOf(player1), balanceAvant - 50 * DECIMALS);
    }

    function test_BuyItem_SoldeInsuffisantRevert() public {
        // player1 a 500 GOLD — essayer d'acheter sans approve
        vm.prank(player1);
        vm.expectRevert();
        shop.buyItem(0);
    }

    function test_BuyItem_SansApprobationRevert() public {
        // Pas d'approve → doit échouer
        vm.prank(player1);
        vm.expectRevert();
        shop.buyItem(0);
    }

    function test_BuyItem_EmitItemPurchased() public {
        vm.prank(player1);
        gold.approve(address(shop), 50 * DECIMALS);

        vm.expectEmit(true, true, false, false);
        emit GameShop.ItemPurchased(player1, 0, 0, 50 * DECIMALS);

        vm.prank(player1);
        shop.buyItem(0);
    }

    // ─── Tests owner ──────────────────────────────────────────

    function test_AddItem_OwnerPeutAjouter() public {
        shop.addItem("Magic Wand", 40 * DECIMALS, 0);
        assertEq(shop.itemCount(), 11);
    }

    function test_AddItem_NonOwnerRevert() public {
        vm.prank(player1);
        vm.expectRevert();
        shop.addItem("Magic Wand", 40 * DECIMALS, 0);
    }

    function test_SetAvailability_DesactiverItem() public {
        shop.setItemAvailability(0, false);

        vm.prank(player1);
        gold.approve(address(shop), 50 * DECIMALS);

        vm.prank(player1);
        vm.expectRevert();
        shop.buyItem(0);
    }
}
