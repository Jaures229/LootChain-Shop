# LootChain Shop 🏪

> On-chain game economy — ERC-20 Gold Token + decentralized item shop powered by LootChain NFTs.

## Overview

LootChain Shop is the economic layer of the LootChain ecosystem. Players earn `$GOLD` tokens by playing, then spend them to purchase NFT items directly on-chain. The shop burns `$GOLD` on every purchase, creating a deflationary economy.

## Features

- 💰 **$GOLD Token (ERC-20)** — in-game currency with a 1,000,000 max supply
- 🏪 **On-chain shop** — 10 items available, each with a fixed $GOLD price
- 🔥 **Deflationary** — $GOLD is burned (destroyed) on every purchase
- 🔐 **CEI Pattern** — checks → effects → interactions (reentrancy-safe)
- 🛡️ **ReentrancyGuard** — double protection against reentrancy attacks
- 🎭 **AccessControl** — MINTER_ROLE allows GameShop to mint NFTs
- 💱 **Buy & Sell system** — players can sell their NFTs back for $GOLD
- 💎 **Rarity-based sell prices** — Common: 10 / Rare: 25 / Epic: 50 / Legendary: 100
- ✅ **27/27 tests passing**

## Contracts

| Contract | Network | Address |
|---|---|---|
| `GoldToken.sol` | Sepolia | `0xbcB4aED233C33DB9Bd110828329F59bBfCa88D99` |
| `LootChain.sol` | Sepolia | `0x6d341D6aE34Ff9F6B1e739CeA6F2dc301Cf8aa79` |
| `GameShop.sol` | Sepolia | `0x75D31e68730a02d61fd8695f95d887Cd2AA28003` |

## Shop Catalogue

| Item | Price ($GOLD) |
|---|---|
| Sword of Embers | 50 |
| Frost Dagger | 30 |
| Thunder Axe | 75 |
| Shadow Blade | 60 |
| Ancient Staff | 100 |
| Iron Shield | 20 |
| Dragon Scale | 80 |
| Phantom Cloak | 45 |
| Storm Gauntlets | 55 |
| Relic Armor | 90 |

## Sell Prices (by Rarity)

| Rarity | $GOLD Received |
|---|---|
| Common | 10 |
| Rare | 25 |
| Epic | 50 |
| Legendary | 100 |

## Purchase Flow

```
1. Owner rewards player with $GOLD (rewardPlayer)
        ↓
2. Player approves GameShop to spend $GOLD (approve)
        ↓
3. Player buys an item (buyItem)
        ↓
4. GameShop burns $GOLD from player (burnFrom)
        ↓
5. GameShop mints the NFT to player (mintLoot)
        ↓
6. Player receives NFT item in their wallet ✅
```

## Sell Flow

```
1. Player approves GameShop to transfer their NFT (approve)
        ↓
2. Player sells the NFT (sellItem)
        ↓
3. GameShop transfers NFT from player to itself
        ↓
4. GameShop burns the NFT (burnToken)
        ↓
5. GameShop mints $GOLD to player based on rarity ✅
```

## Security

```
CEI Pattern (Checks → Effects → Interactions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Checks      → verify balance, allowance, stock, availability
2. Effects     → update stock, burn $GOLD
3. Interactions → mint NFT to player

+ nonReentrant modifier for double protection
```

## Tech Stack

- **Solidity** `^0.8.20`
- **Foundry** (forge, cast, anvil)
- **OpenZeppelin** — ERC20, ERC20Burnable, AccessControl, ReentrancyGuard, Ownable
- **Sepolia** testnet

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/)
- MetaMask wallet with Sepolia ETH
- Alchemy RPC URL
- Etherscan API key

### Installation

```bash
git clone https://github.com/Jaures229/LootChainShop
cd LootChainShop
forge install
```

### Environment setup

Create a `.env` file:

```
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=your_alchemy_url
ETHERSCAN_API_KEY=your_etherscan_key
```

### Run tests

```bash
forge test -vv
```

### Deploy

```bash
source .env
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  -vvv
```

## Contract Functions

### GoldToken

| Function | Access | Description |
|---|---|---|
| `rewardPlayer(address, uint256)` | Owner | Mint $GOLD to a player |
| `burn(uint256)` | Player | Burn own $GOLD |
| `burnFrom(address, uint256)` | Approved | Burn $GOLD from an address |
| `balanceOfPlayer(address)` | Public | Returns balance without decimals |

### GameShop

| Function | Access | Description |
|---|---|---|
| `buyItem(uint256 itemId)` | Public | Purchase an item with $GOLD |
| `sellItem(uint256 tokenId)` | Public | Sell an NFT back for $GOLD |
| `addItem(string, uint256, uint256)` | Owner | Add a new item to the shop |
| `setItemAvailability(uint256, bool)` | Owner | Enable/disable an item |
| `setSellPrice(Rarity, uint256)` | Owner | Update sell price for a rarity |
| `getShopItems()` | Public | Returns all shop items |

## Project Structure

```
LootChainShop/
├── src/
│   ├── GoldToken.sol       # ERC-20 in-game currency
│   ├── GameShop.sol        # On-chain item shop
│   └── LootChain.sol       # ERC-721 NFT (from LootChain)
├── test/
│   ├── GoldToken.t.sol     # 10 tests
│   └── GameShop.t.sol      # 10 tests
├── script/
│   └── Deploy.s.sol        # Deploys all 3 contracts
└── foundry.toml
```

## Part of the LootChain Ecosystem

```
LootChain       → NFT loot drop system
LootChain Shop  → Gold token + in-game shop  (this repo)
LootChain Game  → 2D Unity game (coming soon)
```
