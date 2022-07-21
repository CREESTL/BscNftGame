// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


contract MyContract is Initializable, PausableUpgradeable, OwnableUpgradeable {
    IERC20 public resources;    
    IERC1155 public tools;

    uint256 public reawardRate;
    uint256 public miningTime;

    struct MiningSession {
        uint256 endTime;
        uint256 toolId;
        uint256 resourceAmount;
        bool started;
    }

    mapping (address => MiningSession) session;

    event MiningStarted(address user, uint256 toolId, uint256 resourceAmount, uint256 timestamp);
    event MiningEnded(address user, uint256 toolId, uint256 resourceAmount, uint256 timestamp);

    function initialize(uint256 _rewardRate, address resourcesAddress) initializer public {
        reawardRate = _rewardRate;
        resources = IERC20(resourcesAddress);

        __Pausable_init();
        __Ownable_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function startMining(uint256 resourceAmount, uint256 toolId) external {
        require(!session[msg.sender].started, "This user already started mining process");
        tools.safeTransferFrom(msg.sender, address(this), toolId, 1, "");
        resources.transferFrom(msg.sender, address(this), resourceAmount);
        session[msg.sender].resourceAmount = resourceAmount;
        session[msg.sender].endTime = block.timestamp + miningTime;
        session[msg.sender].toolId = toolId;
        session[msg.sender].started = true;
        emit MiningStarted(msg.sender, toolId, resourceAmount, block.timestamp);
    }

    function returnTool() external {
        require(session[msg.sender].started == true, "User does not mine");
        require(block.timestamp >= session[msg.sender].endTime);
        tools.safeTransferFrom(address(this), msg.sender, session[msg.sender].toolId, 1, "");
        emit MiningEnded(msg.sender, session[msg.sender].toolId, session[msg.sender].resourceAmount, session[msg.sender].endTime);
        delete session[msg.sender];
    }
}