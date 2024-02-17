// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../errors/ErrorHandlers.sol";

contract StakeThisGuy is ERC20 {
    mapping(address => uint256) public staked;

    mapping(address => uint256) public stakedFromTimeStamp;

    constructor(uint256 _amountToMint) ERC20("StakeThisGuy", "STG") {
        _mint(msg.sender, _amountToMint);
    }

    function stake(uint256 _amount) external {
        if (_amount < 0) {
            revert ErrorHandlers.AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
        }

        if (balanceOf(msg.sender) < _amount) {
            revert ErrorHandlers.BALANCE_IS_LESS_THAN_AMOUNT();
        }

        _transfer(msg.sender, address(this), _amount);

        if (staked[msg.sender] > 0) {
            claim();
        }

        stakedFromTimeStamp[msg.sender] = block.timestamp;

        staked[msg.sender] += _amount;
    }

    function unstake(uint256 _amount) external {
        if (_amount < 0) {
            revert ErrorHandlers.AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
        }

        if (staked[msg.sender] < _amount) {
            revert ErrorHandlers.AMOUNT_IS_GRATER_THAN_STAKED();
        }

        claim();

        staked[msg.sender] -= _amount;

        _transfer(address(this), msg.sender, _amount);
    }

    function claim() public {
        if (staked[msg.sender] <= 0) {
            revert ErrorHandlers.STAKE_IS_LESS_THAN_ZERO();
        }

        // This represents the duration for which the tokens have been staked.
        uint256 duration = block.timestamp - stakedFromTimeStamp[msg.sender];
        // It is calculated by subtracting the timestamp when the tokens were staked (stakedFromTimeStamp[msg.sender]) from the current block timestamp.
        // The result is a duration measured in seconds.

        // So, when you multiply the amount staked (staked[msg.sender]) by the duration in seconds (duration), you get the total "staking time" in seconds for which the tokens have been staked.
        // Then, dividing this by 3.154e7 effectively converts the staking time from seconds to years.
        uint256 rewards = (staked[msg.sender] * duration) / 3.154e7;
        // 3.154e7: This is a scientific notation representing the number of seconds in a year.
        // Specifically, 3.154e7 equals 31,540,000 seconds, which is the approximate number of seconds in a standard Gregorian calendar year (365 days).

        _mint(msg.sender, rewards);

        stakedFromTimeStamp[msg.sender] = block.timestamp;
    }
}
