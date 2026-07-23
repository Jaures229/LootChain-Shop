// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GoldToken.sol";
import "./LootChain.sol";

contract GameShop is Ownable, ReentrancyGuard {

    // ─── Structures ───────────────────────────────────────────

    struct ShopItem {
        string  name;
        uint256 price;      // en GOLD (avec 18 décimales)
        uint256 stock;      // 0 = illimité
        bool    available;
    }

    // ─── Storage ──────────────────────────────────────────────

    GoldToken public goldToken;
    LootChain public lootChain;

    mapping(uint256 => ShopItem) public items;
    uint256 public itemCount;

    // ─── Events ───────────────────────────────────────────────

    event ItemAdded(uint256 indexed itemId, string name, uint256 price);
    event ItemPurchased(
        address indexed buyer,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price
    );
    event ItemAvailabilityUpdated(uint256 indexed itemId, bool available);

    // ─── Constructor ──────────────────────────────────────────

    constructor(address goldTokenAddress, address lootChainAddress)
        Ownable(msg.sender)
    {
        goldToken = GoldToken(goldTokenAddress);
        lootChain = LootChain(lootChainAddress);

        // Ajouter les items de base au shop
        _addItem("Sword of Embers",  50  * 10 ** 18, 0);
        _addItem("Frost Dagger",     30  * 10 ** 18, 0);
        _addItem("Thunder Axe",      75  * 10 ** 18, 0);
        _addItem("Shadow Blade",     60  * 10 ** 18, 0);
        _addItem("Ancient Staff",    100 * 10 ** 18, 0);
        _addItem("Iron Shield",      20  * 10 ** 18, 0);
        _addItem("Dragon Scale",     80  * 10 ** 18, 0);
        _addItem("Phantom Cloak",    45  * 10 ** 18, 0);
        _addItem("Storm Gauntlets",  55  * 10 ** 18, 0);
        _addItem("Relic Armor",      90  * 10 ** 18, 0);
    }

    // ─── Fonctions principales ────────────────────────────────

    /// @notice Acheter un item du shop
    /// @dev Protégé contre la reentrancy
    function buyItem(uint256 itemId) external nonReentrant returns (uint256) {
        ShopItem storage item = items[itemId];

        require(item.available,                          "Item non disponible");
        require(item.stock == 0 || item.stock > 0,       "Stock epuise");
        require(
            goldToken.balanceOf(msg.sender) >= item.price,
            "Solde GOLD insuffisant"
        );
        require(
            goldToken.allowance(msg.sender, address(this)) >= item.price,
            "Approbation GOLD insuffisante"
        );

        // Mettre à jour le stock si limité
        if (item.stock > 0) {
            item.stock--;
            if (item.stock == 0) item.available = false;
        }

        // Brûler les GOLD du joueur (CEI pattern : checks → effects → interactions)
        goldToken.burnFrom(msg.sender, item.price);

        // Mint le NFT au joueur
        uint256 tokenId = lootChain.mintLoot(msg.sender);

        emit ItemPurchased(msg.sender, itemId, tokenId, item.price);

        return tokenId;
    }

    /// @notice Ajouter un nouvel item au shop
    function addItem(
        string calldata name,
        uint256 price,
        uint256 stock
    ) external onlyOwner {
        _addItem(name, price, stock);
    }

    /// @notice Modifier la disponibilité d'un item
    function setItemAvailability(uint256 itemId, bool available)
        external
        onlyOwner
    {
        require(itemId < itemCount, "Item inexistant");
        items[itemId].available = available;
        emit ItemAvailabilityUpdated(itemId, available);
    }

    /// @notice Retourne tous les items du shop
    function getShopItems() external view returns (ShopItem[] memory) {
        ShopItem[] memory allItems = new ShopItem[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            allItems[i] = items[i];
        }
        return allItems;
    }

    // ─── Logique interne ──────────────────────────────────────

    function _addItem(
        string memory name,
        uint256 price,
        uint256 stock
    ) private {
        items[itemCount] = ShopItem(name, price, stock, true);
        emit ItemAdded(itemCount, name, price);
        itemCount++;
    }
}
