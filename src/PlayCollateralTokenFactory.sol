// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import "./PlayCollateralToken.sol";

/// @title PlayCollateralTokenFactory
/// @notice Factory contract for deploying PlayCollateralToken instances, each bound to a specified ConditionalTokens address.
contract PlayCollateralTokenFactory {
    /// @dev The ConditionalTokens address that all newly created tokens will use.
    address public immutable CONDITIONAL_TOKENS;

    /// @notice Emitted when a new PlayCollateralToken is created.
    /// @param token The address of the newly deployed token.
    event PlayCollateralTokenCreated(address indexed token);

    /// @param conditionalTokens The address of the ConditionalTokens contract that each token should trust.
    constructor(address conditionalTokens) {
        CONDITIONAL_TOKENS = conditionalTokens;
    }

    /// @notice Deploys a new PlayCollateralToken with a given name, symbol, initial supply, and owner.
    /// @param name The ERC20 name.
    /// @param symbol The ERC20 symbol.
    /// @param initialSupply The initial token supply to be minted to `owner`.
    /// @param owner The address that will receive the initial supply and act as token owner.
    /// @return The address of the newly created PlayCollateralToken contract.
    function createCollateralToken(string memory name, string memory symbol, uint256 initialSupply, address owner)
        external
        returns (address)
    {
        PlayCollateralToken newToken = new PlayCollateralToken(name, symbol, initialSupply, CONDITIONAL_TOKENS, owner);
        emit PlayCollateralTokenCreated(address(newToken));
        return address(newToken);
    }
}
