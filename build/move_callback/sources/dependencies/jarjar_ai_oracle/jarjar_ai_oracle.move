
module jarjar_ai_oracle::jarjar_ai_oracle {
    use std::string::String;
    use sui::event;
    use sui::coin::Coin;
    use sui::coin;
    use sui::sui::SUI;
    use jarjar_ai_oracle::price_model::{Self, PriceModel};

    const EInvalidPrice: u64 = 1;
    
    public struct EventGenerate has copy, drop  {
        prompt_data: String,
        callback_data: String,
        model_name: String,
        sender: address,
        value: u64,
    }   

    public struct OwnerCap has key { id: UID, owner: address }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(
    OwnerCap {
            id: object::new(ctx),            
            owner: tx_context::sender(ctx),
        }
        );
    } 

    public fun get_owner_cap_address(ownercap: &OwnerCap): address {
        ownercap.owner
    }

    public fun generate(
        prompt_data: String,  
        callback_data: String,
        model_name: String,
        payment: Coin<SUI>,
        price_model: &PriceModel,
        ownercap: &mut OwnerCap,
        ctx: &mut TxContext
    ) {
        let price = price_model::get_price(price_model, &model_name);
        assert!(coin::value(&payment) >= price, EInvalidPrice);

        let value: u64 = coin::value(&payment);

        transfer::public_transfer(payment, ownercap.owner);

        event::emit(EventGenerate {
            prompt_data,
            callback_data,
            model_name,
            sender: tx_context::sender(ctx),
            value,
        });
    }
}
