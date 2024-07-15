### Blink - hyper-functional DEX powered on Blast L2
| Blast Mainnet | Address            |
| ------------- |:------------------:|
| BlinkFactory       | [0xFfbDb302f29B29ee45D650DF44889450d252d868](https://blastscan.io/address/0xFfbDb302f29B29ee45D650DF44889450d252d868)|
| BlinkRouter        | [0xe38BdAa37742096DdE50F121863A63685C2Fc9C1](https://blastscan.io/address/0xe38BdAa37742096DdE50F121863A63685C2Fc9C1) |
| BlinkFeeReceiver   | [0x8BD4c4B20C5d22b8de701cba2Cf15ACeC93b2Df8](https://blastscan.io/address/0x8BD4c4B20C5d22b8de701cba2Cf15ACeC93b2Df8) |

### Official links:
[1. Blinkswap](https://blinkswap.xyz/)
[2. Blinkswap App](https://app.blinkswap.xyz/)
[3. Blinkswap Docs](https://docs.blinkswap.xyz/)
[4. Blinkswap Twitter](https://x.com/blinkswap)

#### Blink uses the revolutionary idea of ​​points calculating
Аll data is stored on-chain and can be viewed directly on the blockchain. All information about points is open-source. 

Each interaction with an ERC20 token BlinkPair calls the function blinkUpdateLiquidityTime(). This helps to calculate points according to time*user liquidity
```
src/BlinkPair.sol
```
```solidity
    function blinkUpdateLiquidityTime(address user) external {
        if (IUniswapV2Factory(factory).blinkPush(token0, token1, 0, 0) == false) {
            uint lastTimestamp = blinkLastTimestamp[user];
            uint lastRemainder = blinkLastRemainder[user];
            if (lastTimestamp == 0) blinkPairUsers.push(user);
            if (lastRemainder > 0) {
                if (block.timestamp.sub(lastTimestamp) > 0) {
                blinkLiquidityTime[user] += (block.timestamp.sub(lastTimestamp)).mul(lastRemainder);
                }
            }
            blinkLastRemainder[user] = balanceOf[user];
            blinkLastTimestamp[user] = block.timestamp;
        }
    }
```
Also, when making a swap, Blink records the volume of each swap that the user made
```
src/BlinkFactory.sol
```
```solidity
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
```

### Local deployment and Usage
Install Foundry
```
https://book.getfoundry.sh/
```
To utilize the contracts and deploy to a local testnet, you can install the code in your repo with forge:
```
forge build
```