## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

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
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
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

