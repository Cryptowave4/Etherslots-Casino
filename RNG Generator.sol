// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomNumberGenerator {
    uint256 public seed;

    constructor(uint256 initialSeed) {
        seed = initialSeed;
    }

    function setSeed(uint256 newSeed) public {
        seed = newSeed;
    }

    function getRandomNumber() public view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed)));
        return randomNumber;
    }

    function getCombinedRandomNumber() public view returns (uint256) {
        uint256 bbsRandomNumber = getRandomNumber();
        uint256 timestamp = block.timestamp;
        uint256 combinedNumber = bbsRandomNumber ^ timestamp;
        return combinedNumber;
    }
}



