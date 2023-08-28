// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

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

    using ECDSA for bytes32;

    address private _zeroAddress;
    // user address => (toolId => MinigSession)
    mapping(address => mapping(uint256 => MiningSession)) _session;
    // user address => (resource id => amount)
    mapping(address => mapping(uint256 => uint256)) availableResources;
    // user address => artifacts type => amount
    mapping(address => mapping(uint256 => uint256)) availableArtifacts;
    /// @notice Marks transaction hashes that have been executed already.
    ///         Prevents Replay Attacks
    mapping(bytes32 => bool) private _executed;

    struct MiningSession {
        uint32 endTime;
        uint32 energyCost;
        uint32 toolId;
        uint16 strengthCost;
        bool started;
        uint32 nonce;
    }

    struct Args {
        uint256 toolId;
        address user;
        uint256 nonce;
        bytes signature;
        uint256[] resources;
        uint256[] artifacts;
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
        bytes calldata rewards,
        bytes calldata signature,
        uint256 nonce
    ) external virtual whenNotPaused isInBlacklist(user) {
        (
            uint256[] memory resourcesAmount,
            uint256[] memory artifactsAmount
        ) = abi.decode(rewards, (uint256[], uint256[]));

        // Avoid "stack too deep"
        Args memory args = Args({
            toolId: toolId,
            user: user,
            nonce: nonce,
            signature: signature,
            resources: resourcesAmount,
            artifacts: artifactsAmount
        });

        require(
            !_session[args.user][args.toolId].started,
            "Mining: this user already started mining process"
        );

        bytes32 txHash = _getTxHashMining(
            args.toolId,
            args.user,
            args.resources,
            args.artifacts,
            args.nonce
        );

        require(!_executed[txHash], "Mining: already executed");

        require(
            _verifyBackendSignature(args.signature, txHash),
            "Mining: invalid backend signature"
        );

        _executed[txHash] = true;

        (
            uint256 toolType,
            uint256 strength,
            uint256 strengthCost,
            uint256 miningDuration,
            uint256 energyCost
        ) = _tools.getToolProperties(args.user, args.toolId);

        require(strength - strengthCost > 0, "Mining: not enougth strength");

        IResources resource = IResources(_tools.getResourceAddress(0));

        _tools.safeTransferFrom(args.user, address(this), args.toolId, 1, "");
        resource.transferFrom(args.user, _zeroAddress, energyCost);

        _session[args.user][args.toolId] = MiningSession({
            endTime: uint32(block.timestamp + miningDuration),
            energyCost: uint32(energyCost),
            toolId: uint32(args.toolId),
            strengthCost: uint16(strengthCost),
            started: true,
            nonce: uint32(args.nonce)
        });
        setRewards(args.user, args.resources, args.artifacts);
        emit MiningStarted(args.user, _session[args.user][args.toolId]);
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

    /// @dev Verifies that message was signed by the backend
    /// @param signature A signature used to sign the tx
    /// @param txHash An unsigned hashed data
    /// @return True if tx was signed by the backend (owner). Otherwise false.
    function _verifyBackendSignature(
        bytes memory signature,
        bytes32 txHash
    ) private view returns (bool) {
        // Remove the "\x19Ethereum Signed Message:\n" prefix from the signature
        bytes32 clearHash = txHash.toEthSignedMessageHash();
        // Recover the address of the user who signed the tx
        address recoveredUser = clearHash.recover(signature);
        return recoveredUser == owner();
    }

    /// @dev Calculates the hash of parameters of mining function and a nonce
    /// @param toolId The ID of the tool used for mining
    /// @param user The user who started mining
    /// @param resourcesAmount The amount of resources to be mined
    /// @param artifactsAmount The amount of artifacts to be mined
    /// @param nonce The unique integer
    function _getTxHashMining(
        uint256 toolId,
        address user,
        uint256[] memory resourcesAmount,
        uint256[] memory artifactsAmount,
        uint256 nonce
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    toolId,
                    user,
                    resourcesAmount,
                    artifactsAmount,
                    nonce
                )
            );
    }
}
