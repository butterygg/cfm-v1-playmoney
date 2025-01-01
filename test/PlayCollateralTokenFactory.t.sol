// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import "forge-std/src/Test.sol";

import "src/PlayCollateralTokenFactory.sol";

contract CollateralTokenFactoryTest is Test {
    PlayCollateralTokenFactory factory;
    address condTokens = address(0x1111);

    function setUp() public {
        factory = new PlayCollateralTokenFactory(condTokens);
    }

    function testCreateCollateralToken(address owner, uint256 supply) public {
        vm.assume(owner != address(0));

        address tokenAddr = factory.createCollateralToken("FactoryToken", "FCT", supply, owner);
        PlayCollateralToken token = PlayCollateralToken(tokenAddr);

        assertEq(token.name(), "FactoryToken");
        assertEq(token.symbol(), "FCT");
        assertEq(token.totalSupply(), supply);
        assertEq(token.balanceOf(owner), supply);
        assertEq(token.CONDITIONAL_TOKENS(), condTokens);
        assertEq(token.OWNER(), owner);
    }
}
