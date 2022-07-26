// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./interfaces/ITools.sol";
import "./interfaces/IBlackList.sol";
import "./interfaces/IMining.sol";

contract Mining is Initializable, PausableUpgradeable, OwnableUpgradeable, IMining {
    IERC20 public berry;
    IERC20 public tree;
    IERC20 public gold;

    ITools public tools;
    IBlackList public blacklist;

    uint256 public miningTime;
    
    uint256 private _energyTokenAmount;
    uint256 private _toolTypeAmount;

    mapping (address => MiningSession) session;
    // tool type => resource
    // -----------------------------
    // 1 - raspberry bush => berry
    // 2 - strawberry bush => berry
    // 3 - grapes => berry
    // 4 - magic berry => berry
    // -----------------------------
    // 5 - birch grove => tree
    // 6 - lumberjack's hut => tree
    // 7 - detachment of lumberjacks => tree
    // 8 - big sawmill => tree
    // -----------------------------
    // 9 - small gold mine => gold
    // 10 - diamond mine => gold
    mapping(uint256 => IERC20) energyToken;
    // token type => energy cost 
    mapping(uint256 => uint256) energyCost;

    event MiningStarted(address user, uint256 toolId, uint256 toolType, uint256 timestamp);
    event MiningEnded(address user, uint256 toolId, uint256 toolType, uint256 timestamp);

    function initialize(address berryAddress, address treeAddress, address goldAddress, address blacklistAddress, address toolsAddress) initializer public {
        berry = IERC20(berryAddress);
        tree = IERC20(treeAddress);
        gold = IERC20(goldAddress);
        tools = ITools(toolsAddress);
        blacklist = IBlackList(blacklistAddress);

        _energyTokenAmount = 3;
        _toolTypeAmount = 10;
        
        energyToken[1] = berry;
        energyToken[2] = berry;
        energyToken[3] = berry;
        energyToken[4] = berry;
        energyToken[5] = tree;
        energyToken[6] = tree;
        energyToken[7] = tree;
        energyToken[8] = tree;
        energyToken[9] = gold;
        energyToken[10] = gold;

        energyCost[1] = 1;
        energyCost[2] = 3;
        energyCost[3] = 9;
        energyCost[4] = 30;
        energyCost[5] = 4;
        energyCost[6] = 7;
        energyCost[7] = 13;
        energyCost[8] = 25;
        energyCost[9] = 30;
        energyCost[10] = 60;

        __Pausable_init();
        __Ownable_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function startMining(uint256 toolType) external virtual whenNotPaused isInBlacklist(msg.sender) {
        require(!session[msg.sender].started, "This user already started mining process");
        tools.safeTransferFrom(msg.sender, address(this), toolType, 1, "");
        energyToken[toolType].transferFrom(msg.sender, address(this), energyCost[toolType]);
        session[msg.sender].endTime = uint32(block.timestamp + miningTime);
        session[msg.sender].toolType = uint32(toolType);
        session[msg.sender].started = true;
        // emit MiningStarted(msg.sender, toolType, block.timestamp);
    }

    function endMining() external virtual whenNotPaused isInBlacklist(msg.sender) {
        require(session[msg.sender].started == true, "User does not mine");
        require(block.timestamp >= session[msg.sender].endTime);
        tools.safeTransferFrom(address(this), msg.sender, session[msg.sender].toolType, 1, "");
        // emit MiningEnded(msg.sender, session[msg.sender].toolType, session[msg.sender].endTime);
        delete session[msg.sender];
    }



    modifier isInBlacklist(address user) {
        require(!blacklist.check(user), "User in blacklist");
        _;
    }
}