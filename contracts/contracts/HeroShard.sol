/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@thirdweb-dev/contracts/drop/DropERC1155.sol";
import "@thirdweb-dev/contracts/extension/Ownable.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";

contract HeroShard is DropERC1155, Ownable, PermissionsEnumerable {

    event ShardsMinted(address indexed player, uint256 indexed heroId, uint256 amount);
    event ShardsBurned(address indexed player, uint256 indexed heroId, uint256 amount);

    constructor() {
        // Initialize the contract with any necessary logic
    }

    function mintShards(address player, uint256 heroId, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(player, heroId, amount, "");
        emit ShardsMinted(player, heroId, amount);
    }

    function burnShards(address player, uint256 heroId, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(player, heroId, amount);
        emit ShardsBurned(player, heroId, amount);
    }
}

