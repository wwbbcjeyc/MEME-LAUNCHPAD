// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPancakePair
 * @notice PancakeSwap V2 交易对接口
 * @dev 定义了一个流动池的所有标准方法，用于两个代币之间的交易
 * 
 * 核心概念：
 * - 每个交易对包含两种代币（token0 和 token1）
 * - 通过恒定乘积公式维持流动性：reserve0 * reserve1 = 常数
 * - 用户可以添加/移除流动性，或者进行兑换
 */
interface IPancakePair {
    // ==================== ERC20 标准事件 ====================
    
    /**
     * @notice 授权事件
     * @param owner 代币持有者
     * @param spender 被授权者
     * @param value 授权数量
     */
    event Approval(address indexed owner, address indexed spender, uint value);
    
    /**
     * @notice 转账事件
     * @param from 转出地址
     * @param to 接收地址
     * @param value 转账数量
     */
    event Transfer(address indexed from, address indexed to, uint value);

    // ==================== ERC20 标准查询函数 ====================
    
    function name() external pure returns (string memory);      // 代币名称（如 "Pancake LPs"）
    function symbol() external pure returns (string memory);    // 代币符号（LP 代币）
    function decimals() external pure returns (uint8);          // 小数位数（通常为 18）
    function totalSupply() external view returns (uint);        // LP 代币总供应量
    function balanceOf(address owner) external view returns (uint);  // 查询某地址的 LP 代币余额
    function allowance(address owner, address spender) external view returns (uint);  // 查询授权额度

    // ==================== ERC20 标准操作函数 ====================
    
    function approve(address spender, uint value) external returns (bool);      // 授权
    function transfer(address to, uint value) external returns (bool);          // 转账
    function transferFrom(address from, address to, uint value) external returns (bool);  // 授权转账

    // ==================== EIP-2612 Permit 扩展 ====================
    // 允许使用签名进行授权，无需事先调用 approve（节省 gas）
    
    function DOMAIN_SEPARATOR() external view returns (bytes32);   // EIP-712 域分隔符
    function PERMIT_TYPEHASH() external pure returns (bytes32);    // permit 函数的类型哈希
    function nonces(address owner) external view returns (uint);   // 用户签名随机数，防止重放攻击

    /**
     * @notice 使用签名授权（EIP-2612）
     * @dev 用户签署一条消息，其他人可以提交来代为授权
     * @param owner 代币持有者
     * @param spender 被授权者
     * @param value 授权数量
     * @param deadline 过期时间
     * @param v ECDSA 签名恢复值
     * @param r ECDSA 签名 r 值
     * @param s ECDSA 签名 s 值
     */
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    // ==================== 交易对特有事件 ====================
    
    /**
     * @notice 铸造 LP 代币事件（添加流动性时触发）
     * @param sender 调用者
     * @param amount0 添加的 token0 数量
     * @param amount1 添加的 token1 数量
     */
    event Mint(address indexed sender, uint amount0, uint amount1);
    
    /**
     * @notice 销毁 LP 代币事件（移除流动性时触发）
     * @param sender 调用者
     * @param amount0 赎回的 token0 数量
     * @param amount1 赎回的 token1 数量
     * @param to 接收资产地址
     */
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    
    /**
     * @notice 兑换事件
     * @param sender 调用者
     * @param amount0In 输入的 token0 数量
     * @param amount1In 输入的 token1 数量
     * @param amount0Out 输出的 token0 数量
     * @param amount1Out 输出的 token1 数量
     * @param to 接收输出代币的地址
     */
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    
    /**
     * @notice 同步储备金事件（当储备金被手动更新时触发）
     * @param reserve0 更新后的 token0 储备量
     * @param reserve1 更新后的 token1 储备量
     */
    event Sync(uint112 reserve0, uint112 reserve1);

    // ==================== 交易对信息查询 ====================
    
    function MINIMUM_LIQUIDITY() external pure returns (uint);    // 最小流动性常数（1000）
    function factory() external view returns (address);           // 工厂合约地址
    function token0() external view returns (address);            // 交易对中的第一个代币地址
    function token1() external view returns (address);            // 交易对中的第二个代币地址
    
    /**
     * @notice 获取当前储备金和最后更新时间
     * @return reserve0 token0 的当前储备量
     * @return reserve1 token1 的当前储备量
     * @return blockTimestampLast 最后更新区块的时间戳
     */
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function price0CumulativeLast() external view returns (uint);  // token0 的累计价格（用于预言机）
    function price1CumulativeLast() external view returns (uint);  // token1 的累计价格（用于预言机）
    function kLast() external view returns (uint);                  // 上一次更新的乘积常数

    // ==================== 核心操作函数 ====================
    
    /**
     * @notice 添加流动性，铸造 LP 代币
     * @dev 用户需要先向合约转入两种代币，然后调用此函数
     * @param to 接收 LP 代币的地址
     * @return liquidity 铸造的 LP 代币数量
     */
    function mint(address to) external returns (uint liquidity);
    
    /**
     * @notice 移除流动性，销毁 LP 代币
     * @dev 用户需要先向合约转入 LP 代币，然后调用此函数
     * @param to 接收赎回资产的地址
     * @return amount0 赎回的 token0 数量
     * @return amount1 赎回的 token1 数量
     */
    function burn(address to) external returns (uint amount0, uint amount1);
    
    /**
     * @notice 兑换代币
     * @dev 恒定乘积公式：reserve0 * reserve1 >= (reserve0 - amount0Out) * (reserve1 - amount1Out)
     * @param amount0Out 想要输出的 token0 数量（0 表示不输出 token0）
     * @param amount1Out 想要输出的 token1 数量（0 表示不输出 token1）
     * @param to 接收输出代币的地址
     * @param data 回调数据（用于闪电贷）
     */
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    
    /**
     * @notice 提取多余余额
     * @dev 当合约余额大于储备金时，可将多余部分转到指定地址
     * @param to 接收多余资产的地址
     */
    function skim(address to) external;
    
    /**
     * @notice 同步储备金
     * @dev 根据当前合约余额更新储备金，防止价格操纵
     */
    function sync() external;

    /**
     * @notice 初始化交易对
     * @dev 只在首次创建时调用一次，设置两个代币地址
     * @param token0 第一个代币地址
     * @param token1 第二个代币地址
     */
    function initialize(address, address) external;
}