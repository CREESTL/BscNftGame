//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Gem is Ownable, ERC20 {
    address public compensator;
    uint256 public compensationRate;

    mapping(address => bool) public blocked;

    constructor(uint256 compensationRate_) ERC20("GEM", "GEM") Ownable() {
        compensationRate = compensationRate_;
    }

    function setCompensator(address compensator_) external onlyOwner {
        compensator = compensator_;
    }

    function setCompensationRate(uint256 compensationRate_) external onlyOwner {
        compensationRate = compensationRate_;
    }

    function blockAddress(address addr, bool isBlocked) external onlyOwner {
        blocked[addr] = isBlocked;
    }

    function compensateBnb(address to, uint256 bnbAmount) external {
        if (msg.sender == compensator) {
            _mint(to, (bnbAmount * compensationRate) / 10 ** 9);
        }
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function _beforeTokenTransfer(
        address,
        address to,
        uint256
    ) internal view override {
        require(!blocked[to], "Can not transfer to blocked addresses");
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        require(!blocked[spender], "Can not approve blocked addresses");
        super._approve(owner, spender, amount);
    }
}
