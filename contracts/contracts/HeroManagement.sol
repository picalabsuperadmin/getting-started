// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@thirdweb-dev/contracts/drop/DropERC1155.sol"; // Import DropERC1155 which includes access control
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";

contract MyModularContract is DropERC1155, PermissionsEnumerable {

    struct HeroAttributes {
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 health;
        uint256 magicPower;
        uint256 stamina;
    }

    mapping(uint256 => HeroAttributes) public heroAttributes;

    uint256 public constant DEVIL = 0;
    uint256 public constant GRIFFIN = 1;
    uint256 public constant FIREBIRD = 2;
    uint256 public constant KAMO = 3;
    uint256 public constant KUKULKAN = 4;
    uint256 public constant CELESTION = 5;

    event HeroAttributesUpdated(uint256 indexed heroId, HeroAttributes attributes);

    constructor() {
        initializeHeroAttributes();
    }

    function initializeHeroAttributes() internal {
        heroAttributes[DEVIL] = HeroAttributes(80, 60, 70, 300, 90, 4);
        heroAttributes[GRIFFIN] = HeroAttributes(75, 85, 80, 350, 70, 3);
        heroAttributes[FIREBIRD] = HeroAttributes(90, 50, 100, 280, 95, 5);
        heroAttributes[KAMO] = HeroAttributes(60, 70, 75, 320, 65, 3);
        heroAttributes[KUKULKAN] = HeroAttributes(85, 65, 80, 330, 90, 4);
        heroAttributes[CELESTION] = HeroAttributes(70, 80, 85, 340, 75, 3);
    }

    function updateHeroAttributes(uint256 heroId, HeroAttributes memory newAttributes) external onlyRole(DEFAULT_ADMIN_ROLE) {
        heroAttributes[heroId] = newAttributes;
        emit HeroAttributesUpdated(heroId, newAttributes);
    }

    function getHeroAttributes(uint256 heroId) external view returns (HeroAttributes memory) {
        return heroAttributes[heroId];
    }

    function mintHero(address to, uint256 heroId, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, heroId, amount, "");
    }

    function burnHero(address from, uint256 heroId, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, heroId, amount);
    }

    function updateTokenURI(uint256 heroId, string memory newURI) external onlyRole(METADATA_ROLE) {
        _setURI(heroId, newURI);
    }
}

