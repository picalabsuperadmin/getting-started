// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@thirdweb-dev/contracts/drop/DropERC1155.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";
import "@thirdweb-dev/contracts/extension/Ownable.sol";

contract HeroContract is DropERC1155, Ownable, PermissionsEnumerable {
    struct HeroAttributes {
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 health;
        uint256 magicPower;
        uint256 stamina;
        uint256 dailyBattleLimit;
        uint256 battlesFoughtToday;
        uint256 lastBattleTimestamp;
    }

    mapping(uint256 => HeroAttributes) public heroAttributes;
    mapping(uint256 => uint256) public heroShardSupply; // Mapping to keep track of hero shards

    event HeroMinted(address indexed player, uint256 indexed heroId, uint256 amount);
    event HeroUpgraded(uint256 indexed heroId, HeroAttributes newAttributes);
    event HeroShardsMinted(address indexed player, uint256 indexed heroId, uint256 amount);
    event HeroShardsBurned(address indexed player, uint256 indexed heroId, uint256 amount);
    event HeroCombined(uint256 indexed newHeroId, address indexed owner);

    constructor() {
        initializeHeroAttributes();
    }

    function initializeHeroAttributes() internal {
        heroAttributes[1] = HeroAttributes(80, 60, 70, 300, 90, 4, 3, 0, block.timestamp);
        heroAttributes[2] = HeroAttributes(75, 85, 80, 350, 70, 3, 3, 0, block.timestamp);
        // Add more heroes as needed
    }

    function mintHero(address to, uint256 heroId, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, heroId, amount, "");
        emit HeroMinted(to, heroId, amount);
    }

    function mintHeroShards(address to, uint256 heroId, uint256 amount) external onlyRole(MINTER_ROLE) {
        heroShardSupply[heroId] += amount;
        _mint(to, heroId, amount, "");
        emit HeroShardsMinted(to, heroId, amount);
    }

    function burnHeroShards(address from, uint256 heroId, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(heroShardSupply[heroId] >= amount, "Not enough shards");
        heroShardSupply[heroId] -= amount;
        _burn(from, heroId, amount);
        emit HeroShardsBurned(from, heroId, amount);
    }

    function combineShardsToHero(address to, uint256 heroId1, uint256 heroId2) external onlyRole(MINTER_ROLE) {
        uint256 newHeroId = _generateNewHeroId(heroId1, heroId2);

        // Burn shards for both heroIds
        burnHeroShards(to, heroId1, 1);
        burnHeroShards(to, heroId2, 1);

        // Mint a new hero with combined attributes
        HeroAttributes memory combinedAttributes = _combineAttributes(heroId1, heroId2);
        heroAttributes[newHeroId] = combinedAttributes;
        _mint(to, newHeroId, 1, "");

        emit HeroCombined(newHeroId, to);
    }

    function upgradeHeroAttributes(uint256 heroId, HeroAttributes memory newAttributes) external onlyRole(DEFAULT_ADMIN_ROLE) {
        heroAttributes[heroId] = newAttributes;
        emit HeroUpgraded(heroId, newAttributes);
    }

    function getHeroAttributes(uint256 heroId) external view returns (HeroAttributes memory) {
        return heroAttributes[heroId];
    }

    function _generateNewHeroId(uint256 heroId1, uint256 heroId2) internal pure returns (uint256) {
        // Implement your logic to generate a new hero ID based on the combined heroes
        return uint256(keccak256(abi.encodePacked(heroId1, heroId2)));
    }

    function _combineAttributes(uint256 heroId1, uint256 heroId2) internal view returns (HeroAttributes memory) {
        HeroAttributes memory attrs1 = heroAttributes[heroId1];
        HeroAttributes memory attrs2 = heroAttributes[heroId2];

        // Simple example: average the attributes of both heroes to create a new hero
        HeroAttributes memory combinedAttributes = HeroAttributes({
            attack: (attrs1.attack + attrs2.attack) / 2,
            defense: (attrs1.defense + attrs2.defense) / 2,
            speed: (attrs1.speed + attrs2.speed) / 2,
            health: (attrs1.health + attrs2.health) / 2,
            magicPower: (attrs1.magicPower + attrs2.magicPower) / 2,
            stamina: (attrs1.stamina + attrs2.stamina) / 2,
            dailyBattleLimit: (attrs1.dailyBattleLimit + attrs2.dailyBattleLimit) / 2,
            battlesFoughtToday: 0, // Reset for the new hero
            lastBattleTimestamp: block.timestamp
        });

        return combinedAttributes;
    }

    function _msgSender()
    internal
    view
    override(ContextUpgradeable, DropERC1155)
    returns (address sender)
    {
        return DropERC1155._msgSender();
    }

    function _msgData()
    internal
    view
    override(ContextUpgradeable, DropERC1155)
    returns (bytes calldata)
    {
        return DropERC1155._msgData();
    }
}

