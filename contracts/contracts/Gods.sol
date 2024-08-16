/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import necessary contracts from thirdweb and your custom contracts
import "@thirdweb-dev/contracts/drop/DropERC1155.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";
import "./HeroContract.sol";
import "./Player.sol";

contract Gods is PermissionsEnumerable {
    HeroContract public heroContract;
    Player public playerContract;

    enum BattleStatus { PENDING, STARTED, ENDED }

    struct Battle {
        BattleStatus battleStatus;
        bytes32 battleHash;
        string name;
        address[2] players;
        uint256[2] heroIds;
        address winner;
    }

    mapping(string => uint256) public battleInfo;
    Battle[] public battles;

    event NewBattle(string battleName, address indexed player1, address indexed player2);
    event BattleEnded(string battleName, address indexed winner, address indexed loser);

    constructor(address _heroContractAddress, address _playerContractAddress) {
        heroContract = HeroContract(_heroContractAddress);
        playerContract = Player(_playerContractAddress);
    }

    // Hero battle participation check
    function canHeroBattle(uint256 heroId) public view returns (bool) {
        (,, uint256 dailyBattleLimit, uint256 battlesFoughtToday, uint256 lastBattleTimestamp) = heroContract.getHeroAttributes(heroId);
        return block.timestamp > lastBattleTimestamp + 1 days || battlesFoughtToday < dailyBattleLimit;
    }

    // Create a new battle
    function createBattle(string memory _name, uint256 heroId) external returns (Battle memory) {
        require(canHeroBattle(heroId), "Hero cannot battle yet. Wait until tomorrow or more battles allowed today");
        require(!isBattle(_name), "Battle already exists!");

        bytes32 battleHash = keccak256(abi.encode(_name));

        Battle memory _battle = Battle(
            BattleStatus.PENDING,
            battleHash,
            _name,
            [msg.sender, address(0)],
            [heroId, 0],
            address(0)
        );

        uint256 _id = battles.length;
        battleInfo[_name] = _id;
        battles.push(_battle);

        _updateHeroBattleStats(heroId);

        return _battle;
    }

    // Join an existing battle
    function joinBattle(string memory _name, uint256 heroId) external returns (Battle memory) {
        Battle memory _battle = getBattle(_name);
        require(_battle.battleStatus == BattleStatus.PENDING, "Battle already started!");
        require(_battle.players[0] != msg.sender, "Only player two can join a battle");
        require(canHeroBattle(heroId), "Hero cannot battle yet. Wait until tomorrow or more battles allowed today");

        _battle.battleStatus = BattleStatus.STARTED;
        _battle.players[1] = msg.sender;
        _battle.heroIds[1] = heroId;
        updateBattle(_name, _battle);

        _updateHeroBattleStats(heroId);

        emit NewBattle(_battle.name, _battle.players[0], msg.sender);
        return _battle;
    }

    // Update hero's battle stats after each battle
    function _updateHeroBattleStats(uint256 heroId) internal {
        (,, uint256 dailyBattleLimit, uint256 battlesFoughtToday, uint256 lastBattleTimestamp) = heroContract.getHeroAttributes(heroId);
        if (block.timestamp > lastBattleTimestamp + 1 days) {
            heroContract.resetHeroBattles(heroId);
        }
        heroContract.incrementHeroBattles(heroId);
    }

    // Retrieve battle information by name
    function getBattle(string memory _name) public view returns (Battle memory) {
        return battles[battleInfo[_name]];
    }

    // Check if a battle with the given name exists
    function isBattle(string memory _name) public view returns (bool) {
        return battleInfo[_name] != 0;
    }
}

