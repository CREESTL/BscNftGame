// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IBlackList.sol";

contract BlackList is IBlackList, Ownable {
    mapping(address => bool) private list;

    function check(address user) external view returns(bool) {
        return list[user];
    }

    function addToBlacklist(address user) onlyOwner external {
        require(list[user] == false, "User already in blacklist");
        list[user] = true;
    }

    function removeFromBlacklist(address user) onlyOwner external {
        require(list[user] == true, "User is not in blacklist");
        list[user] = false;
    }
}