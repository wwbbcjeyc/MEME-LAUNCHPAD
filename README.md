## Foundry
- **Forge**: 以太坊测试框架（类似于 Truffle、Hardhat 和 DappTools）
- **Cast**: 用于与以太坊虚拟机智能合约进行交互、发送交易以及获取链上数据的多功能工具.
- **Anvil**: 本地以太坊节点，类似于 Ganache、Hardhat 网络.
- **Chisel**: 快速、实用且冗长的 Solidity 连续式命令行解释器.

## Documentation

https://book.getfoundry.sh/

## Usage

### 编译合约

```shell
forge build
forge build --sizes

```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Anvil

```shell
anvil
```

### Deploy

```shell
forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
cast <subcommand>
```

### Help

```shell
forge --help
anvil --help
cast --help
```


### 架构

```shell
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  MetaNodeCore    │─────▶│ MetaNodeVesting  │◀─────│     User         │
│  (代币创建)       │      │ (线性释放)       │      │    (领取)        │
└──────────────────┘      └──────────────────┘      └──────────────────┘
         │                         │
         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│  MetaNodeToken   │      │ 归属时间表        │
│   (ERC20)        │      │   管理           │
└──────────────────┘      └──────────────────┘
```


### 本地测试 
```shell
# 快速测试
make test
# 分模块测试
forge test --match-path test/MetaNodeCoreTest.t.sol # 核心合约测试（权限、保证金、交易限制）
forge test --match-path test/InitialBuyTest.t.sol # 初始买入测试
forge test --match-path test/VestingTest.t.sol # 归属功能测试（锁仓释放）
forge test --match-path test/ComprehensiveFeeTest.t.sol # 费用机制测试
forge test --match-path test/MarginDepositTest.t.sol # 保证金测试
forge test --match-path test/FutureLaunchTest.t.sol # 延迟启动测试
forge test --match-path test/CalculateInitialBuyTest.t.sol # 联合曲线计算测试
forge test --match-path test/VestingPreBuyTest.t.sol # 预购+归属组合测试
forge test --match-path test/VanityAddressTest.t.sol # 靓号地址测试
```

