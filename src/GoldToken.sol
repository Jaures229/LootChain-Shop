// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GoldToken is ERC20, ERC20Burnable, Ownable {

    // ─── Constants ────────────────────────────────────────────

    uint256 public constant MAX_SUPPLY = 1_000_000 * 10 ** 18; // 1 million GOLD

    // ─── Events ───────────────────────────────────────────────

    event PlayerRewarded(address indexed player, uint256 amount);

    // ─── Constructor ──────────────────────────────────────────

    constructor() ERC20("Gold Token", "GOLD") Ownable(msg.sender) {
        // Mint initial de 100 000 GOLD au owner (réserve du jeu)
        _mint(msg.sender, 100_000 * 10 ** 18);
    }

    // ─── Fonctions principales ────────────────────────────────

    /// @notice Récompense un joueur en GOLD (simule une victoire en jeu)
    /// @dev Seul le owner (serveur de jeu) peut récompenser
    function rewardPlayer(address player, uint256 amount) external onlyOwner {
        require(player != address(0),             "Adresse invalide");
        require(amount > 0,                       "Montant invalide");
        require(totalSupply() + amount <= MAX_SUPPLY, "Supply max atteint");

        _mint(player, amount);
        emit PlayerRewarded(player, amount);
    }

    /// @notice Retourne le solde d'un joueur en GOLD (formaté sans décimales)
    function balanceOfPlayer(address player) external view returns (uint256) {
        return balanceOf(player) / 10 ** 18;
    }
}
