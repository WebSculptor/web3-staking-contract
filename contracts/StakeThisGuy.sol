// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
error BALANCE_IS_LESS_THAN_AMOUNT();
error STAKE_IS_LESS_THAN_ZERO();
error AMOUNT_IS_GRATER_THAN_STAKED();

contract StakeThisGuy is ERC20 {
    mapping(address => uint256) public staked;

    mapping(address => uint256) public stakedFromTimeStamp;

    constructor(uint256 _amountToMint) ERC20("StakeThisGuy", "STG") {
        _mint(msg.sender, _amountToMint);
    }

    function stake(uint256 _amount) external {
        if (_amount < 0) {
            revert AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
        }

        if (balanceOf(msg.sender) < _amount) {
            revert BALANCE_IS_LESS_THAN_AMOUNT();
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
            revert AMOUNT_IS_LESS_THAN_OR_EQUAL_TO_ZERO();
        }

        if (staked[msg.sender] < _amount) {
            revert AMOUNT_IS_GRATER_THAN_STAKED();
        }

        claim();

        staked[msg.sender] -= _amount;

        _transfer(address(this), msg.sender, _amount);
    }

    function claim() public {
        if (staked[msg.sender] <= 0) {
            revert STAKE_IS_LESS_THAN_ZERO();
        }

        uint256 duration = block.timestamp - stakedFromTimeStamp[msg.sender];

        uint256 rewards = (staked[msg.sender] * duration) / 3.154e7;

        _mint(msg.sender, rewards);

        stakedFromTimeStamp[msg.sender] = block.timestamp;
    }
}
