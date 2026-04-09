// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPancakeRouter02
 * @notice PancakeSwap V2 路由接口
 * @dev 路由合约是用户与 PancakeSwap 交互的主要入口，封装了添加/移除流动性、兑换等复杂操作
 *
 * 核心功能：
 * 1. 添加/移除流动性（ETH 配对版本）
 * 2. 代币兑换（支持 ETH 和代币之间的互换）
 * 3. 手续费代币支持（SupportingFeeOnTransferTokens 版本）
 *
 * 名词解释：
 * - ETH：泛指原生币（BNB Chain 上是 BNB）
 * - WETH：包装后的原生币（符合 ERC20 标准）
 * - path：兑换路径，如 [tokenA, tokenB, tokenC]
 * - slippage：滑点，实际成交价与预期价的差异
 */
interface IPancakeRouter02 {
    // ==================== 添加/移除流动性 ====================

    /**
     * @notice 添加流动性（ETH + 代币）
     * @dev 用户同时提供 ETH 和代币，获得 LP 代币
     *
     * 使用流程：
     * 1. 用户先 approve 代币给 Router
     * 2. 调用此函数并附带 ETH（msg.value）
     * 3. Router 将 ETH 转为 WETH
     * 4. 调用 Factory 获取/创建交易对
     * 5. 调用 Pair 的 mint 方法铸造 LP 代币
     *
     * @param token 代币地址（与 ETH 配对）
     * @param amountTokenDesired 希望添加的代币数量
     * @param amountTokenMin 最少接受的代币数量（防止滑点）
     * @param amountETHMin 最少接受的 ETH 数量（防止滑点）
     * @param deadline 交易截止时间（防止延迟执行）
     * @param optOutUserShare 是否选择退出用户份额（通常填 false）
     * @return amountToken 实际使用的代币数量
     * @return amountETH 实际使用的 ETH 数量
     * @return liquidity 获得的 LP 代币数量
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline,
        bool optOutUserShare
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    /**
     * @notice 移除流动性（ETH + 代币）
     * @dev 用户提供 LP 代币，赎回 ETH 和代币
     *
     * 使用流程：
     * 1. 用户先 approve LP 代币给 Router
     * 2. 调用此函数
     * 3. Router 调用 Pair 的 burn 方法销毁 LP 代币
     * 4. 将 WETH 转回 ETH 返回给用户
     *
     * @param token 代币地址（与 ETH 配对）
     * @param liquidity 要销毁的 LP 代币数量
     * @param amountTokenMin 最少赎回的代币数量（防止滑点）
     * @param amountETHMin 最少赎回的 ETH 数量（防止滑点）
     * @param to 接收赎回资产的地址
     * @param deadline 交易截止时间
     * @return amountToken 实际赎回的代币数量
     * @return amountETH 实际赎回的 ETH 数量
     */
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    // ==================== 查询函数 ====================

    /**
     * @notice 获取工厂合约地址
     * @return address 工厂合约地址
     */
    function factory() external pure returns (address);

    /**
     * @notice 获取 WETH 合约地址
     * @return address WETH/WBNB 合约地址
     */
    function WETH() external pure returns (address);

    /**
     * @notice 给定输入数量，计算输出数量（正向计算）
     * @dev 用于估算能换到多少代币
     *
     * 示例：输入 1 BNB，通过路径 [WBNB, USDT, CAKE] 能换到多少 CAKE
     *
     * @param amountIn 输入数量
     * @param path 兑换路径（代币地址数组）
     * @return amounts 每一步的输出数量（长度 = path.length）
     */
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    /**
     * @notice 给定输出数量，计算需要输入多少（反向计算）
     * @dev 用于估算需要花费多少代币才能得到想要的输出
     *
     * @param amountOut 期望的输出数量
     * @param path 兑换路径
     * @return amounts 每一步的输入数量（长度 = path.length）
     */
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    // ==================== 普通代币兑换（标准版）====================

    /**
     * @notice 代币兑换代币（支持转账时收费的代币）
     * @dev 专为有转账手续费机制的代币设计，会正确处理实际到账数量
     *
     * 使用场景：代币合约在转账时会扣税（如 5% 手续费）
     * 使用此函数可以保证兑换金额正确
     *
     * @param amountIn 输入代币数量
     * @param amountOutMin 最少接受的输出数量（滑点保护）
     * @param path 兑换路径
     * @param to 接收输出代币的地址
     * @param deadline 交易截止时间
     */
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    /**
     * @notice ETH 兑换代币（支持转账时收费的代币）
     * @dev 用户发送 ETH，兑换成目标代币
     *
     * 使用方式：调用时附带 ETH（msg.value）
     *
     * @param amountOutMin 最少接受的输出数量
     * @param path 兑换路径（第一个地址必须是 WETH）
     * @param to 接收代币的地址
     * @param deadline 交易截止时间
     */
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    /**
     * @notice 代币兑换 ETH（支持转账时收费的代币）
     * @dev 用户提供代币，兑换成 ETH
     *
     * 使用前需要先 approve 代币给 Router
     *
     * @param amountIn 输入代币数量
     * @param amountOutMin 最少接受的 ETH 数量
     * @param path 兑换路径（最后一个地址必须是 WETH）
     * @param to 接收 ETH 的地址
     * @param deadline 交易截止时间
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    // ==================== 标准兑换函数（返回精确数量）====================

    /**
     * @notice 精确输入，代币换代币
     * @dev 适用于普通 ERC20 代币（无转账手续费）
     * @param amountIn 输入数量
     * @param amountOutMin 最小输出数量
     * @param path 兑换路径
     * @param to 接收地址
     * @param deadline 截止时间
     * @return amounts 每步兑换的数量
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @notice 精确输出，代币换代币
     * @dev 想要固定数量的输出，计算需要多少输入
     * @param amountOut 期望的输出数量
     * @param amountInMax 最多愿意支付的输入数量
     * @param path 兑换路径
     * @param to 接收地址
     * @param deadline 截止时间
     * @return amounts 每步兑换的数量
     */
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @notice 精确输入，ETH 换代币
     * @dev 发送固定数量的 ETH，获得代币
     * @param amountOutMin 最小输出数量
     * @param path 兑换路径（第一个必须是 WETH）
     * @param to 接收地址
     * @param deadline 截止时间
     * @return amounts 每步兑换的数量
     */
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    /**
     * @notice 精确输出，代币换 ETH
     * @dev 想要固定数量的 ETH，计算需要多少代币
     * @param amountOut 期望的 ETH 数量
     * @param amountInMax 最多愿意支付的代币数量
     * @param path 兑换路径（最后一个是 WETH）
     * @param to 接收地址
     * @param deadline 截止时间
     * @return amounts 每步兑换的数量
     */
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @notice 精确输入，代币换 ETH
     * @dev 发送固定数量的代币，获得 ETH
     * @param amountIn 输入代币数量
     * @param amountOutMin 最小 ETH 输出
     * @param path 兑换路径（最后一个是 WETH）
     * @param to 接收地址
     * @param deadline 截止时间
     * @return amounts 每步兑换的数量
     */
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @notice 精确输出，ETH 换代币
     * @dev 想要固定数量的代币，计算需要多少 ETH
     * @param amountOut 期望的代币数量
     * @param path 兑换路径（第一个必须是 WETH）
     * @param to 接收地址
     * @param deadline 截止时间
     * @return amounts 每步兑换的数量
     */
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
}
