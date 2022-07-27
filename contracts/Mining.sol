// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./interfaces/ITools.sol";
import "./interfaces/IBlackList.sol";
import "./interfaces/IMining.sol";
import "./interfaces/IResources.sol";

contract Mining is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    IMining
{
    ITools private _tools;
    IBlackList private _blacklist;

    // user address => (toolId => MinigSession)
    mapping(address => mapping(uint256 => MiningSession)) _session;

    event MiningStarted(MiningSession);
    event MiningEnded(MiningSession);

    function initialize(address blacklistAddress, address toolsAddress)
        public
        initializer
    {
        _tools = ITools(toolsAddress);
        _blacklist = IBlackList(blacklistAddress);

        __Pausable_init();
        __Ownable_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function startMining(uint256 toolId)
        external
        virtual
        whenNotPaused
        isInBlacklist(_msgSender())
    {
        require(
            !_session[_msgSender()][toolId].started,
            "Mining: this user already started mining process"
        );
        (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningResource,
            uint256 miningDuration,
            uint256 energyCost,
            uint256 rewardRate
        ) = _tools.getToolProperties(toolId);

        require(strength - strengthCost > 0, "Mining: not enougth strength");

        IResources resource = IResources(
            _tools.getResourceAddress(miningResource)
        );

        _tools.safeTransferFrom(_msgSender(), address(this), toolId, 1, "");
        resource.transferFrom(_msgSender(), address(0), energyCost);

        _session[_msgSender()][toolId] = MiningSession({
            endTime: uint32(block.timestamp + miningDuration),
            rewardRate: uint32(rewardRate),
            energyCost: uint32(energyCost),
            toolType: uint16(toolType),
            strengthCost: uint16(strengthCost),
            started: true
        });

        emit MiningStarted(_session[_msgSender()][toolId]);
    }

    function endMining(uint256 toolId)
        external
        virtual
        whenNotPaused
        isInBlacklist(_msgSender())
    {
        require(
            _session[_msgSender()][toolId].started,
            "Mining: user doesn't mine"
        );
        require(
            block.timestamp >= _session[_msgSender()][toolId].endTime,
            "Mining: too early"
        );

        _tools.safeTransferFrom(address(this), _msgSender(), toolId, 1, "");
        emit MiningEnded(_session[_msgSender()][toolId]);
        delete _session[_msgSender()][toolId];
    }

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "User in blacklist");
        _;
    }
}
