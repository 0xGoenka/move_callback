/// Module: move_callback
module move_callback::move_callback {
    use std::string::String;
    use sui::coin::Coin;
    use sui::coin;
    use sui::sui::SUI;
    use bridge::bridge::{Self};

    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const MIN_INFERENCE_COST: u64 = 50_000_000;

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

    public fun callback(prompt_result:String, model_name: String, ownerCap: &mut bridge::OwnerCap, ctx: &mut TxContext) {

    }
}

