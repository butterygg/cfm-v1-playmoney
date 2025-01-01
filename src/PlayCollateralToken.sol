// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";

/// @title PlayCollateralToken
/// @notice Restrictive ERC20 for "play money": only the owner or ConditionalTokens can send or receive tokens.
contract PlayCollateralToken is ERC20 {
    address public immutable CONDITIONAL_TOKENS;
    address public immutable OWNER;

    /// @notice Reverts when a non-allowed transfer is attempted.
    /// @param from The address tokens are being transferred from.
    /// @param to The address tokens are being sent to.
    /// @param sender The caller of the transfer function (msg.sender).
    error InvalidPlayTokenTransfer(address from, address to, address sender);

    /// @notice Initializes the token with a specified name, symbol, initial supply, and references to ConditionalTokens and owner.
    /// @param name_ ERC20 name.
    /// @param symbol_ ERC20 symbol.
    /// @param initialSupply The initial amount of tokens to mint.
    /// @param conditionalTokens The ConditionalTokens contract that can interact with these tokens.
    /// @param owner The address to receive the initial supply and act as token owner.
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address conditionalTokens,
        address owner
    ) ERC20(name_, symbol_) {
        CONDITIONAL_TOKENS = conditionalTokens;
        OWNER = owner;
        _mint(owner, initialSupply);
    }

    /// @notice Restricts token transfers to or from the owner and the ConditionalTokens contract.
    /// @dev Reverts if neither side of the transfer is valid:
    ///      - Sender must be OWNER or CONDITIONAL_TOKENS
    ///      - Recipient must be CONDITIONAL_TOKENS (if called by CONDITIONAL_TOKENS) or OWNER
    /// @param from The address tokens are transferred from.
    /// @param to The address tokens are transferred to.
    modifier onlyPlayTransfers(address from, address to) {
        bool isFromAllowed = (from == CONDITIONAL_TOKENS || from == OWNER);
        bool isToAllowed = ((to == CONDITIONAL_TOKENS && msg.sender == CONDITIONAL_TOKENS) || to == OWNER);
        if (!isFromAllowed && !isToAllowed) {
            revert InvalidPlayTokenTransfer(from, to, msg.sender);
        }
        _;
    }

    /// @dev Enforces `onlyPlayTransfers` before calling the base logic.
    function _update(address from, address to, uint256 value) internal virtual override onlyPlayTransfers(from, to) {
        super._update(from, to, value);
    }
}
