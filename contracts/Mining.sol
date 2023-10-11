// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

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
import "./interfaces/IMining.sol";

/// @title Contract for resources mining
contract Mining is
    Initializable,
    IMining,
    PausableUpgradeable,
    OwnableUpgradeable,
    IERC1155Receiver
{
    using ECDSA for bytes32;

    /// @dev The address of Tools contract
    ITools private _tools;
    /// @dev The address of Blacklist contract
    IBlackList private _blacklist;
    /// @dev Zero address to burn tokens
    address private constant _zeroAddress =
        0x000000000000000000000000000000000000dEaD;

    /// @dev Mapping (user address => (toolId => MiningSession))
    mapping(address => mapping(uint256 => MiningSession))
        private _usersToSessions;
    /// @dev Mapping showing the amount of resources a user would win in specific mining session
    // (user address => (toolId => (resource id => amount)))
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        private _usersToResources;
    /// @dev Mapping showing the amount of artifacts a user would win in specific mining session
    // (user address => (toolId => (artifact type => amount)))
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        private _usersToArtifacts;
    /// @notice Marks transaction hashes that have been executed already.
    ///         Prevents Replay Attacks
    mapping(bytes32 => bool) private _executed;

    /// @dev Checks that user is not blacklisted
    modifier ifNotBlacklisted(address user) {
        require(!_blacklist.check(user), "User in blacklist");
        _;
    }

    function initialize(
        address blacklistAddress,
        address toolsAddress
    ) external initializer {
        _tools = ITools(toolsAddress);
        _blacklist = IBlackList(blacklistAddress);

        __Pausable_init();
        __Ownable_init();
    }

    /// @dev The following 3 functions are required to ERC1155 standard
    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    /// @notice See {IMining-pause}
    function pause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @notice See {IMining-startMining}
    function startMining(
        uint256 toolId,
        address user,
        bytes calldata rewards,
        bytes calldata signature,
        uint256 nonce
    ) external whenNotPaused ifNotBlacklisted(user) {
        (
            uint256[] memory resourcesAmount,
            uint256[] memory artifactsAmounts
        ) = abi.decode(rewards, (uint256[], uint256[]));

        // Avoid "stack too deep"
        Args memory args = Args({
            toolId: toolId,
            user: user,
            nonce: nonce,
            signature: signature,
            resources: resourcesAmount,
            artifacts: artifactsAmounts
        });

        require(
            !_usersToSessions[args.user][args.toolId].started,
            "Mining: this user already started mining process"
        );

        bytes32 txHash = _getTxHashMining(
            args.toolId,
            args.user,
            args.resources,
            args.artifacts,
            args.nonce
        );

        // Prevent signature replay attacks
        require(!_executed[txHash], "Mining: already executed");
        
        // Make sure the backend has signed the tx
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

        require(strength - strengthCost > 0, "Mining: not enough strength");

        // Burn user's Berry tokens.
        IResources resource = IResources(_tools.getResourceAddress(0));
        resource.transferFrom(args.user, _zeroAddress, energyCost);

        // Transfer user's tool to this contract
        _tools.safeTransferFrom(args.user, address(this), args.toolId, 1, "");

        // Create a new session
        _usersToSessions[args.user][args.toolId] = MiningSession({
            toolId: uint32(args.toolId),
            started: true,
            ended: false,
            endTime: uint32(block.timestamp + miningDuration),
            energyCost: uint32(energyCost),
            strengthCost: uint16(strengthCost),
            nonce: uint32(args.nonce)
        });

        // After session has been started, the rewards are assigned to the user
        _setRewards(args.user, args.toolId, args.resources, args.artifacts);

        emit MiningStarted(args.user, _usersToSessions[args.user][args.toolId]);
    }

    /// @notice See {IMining-endMining}
    function endMining(
        uint256 toolId
    ) external whenNotPaused ifNotBlacklisted(_msgSender()) {
        require(
            _usersToSessions[_msgSender()][toolId].started,
            "Mining: user doesn't mine"
        );
        require(
            block.timestamp >= _usersToSessions[_msgSender()][toolId].endTime,
            "Mining: too early"
        );

        // Decrease tool's strength and give it back to the user
        _tools.corrupt(
            address(this),
            toolId,
            _usersToSessions[_msgSender()][toolId].strengthCost
        );
        _tools.safeTransferFrom(address(this), _msgSender(), toolId, 1, "");

        // Stop the session
        _usersToSessions[_msgSender()][toolId].ended = true;
        emit MiningEnded(_msgSender(), _usersToSessions[_msgSender()][toolId]);

        IResources resource;
        IArtifacts artifacts;

        uint256[] memory claimedResources = new uint256[](
            _tools.getResourcesTypesAmount()
        );
        uint256[] memory claimedArtifacts = new uint256[](
            _tools.getArtifactsTypesAmount()
        );

        // Claim all types of resources from this session
        for (
            uint256 toolType = 0;
            toolType < _tools.getResourcesTypesAmount();
            toolType++
        ) {
            if (_usersToResources[_msgSender()][toolId][toolType] != 0) {
                resource = IResources(_tools.getResourceAddress(toolType));
                resource.transfer(
                    _msgSender(),
                    _usersToResources[_msgSender()][toolId][toolType]
                );
                delete _usersToResources[_msgSender()][toolId][toolType];
            }
            // Mark that user has claimed some amount of resources. Even if it's zero.
            claimedResources[toolType] = _usersToResources[_msgSender()][
                toolId
            ][toolType];
        }

        // Claim all types of artifacts from this session
        for (
            uint256 artifactType = 0;
            artifactType < _tools.getArtifactsTypesAmount();
            artifactType++
        ) {
            if (_usersToArtifacts[_msgSender()][toolId][artifactType] != 0) {
                artifacts = IArtifacts(_tools.getArtifactsAddress());
                for (
                    uint256 i = 0;
                    i < _usersToArtifacts[_msgSender()][toolId][artifactType];
                    i++
                ) {
                    // Mint new artifact a required number of times
                    artifacts.lootArtifact(_msgSender(), artifactType);
                    // When looting, 1 artifact is minted
                    claimedArtifacts[artifactType] = 1;
                }
                delete _usersToArtifacts[_msgSender()][toolId][artifactType];
            } else {
                // No artifacts were looted
                claimedArtifacts[artifactType] = 0;
            }
        }

        emit RewardsClaimed(_msgSender(), claimedResources, claimedArtifacts);

        // Delete the session
        delete _usersToSessions[_msgSender()][toolId];
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
    /// @param artifactsAmounts The amount of artifacts to be mined
    /// @param nonce The unique integer
    function _getTxHashMining(
        uint256 toolId,
        address user,
        uint256[] memory resourcesAmount,
        uint256[] memory artifactsAmounts,
        uint256 nonce
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    toolId,
                    user,
                    resourcesAmount,
                    artifactsAmounts,
                    nonce
                )
            );
    }

    /// @dev Sets rewards for a user in a specific mining session
    /// @param user The user to assign rewards to
    /// @param toolId The ID of the tool used in the session
    ///        a unique tool is used in each session
    /// @param resourcesAmount Array of amounts of each type of resource that
    ///        can be claimed after mining
    /// @param artifactsAmounts Array of amounts of each type of artifact that
    ///        can be claimed after mining
    function _setRewards(
        address user,
        uint256 toolId,
        uint256[] memory resourcesAmount,
        uint256[] memory artifactsAmounts
    ) private {
        for (
            uint256 counter = 0; 
            counter < resourcesAmount.length; 
            counter++
        ) {
            if (resourcesAmount[counter] != 0) {
                _usersToResources[user][toolId][counter] += resourcesAmount[
                    counter
                ];
            }
        }
        for (
            uint256 counter = 0;
            counter < artifactsAmounts.length;
            counter++
        ) {
            if (artifactsAmounts[counter] != 0) {
                _usersToArtifacts[user][toolId][
                    counter + 1
                ] += artifactsAmounts[counter];
            }
        }
    }
}
