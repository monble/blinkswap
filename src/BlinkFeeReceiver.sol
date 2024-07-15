// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlinkFeeReceiver {
    receive() external payable {}

    modifier onlyOwner {
        require(msg.sender == 0xEED041363412E0dd41AFF5Ad40E46aB9f68DED02);
        _;
    }

    function transfer(address ERC20, address recipient, uint256 amount) public onlyOwner {
        (bool success,) = ERC20.call(abi.encodeWithSelector(0xa9059cbb, recipient, amount));
        require(success);
    }

    function transferLoop(address recipient, address[] calldata ERC20, uint256[] calldata amounts) public onlyOwner {
        for (uint256 i; i < ERC20.length;) {
            (bool success,) = ERC20[i].call(abi.encodeWithSelector(0xa9059cbb, recipient, amounts[i]));
            require(success);
            unchecked {++i;}
        }
    }

    function transferETH(address payable recipient, uint256 amount) public onlyOwner {
        (bool success,) = recipient.call{value: amount}("");
        require(success);
    }

    function settings(address factory, address _feeTo, uint256 _feeMul, uint256 _fee, bool _stop) public onlyOwner {
        (bool success,) = factory.call(abi.encodeWithSelector(0xdc243242, _feeTo, _feeMul, _fee, _stop));
        require(success);
    }
}