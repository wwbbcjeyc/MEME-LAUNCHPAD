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

# 详细输出
make test-v

# 显示测试摘要
make test-summary

# 显示 Gas 消耗报告
make test-gas
```

### 分模块测试 
```shell
make test-core           # 核心合约测试（权限、保证金、交易限制）
make test-initial-buy    # 初始买入测试
make test-vesting        # 归属功能测试（锁仓释放）
make test-fee            # 费用机制测试
make test-margin         # 保证金测试
make test-future-launch  # 延迟启动测试
make test-calculate      # 联合曲线计算测试
make test-vesting-prebuy # 预购+归属组合测试
make test-vanity         # 靓号地址测试
```