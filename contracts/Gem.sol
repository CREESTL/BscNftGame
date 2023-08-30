//SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IGem.sol";

/// @title Gem token contract
contract Gem is IGem, Ownable, ERC20 {
    /// @notice The address of the contract that can compensate fees with Gems
    address public compensator;
    /// @notice The BNB/GEM rate of compensation
    uint256 public compensationRate;

    /// @notice Addresses from this list cannot transfer of receive tokens
    mapping(address => bool) public blocked;

    constructor(uint256 compensationRate_) ERC20("GEM", "GEM") Ownable() {
        compensationRate = compensationRate_;
    }

    /// @notice See {IGem-setCompensator}
    function setCompensator(address compensator_) external onlyOwner {
        compensator = compensator_;
    }

    /// @notice See {IGem-setCompensationRate}
    function setCompensationRate(uint256 compensationRate_) external onlyOwner {
        compensationRate = compensationRate_;
    }

    /// @notice See {IGem-blockAddress}
    function blockAddress(address addr, bool isBlocked) external onlyOwner {
        blocked[addr] = isBlocked;

        if (isBlocked) {
            emit Blocked(addr);
        } else {
            emit Unblocked(addr);
        }
    }

    /// @notice See {IGem-compensateBnb}
    function compensateBnb(address to, uint256 bnbAmount) external {
        if (msg.sender == compensator) {
            _mint(to, (bnbAmount * compensationRate) / 10 ** 9);
        }
    }

    /// @notice See {IGem-decimals}
    function decimals() public pure override(ERC20, IGem) returns (uint8) {
        return 9;
    }

    /// @dev Checks that `to` is not blocked before transferring tokens
    /// @param from Sender of tokens
    /// @param to Receiver of tokens
    /// @param amount The amount of tokens sent
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        require(!blocked[to], "Can not transfer to blocked addresses");
    }

    /// @dev Checks that `spender` is not blocked and approves
    ///      transfer of tokens
    /// @param owner The owner of tokens
    /// @param spender The spender of tokens
    /// @param amount The amount of tokens to spend
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        require(!blocked[spender], "Can not approve blocked addresses");
        super._approve(owner, spender, amount);
    }
}
