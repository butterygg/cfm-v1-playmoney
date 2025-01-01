# play collateral token

An implementation of a "play money" collateral token for use with
`ConditionalTokens`.

## overview

This repository provides a restrictive "play money" ERC20 token called **PlayCollateralToken**, along with a **PlayCollateralTokenFactory** that can deploy instances of it. The token only allows transfers **from** or **to**:

- The **owner** (who initially receives all tokens),
- The **ConditionalTokens** contract, but only when initiated by the ConditionalTokens contract itself.

This ensures no free trading occurs—tokens can’t flow to arbitrary addresses or be traded on DEXes.

## how the token works

- **Constructor**: Mints an initial supply of tokens to the `OWNER`.
- **Transfer Restrictions**:
  - Transfers from `OWNER` to `CONDITIONAL_TOKENS` are allowed. 
  - Transfers from `CONDITIONAL_TOKENS` to `OWNER` are allowed (only when the contract calls `transferFrom`).
  - Any other transfers revert with an `InvalidPlayTokenTransfer` error.
- **Minting & Burning**:
  - Minting occurs in the constructor (or if you extend the logic). 
  - Burning can be simulated by sending tokens back to `OWNER` or possibly making additional logic if needed.

## using the factory

1. Deploy `PlayCollateralTokenFactory` by passing it the address of the ConditionalTokens contract you want to trust.
2. Call `createCollateralToken(name, symbol, initialSupply, owner)` on the factory:
   - **name**: A string for the ERC20 name.
   - **symbol**: A string for the ERC20 ticker.
   - **initialSupply**: The amount of tokens to mint to the `owner`.
   - **owner**: The address that will control and distribute tokens.

The factory will emit an event `PlayCollateralTokenCreated(address token)` and return the new token address.

## PlayCollateralToken tests

The outcome of a transfer depends on three parameters:

- `from`
- `to`
- `msg.sender`

Unit tests cover every combination:

- When any of `from` or `to` is the `OWNER`.
- When `from` is `CONDITIONAL_TOKENS`.
- When `to` is `CONDITIONAL_TOKENS`:
    - When `msg.sender` is `CONDITIONAL_TOKENS`.
    - Otherwise (reverts).
- Otherwise (reverts).

Additional integration test verify that the `transfer` and `transferFrom` ERC20
calls work as expected.

## deployment

Using Foundry:

1. **Set environment variables** (`RPC_URL`, `SENDER`, `PRIVATE_KEY`) for your
   deployer account.
2. Set environment variables expected by the deployment script:
   `CONDITIONAL_TOKENS`, the address of the existing ConditionalTokens
   deployment.
2. **Run the deployment script**:
   ```sh
   forge script script/DeployFactory.s.sol \
     --rpc-url $RPC_URL \
     --broadcast \
     --sender $SENDER \
     --private-key $PRIVATE_KEY
   ```

## building and testing

```sh
forge soldeer install
forge build
forge test
```
