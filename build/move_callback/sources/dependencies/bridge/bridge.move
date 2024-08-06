
module bridge::bridge {
    use std::string::String;
    use sui::event;
    use sui::coin::Coin;
    use sui::coin;
    use sui::sui::SUI;

    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const MIN_INFERENCE_COST: u64 = 50_000_000;
    

    public struct EventGenerate has copy, drop  {
        prompt_data: String, 
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


    public fun generate(
        prompt_data: String,  
        model_name: String,
        payment: Coin<SUI>,
        ownercap: &mut OwnerCap,
        ctx: &mut TxContext
        ) {

        let value: u64 = coin::value(&payment);

        assert!(value == MIN_INFERENCE_COST, ERROR_INSUFFICIENT_FUNDS);

        transfer::public_transfer(payment, ownercap.owner);

        event::emit(EventGenerate {
            prompt_data,
            model_name,
            sender: tx_context::sender(ctx),
            value,
        });
    }
}
