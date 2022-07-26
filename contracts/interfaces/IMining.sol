// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.12;

interface IMining {
    struct MiningSession {
        uint32 endTime;
        uint32 toolType;
        uint32 rewardRate;
        uint32 resourceAmount;
        bool started;
    }
}