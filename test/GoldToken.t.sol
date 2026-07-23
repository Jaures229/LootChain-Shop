// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GoldToken.sol";

contract GoldTokenTest is Test {

    GoldToken public gold;

    address public owner   = address(this);
    address public player1 = makeAddr("player1");
    address public player2 = makeAddr("player2");

    uint256 constant DECIMALS = 10 ** 18;

    function setUp() public {
        gold = new GoldToken();
    }

    // ─── Tests de base ────────────────────────────────────────

    function test_NomEtSymbole() public view {
        assertEq(gold.name(),   "Gold Token");
        assertEq(gold.symbol(), "GOLD");
    }

    function test_MintInitial_OwnerRecoit100k() public view {
        assertEq(gold.balanceOf(owner), 100_000 * DECIMALS);
    }

    function test_MaxSupply_Est1Million() public view {
        assertEq(gold.MAX_SUPPLY(), 1_000_000 * DECIMALS);
    }

    // ─── Tests rewardPlayer ───────────────────────────────────

    function test_RewardPlayer_MintGOLD() public {
        gold.rewardPlayer(player1, 100 * DECIMALS);
        assertEq(gold.balanceOf(player1), 100 * DECIMALS);
    }

    function test_RewardPlayer_EmitEvent() public {
        vm.expectEmit(true, false, false, true);
        emit GoldToken.PlayerRewarded(player1, 100 * DECIMALS);
        gold.rewardPlayer(player1, 100 * DECIMALS);
    }

    function test_RewardPlayer_SeulOwnerPeutRecompenser() public {
        vm.prank(player1);
        vm.expectRevert();
        gold.rewardPlayer(player2, 100 * DECIMALS);
    }

    function test_RewardPlayer_AdresseZeroRevert() public {
        vm.expectRevert();
        gold.rewardPlayer(address(0), 100 * DECIMALS);
    }

    function test_RewardPlayer_MontantZeroRevert() public {
        vm.expectRevert();
        gold.rewardPlayer(player1, 0);
    }

    function test_RewardPlayer_MaxSupplyRevert() public {
        // Essayer de mint plus que le MAX_SUPPLY
        uint256 remaining = gold.MAX_SUPPLY() - gold.totalSupply();
        vm.expectRevert();
        gold.rewardPlayer(player1, remaining + 1 * DECIMALS);
    }

    // ─── Tests burn ───────────────────────────────────────────

    function test_Burn_ReducitLesolde() public {
        gold.rewardPlayer(player1, 100 * DECIMALS);

        vm.prank(player1);
        gold.burn(50 * DECIMALS);

        assertEq(gold.balanceOf(player1), 50 * DECIMALS);
    }

    function test_BurnFrom_AvecApprobation() public {
        gold.rewardPlayer(player1, 100 * DECIMALS);

        vm.prank(player1);
        gold.approve(owner, 50 * DECIMALS);

        gold.burnFrom(player1, 50 * DECIMALS);
        assertEq(gold.balanceOf(player1), 50 * DECIMALS);
    }

    // ─── Tests balanceOfPlayer ────────────────────────────────

    function test_BalanceOfPlayer_SansDecimales() public {
        gold.rewardPlayer(player1, 250 * DECIMALS);
        assertEq(gold.balanceOfPlayer(player1), 250);
    }
}
