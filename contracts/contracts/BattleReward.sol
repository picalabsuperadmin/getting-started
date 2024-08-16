// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HeroShard.sol";
import "@thirdweb-dev/contracts/extension/Ownable.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";

contract BattleReward is Ownable, PermissionsEnumerable {

    HeroShard public heroShard;

    event BattleRewardGiven(address indexed winner, uint256 indexed heroId, uint256 shardAmount);

    constructor(address _heroShardAddress) {
        heroShard = HeroShard(_heroShardAddress);
    }

    function distributeShards(address winner, uint256 heroId, uint256 shardAmount) external onlyRole(REWARD_DISTRIBUTOR_ROLE) {
        heroShard.mintShards(winner, heroId, shardAmount);
        emit BattleRewardGiven(winner, heroId, shardAmount);
    }
}

