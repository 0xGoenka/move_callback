/// Module: move_callback
module move_callback::move_callback {
    use std::string::String;
    use sui::coin::Coin;
    use sui::coin;
    use sui::sui::SUI;
    use bridge::bridge::{Self};

    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const ERROR_NOT_ENOUGHT_PERMISSION: u64 = 2;
    const MIN_INFERENCE_COST: u64 = 50_000_000;

    public struct JarJarNFT has key, store {
        id: UID,
        name: String,
        description: String,
        url: String,
        serial_number: u64,
    }

    public fun generate(
        prompt_data: String,  
        model_name: String,
        payment: Coin<SUI>,
        ownerCap: &mut bridge::OwnerCap,
        ctx: &mut TxContext
        ) {

        let value: u64 = coin::value(&payment);

        assert!(value == MIN_INFERENCE_COST, ERROR_INSUFFICIENT_FUNDS);
        bridge::generate(prompt_data, model_name, payment, ownerCap,ctx);

        // transfer::public_transfer(payment, ownercap.owner);
    }

    public fun callback(prompt_result:String, sender: address, ownerCap: &mut bridge::OwnerCap, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == bridge::get_owner_cap_address(ownerCap), ERROR_NOT_ENOUGHT_PERMISSION);

        let nft = JarJarNFT {
            id: object::new(ctx),
            name: prompt_result,
            description: prompt_result,
            url: prompt_result,
            serial_number: 0,
        };

        transfer::public_transfer(nft, sender);
    }
}

