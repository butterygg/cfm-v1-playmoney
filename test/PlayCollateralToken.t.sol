// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import "forge-std/src/Test.sol";

import "src/PlayCollateralToken.sol";

import {PlayCollateralTokenHarness} from "./harness/PlayCollateralToken.sol";

contract Base is Test {
    address condTokens = address(0x1111);
    address owner = address(0x2222);

    function setUp() public virtual {
        vm.label(condTokens, "ct");
        vm.label(owner, "owner");
    }
}

contract UnitTest is Base {
    PlayCollateralTokenHarness token;

    function setUp() public virtual override {
        token = new PlayCollateralTokenHarness("PlayToken", "PLY", 10, condTokens, owner);
    }

    function testFromOwner(address to, address sender) public {
        vm.prank(sender);
        token.testModifier(owner, to);
    }

    function testToOwner(address from, address sender) public {
        vm.prank(sender);
        token.testModifier(from, owner);
    }

    function testFromConditionalTokens(address to, address sender) public {
        vm.prank(sender);
        token.testModifier(condTokens, to);
    }

    function testToConditionalTokensSentByConditionalTokens(address from) public {
        vm.prank(condTokens);
        token.testModifier(from, condTokens);
    }

    function testToConditionalTokensSentByOtherFails(address from, address sender) public {
        vm.assume(sender != condTokens);

        vm.prank(sender);
        vm.expectRevert(
            abi.encodeWithSelector(PlayCollateralToken.InvalidPlayTokenTransfer.selector, from, condTokens, sender)
        );
        token.testModifier(from, condTokens);
    }

    function testAnyOtherFails(address from, address to, address sender) public {
        vm.assume(from != condTokens && from != owner);
        vm.assume(to != condTokens && to != owner);

        vm.prank(sender);
        vm.expectRevert(abi.encodeWithSelector(PlayCollateralToken.InvalidPlayTokenTransfer.selector, from, to, sender));
        token.testModifier(from, to);
    }
}

contract ERC20IntegrationTest is Base {
    PlayCollateralToken token;

    function setUp() public virtual override {
        token = new PlayCollateralToken("PlayToken", "PLY", 10, condTokens, owner);
    }

    function testConstructorArgs() public view {
        assertEq(token.name(), "PlayToken");
        assertEq(token.symbol(), "PLY");
        assertEq(token.totalSupply(), 10);
        assertEq(token.balanceOf(owner), 10);
        assertEq(token.CONDITIONAL_TOKENS(), condTokens);
        assertEq(token.OWNER(), owner);
    }

    function testInitialSupply() public view {
        assertEq(token.balanceOf(owner), 10);
    }

    // To or From Owner //

    function testFromOwnerTransfer(address to) public {
        vm.assume(to != condTokens && to != owner && to != address(0));

        vm.prank(owner);
        token.transfer(to, 1);
    }

    function testToOwnerTransfer(address from) public {
        vm.assume(from != condTokens && from != owner && from != address(0));

        deal(address(token), from, 1);

        vm.prank(from);
        token.transfer(owner, 1);
    }

    function testToOwnerTransferFrom(address from, address spender) public {
        vm.assume(from != address(0));
        vm.assume(spender != address(0));

        deal(address(token), from, 1);
        vm.prank(from);
        token.approve(spender, 1);

        vm.prank(spender);
        token.transferFrom(from, owner, 1);
    }

    function testFromOwnerTransferFrom(address to, address spender) public {
        vm.assume(to != address(0));
        vm.assume(spender != address(0));

        deal(address(token), owner, 1);
        vm.prank(owner);
        token.approve(spender, 1);

        vm.prank(spender);
        token.transferFrom(owner, to, 1);
    }

    // To or From CondtionalTokens //

    function testFromCondTokensTransfer(address to) public {
        vm.assume(to != condTokens && to != owner && to != address(0));

        deal(address(token), condTokens, 1);

        vm.prank(condTokens);
        token.transfer(to, 1);
    }

    function testToCondTokensTransferReverts(address from) public {
        vm.assume(from != condTokens && from != owner && from != address(0));

        deal(address(token), from, 1);

        vm.prank(from);
        vm.expectRevert(
            abi.encodeWithSelector(PlayCollateralToken.InvalidPlayTokenTransfer.selector, from, condTokens, from)
        );
        token.transfer(condTokens, 1);
    }

    function testToCondTokensTransferFromViaCondTokens(address from) public {
        vm.assume(from != owner && from != address(0));

        deal(address(token), from, 1);
        vm.prank(from);
        token.approve(condTokens, 1);

        vm.prank(condTokens);
        token.transferFrom(from, condTokens, 1);
    }

    function testOtherTransferFromViaCondTokensReverts(address from, address to) public {
        vm.assume(from != owner && from != address(0));
        vm.assume(to != condTokens && to != address(0));

        deal(address(token), from, 1);
        vm.prank(from);
        token.approve(condTokens, 1);

        vm.prank(condTokens);
        vm.expectRevert(
            abi.encodeWithSelector(PlayCollateralToken.InvalidPlayTokenTransfer.selector, from, to, condTokens)
        );
        token.transferFrom(from, to, 1);
    }

    // To or From other //

    function testOtherTransferReverts(address from, address to) public {
        vm.assume(from != condTokens && from != owner && from != address(0));
        vm.assume(to != condTokens && to != owner && to != address(0));

        deal(address(token), from, 1);

        vm.prank(from);
        vm.expectRevert(abi.encodeWithSelector(PlayCollateralToken.InvalidPlayTokenTransfer.selector, from, to, from));
        token.transfer(to, 1);
    }

    function testOtherTransferFromReverts(address from, address to, address spender) public {
        vm.assume(from != condTokens && from != owner && from != address(0));
        vm.assume(to != owner && to != address(0));
        vm.assume(spender != condTokens && spender != address(0));

        deal(address(token), from, 1);
        vm.prank(from);
        token.approve(spender, 1);

        vm.prank(spender);
        vm.expectRevert(
            abi.encodeWithSelector(PlayCollateralToken.InvalidPlayTokenTransfer.selector, from, to, spender)
        );
        token.transferFrom(from, to, 1);
    }
}
