// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;

import './BlinkPair.sol';

contract BlinkFactory {
    address public feeTo;
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(BlinkPair).creationCode));
    uint public blinkFeeMul;
    uint public blinkFee;
    address[] public blinkUsers;
    mapping(address => uint) public blinkVolume;
    mapping(address => bool) private blinkInit;
    bool private blinkStop;

    constructor() public {
        feeTo = 0x8BD4c4B20C5d22b8de701cba2Cf15ACeC93b2Df8;
        IBlastPoints(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800).configurePointsOperator(0x08E413dc2EB2F7FF3E6d972FF78270EBfAF4f013);
        blinkFeeMul = 5;
        blinkFee = 30;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(BlinkPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function blinkClaim() external {
        (,uint amountETH,,) = IBlast(0x4300000000000000000000000000000000000002).readGasParams(address(this));
        if (amountETH > 0) IBlast(0x4300000000000000000000000000000000000002).claimMaxGas(address(this), feeTo);
    }

    function blinkUsersLength() external view returns (uint) {
        return blinkUsers.length;
    }

    function blinkSettings(address _feeTo, uint _feeMul, uint _fee, bool _stop) external {
        require(msg.sender == feeTo);
        feeTo = _feeTo;
        blinkFeeMul = _feeMul;
        blinkFee = _fee;
        blinkStop = _stop;
    }

    function blinkPush(address token0, address token1, uint256 amount0, uint256 amount1) external returns (bool) {
        if (blinkStop) return true;
        require(getPair[token0][token1] == msg.sender);
        if (!blinkInit[tx.origin]) {
            blinkUsers.push(tx.origin);
            blinkInit[tx.origin] = true;
        }
        if (token0 == 0x4300000000000000000000000000000000000004) blinkVolume[tx.origin] += amount0;
        if (token1 == 0x4300000000000000000000000000000000000004) blinkVolume[tx.origin] += amount1;
    }

}