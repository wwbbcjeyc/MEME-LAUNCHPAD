// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPancakeFactory
 * @notice PancakeSwap V2 工厂接口
 * @dev 工厂合约负责创建和管理所有交易对（Pair）
 *
 * 核心功能：
 * - 创建新的交易对
 * - 查询已存在的交易对
 * - 提供交易对地址计算所需的常量
 *
 * 工作原理：
 * - 每个交易对由两个代币地址唯一确定
 * - 使用 CREATE2 操作码，可以提前计算交易对地址
 * - 交易对地址 = hash(0xff + 工厂地址 + salt + INIT_CODE_HASH)
 */
interface IPancakeFactory {
    /**
     * @notice 交易对创建代码的哈希值
     * @dev 这是 CREATE2 地址计算的关键常量
     *
     * 作用：
     * - 确保交易对地址计算的确定性
     * - 防止地址碰撞攻击
     * - 允许提前计算交易对地址
     *
     * 计算方式：
     * INIT_CODE_HASH = keccak256(abi.encodePacked(type(PancakePair).creationCode))
     *
     * @return bytes32 交易对合约创建代码的哈希值
     */
    function INIT_CODE_HASH() external view returns (bytes32);

    /**
     * @notice 查询两个代币对应的交易对地址
     * @dev 如果交易对不存在，返回 address(0)
     *
     * 地址计算（用于前端预测）：
     * address(
     *     keccak256(
     *         abi.encodePacked(
     *             hex'ff',           // CREATE2 前缀
     *             factoryAddress,    // 工厂合约地址
     *             salt,              // keccak256(abi.encodePacked(token0, token1))
     *             INIT_CODE_HASH     // 交易对创建代码哈希
     *         )
     *     )
     * )
     *
     * @param tokenA 第一个代币地址（顺序无关，会自动排序）
     * @param tokenB 第二个代币地址（顺序无关，会自动排序）
     * @return pair 交易对合约地址，不存在时返回 address(0)
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    /**
     * @notice 创建新的交易对
     * @dev 如果交易对已存在，直接返回已存在的地址
     *
     * 创建流程：
     * 1. 对代币地址进行排序（tokenA < tokenB）
     * 2. 检查交易对是否已存在
     * 3. 使用 CREATE2 部署新的 Pair 合约
     * 4. 初始化 Pair 合约（设置 token0 和 token1）
     * 5. 触发 PairCreated 事件
     * 6. 返回新创建的交易对地址
     *
     * 前置条件：
     * - tokenA != tokenB（不能是同一个代币）
     * - tokenA != address(0) 且 tokenB != address(0)（地址不能为0）
     * - 交易对尚未创建
     *
     * @param tokenA 第一个代币地址
     * @param tokenB 第二个代币地址
     * @return pair 新创建或已存在的交易对地址
     */
    function createPair(address tokenA, address tokenB) external returns (address pair);

    /**
     * @dev 标准 PancakeSwap 工厂还包含以下常用功能（可选）：
     *
     * // 获取所有交易对列表
     * function allPairs(uint256 index) external view returns (address pair);
     *
     * // 获取交易对总数
     * function allPairsLength() external view returns (uint256);
     *
     * // 设置手续费接收地址
     * function setFeeTo(address _feeTo) external;
     *
     * // 获取手续费接收地址
     * function feeTo() external view returns (address);
     *
     * // 设置协议手续费比例
     * function setFeeToSetter(address _feeToSetter) external;
     *
     * // 获取协议手续费比例设置者
     * function feeToSetter() external view returns (address);
     */
}
