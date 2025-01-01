// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import "src/PlayCollateralToken.sol";

contract PlayCollateralTokenHarness is PlayCollateralToken {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address _conditionalTokens,
        address _owner
    ) PlayCollateralToken(name_, symbol_, initialSupply, _conditionalTokens, _owner) {}

    function testModifier(address from, address to) external onlyPlayTransfers(from, to) {}
}
