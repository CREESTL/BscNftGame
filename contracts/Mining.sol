// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import "./interfaces/ITools.sol";
import "./interfaces/IBlackList.sol";
import "./interfaces/IResources.sol";
import "./interfaces/IArtifacts.sol";

contract Mining is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    IERC1155Receiver
{
    ITools private _tools;
    IBlackList private _blacklist;

    address private _zeroAddress;
    // user address => (toolId => MinigSession)
    mapping(address => mapping(uint256 => MiningSession)) _session;
    // user address => (resource id => amount)
    mapping(address => mapping(uint256 => uint256)) availableResources;
    // user address => artifacts type => amount
    mapping(address => mapping(uint256 => uint256)) availableArtifacts;

    struct MiningSession {
        uint32 endTime;
        uint32 energyCost;
        uint16 toolType;
        uint16 strengthCost;
        bool started;
    }

    event MiningStarted(address user, MiningSession session);
    event MiningEnded(address user, MiningSession session);

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function initialize(
        address blacklistAddress,
        address toolsAddress
    ) public initializer {
        _zeroAddress = 0x000000000000000000000000000000000000dEaD;
        _tools = ITools(toolsAddress);
        _blacklist = IBlackList(blacklistAddress);

        __Pausable_init();
        __Ownable_init();
    }

    function pause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    function startMining(
        uint256 toolId,
        address user,
        uint256[] memory resourcesAmount,
        uint256[] memory artifactsAmount
    ) external virtual onlyOwner whenNotPaused isInBlacklist(user) {
        require(
            !_session[user][toolId].started,
            "Mining: this user already started mining process"
        );
        (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        ) = _tools.getToolProperties(user, toolId);

        require(strength - strengthCost > 0, "Mining: not enougth strength");

        IResources resource = IResources(_tools.getResourceAddress(0));

        _tools.safeTransferFrom(user, address(this), toolId, 1, "");
        resource.transferFrom(user, _zeroAddress, energyCost);

        _session[user][toolId] = MiningSession({
            endTime: uint32(block.timestamp + miningDuration),
            energyCost: uint32(energyCost),
            toolType: uint16(toolType),
            strengthCost: uint16(strengthCost),
            started: true
        });
        setRewards(user, resourcesAmount, artifactsAmount);
        emit MiningStarted(user, _session[user][toolId]);
    }

    function endMining(
        uint256 toolId
    ) external virtual whenNotPaused isInBlacklist(_msgSender()) {
        require(
            _session[_msgSender()][toolId].started,
            "Mining: user doesn't mine"
        );
        require(
            block.timestamp >= _session[_msgSender()][toolId].endTime,
            "Mining: too early"
        );

        _tools.corrupt(
            address(this),
            toolId,
            _session[_msgSender()][toolId].strengthCost
        );
        _tools.safeTransferFrom(address(this), _msgSender(), toolId, 1, "");
        MiningSession memory tmp = _session[_msgSender()][toolId];
        tmp.started = false;

        emit MiningEnded(_msgSender(), _session[_msgSender()][toolId]);
        delete _session[_msgSender()][toolId];
    }

    function setRewards(
        address user,
        uint256[] memory resourcesAmount,
        uint256[] memory artifactsAmount
    ) private {
        for (uint256 counter = 0; counter < resourcesAmount.length; counter++) {
            if (resourcesAmount[counter] != 0) {
                availableResources[user][counter] += resourcesAmount[counter];
            }
        }

        for (
            uint256 counter = 0;
            counter < _tools.getArtifactsTypesAmount();
            counter++
        ) {
            if (artifactsAmount[counter] != 0) {
                availableArtifacts[user][counter + 1] += artifactsAmount[
                    counter
                ];
            }
        }
    }

    function getRewards() external {
        IResources resource;
        IArtifacts artifacts;
        for (
            uint256 counter = 0;
            counter < _tools.getResourceAmount();
            counter++
        ) {
            if (availableResources[_msgSender()][counter] != 0) {
                resource = IResources(_tools.getResourceAddress(counter));
                resource.transfer(
                    _msgSender(),
                    availableResources[_msgSender()][counter]
                );
                delete availableResources[_msgSender()][counter];
            }
        }

        for (
            uint256 counter = 1;
            counter <= _tools.getArtifactsTypesAmount();
            counter++
        ) {
            if (availableArtifacts[_msgSender()][counter] != 0) {
                artifacts = IArtifacts(_tools.getArtifactsAddress());
                for (
                    uint256 i = 1;
                    i <= availableArtifacts[_msgSender()][counter];
                    i++
                ) {
                    artifacts.lootArtifact(_msgSender(), counter);
                }
                delete availableArtifacts[_msgSender()][counter];
            }
        }
    }

    modifier isInBlacklist(address user) {
        require(!_blacklist.check(user), "User in blacklist");
        _;
    }
}
