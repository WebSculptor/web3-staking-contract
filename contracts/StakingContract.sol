// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();

contract FixedStaking is ERC20 {
    mapping(address => uint256) public staked;
    mapping(address => uint256) public stakedFromTimeStamp;

    constructor(uint256 _amountToMint) ERC20("FixedStaking", "FXT") {
        _mint(msg.sender, _amountToMint);
    }

    function stake(uint256 _amount) external {
        if (_amount < 0) {
            revert AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
        }
        require(balanceOf(msg.sender) >= _amount, "balance is <= amount");
        _transfer(msg.sender, address(this), _amount);

        if (staked[msg.sender] > 0) {
            claim();
        }

        stakedFromTimeStamp[msg.sender] = block.timestamp;
        staked[msg.sender] += _amount;
    }

    function unstake(uint256 _amount) external {
        if (_amount < 0) {
            revert AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
        }
        require(staked[msg.sender] >= _amount, "amount is > staked");
        claim();
        staked[msg.sender] -= _amount;
        _transfer(address(this), msg.sender, _amount);
    }

    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 secondsStaked = block.timestamp -
            stakedFromTimeStamp[msg.sender];
        uint256 rewards = (staked[msg.sender] * secondsStaked) / 3.154e7;
        _mint(msg.sender, rewards);
        stakedFromTimeStamp[msg.sender] = block.timestamp;
    }
}
