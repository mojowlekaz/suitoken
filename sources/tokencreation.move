module 0x0::pepe {
    use std::option;
    use sui::coin::{Self, TreasuryCap, Coin, CoinMetadata};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;

    const IconUrl: vector<u8> = b"https://ipfs.io/ipfs/QmSa3RXthfbE2QgDpbU4ghGxmBfa7BcMGUF2jSSC8V5EAL";

    /// One-time witness type for initializing the coin
    public struct PEPE has drop {}  // Only 'drop' ability

    /// Marker struct for the PEPE token
    public struct Pepecoin has drop {}

    /// Module initializer called once on module publish
    fun init(witness: PEPE, ctx: &mut TxContext) {
        let ascii_url = std::ascii::string(IconUrl);
        let icon_url = url::new_unsafe(ascii_url);

        // Create the currency with metadata and treasury
        let (mut treasury, metadata) = coin::create_currency(
            witness, 9, b"PEPE COIN", b"PEPE", b"PEPE Token for general use", option::some(icon_url), ctx
        );
        transfer::public_freeze_object(metadata);
        coin::mint_and_transfer(&mut treasury, 1000000000000000000, tx_context::sender(ctx), ctx);

        // Transfer the treasury capability to the deployer
        transfer::public_transfer(treasury, tx_context::sender(ctx));
    }


    /// Mint and transfer coins to a recipient
    public entry fun mint_and_transfer(
        treasury: &mut coin::TreasuryCap<Pepecoin>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury, amount, recipient, ctx);
    }

    /// Burn the coin `c` and decrease the total supply in `cap` accordingly
    public entry fun burn(
        cap: &mut TreasuryCap<Pepecoin>, c: Coin<Pepecoin>, amount: u64, ctx: &mut TxContext
    ): u64 {
        let coin_balance_ref = sui::coin::balance(&c);
        let coin_balance = sui::balance::value(coin_balance_ref);
        assert!(coin_balance >= amount, 0); // Add a descriptive error message here
        coin::burn(cap, c)
    }

    /// Wrapper of module initializer for testing
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(MYCOIN {}, ctx)
    }
}
