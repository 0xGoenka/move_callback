/// Module: move_callback
module jarjar_playground::jarjar_playground {
    use std::string::{utf8, String};
    use sui::coin::Coin;
    use sui::coin;
    use sui::event;
    use sui::sui::SUI;
    use sui::package;
    use sui::display;
    use jarjar_ai_oracle::jarjar_ai_oracle::{Self};
    use jarjar_ai_oracle::price_model::{Self};

    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const ERROR_NOT_ENOUGHT_PERMISSION: u64 = 2;
    const ERROR_INVALIDE_NUMBER_OF_GENERATION: u64 = 3;


    public struct JARJAR_PLAYGROUND has drop {}

    public struct JarJarPlaygroundNFT has key, store {
        id: UID,
        image_url: String,
        description: String,
        number: String,
    }

    public struct CallbackEvent has copy, drop {
        name: String,
        description: String,
        image_url: String,
        number: String,
    }

    #[allow(lint(self_transfer))]
    fun init(otw: JARJAR_PLAYGROUND, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"number"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            // For `name` one can use the `Hero.name` property
            utf8(b"jarjar_playground"),
            // For `link` one can build a URL using an `id` property
            utf8(b"{image_url}"),
            // For `image_url` use an IPFS template + `image_url` property.
            utf8(b"{image_url}"),
            // Description is static for all `Hero` objects.
            utf8(b"{description}"),
            utf8(b"{number}"),
            // Project URL is usually static
            utf8(b"https://playground.jarjar.xyz"),
            // Creator field can be any
            utf8(b"https://x.com/JARJARxyz"),
        ];

        let publisher = package::claim(otw, ctx);
        let mut display = display::new_with_fields<JarJarPlaygroundNFT>(
            &publisher, keys, values, ctx
        );
        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);


        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    public fun generate(
        prompt_data: String,
        callback_data: String,
        model_name: String,
        mut payment: Coin<SUI>,
        price_model: &mut price_model::PriceModel,
        ownerCap: &mut jarjar_ai_oracle::OwnerCap,
        gen_quantity: u8,
        ctx: &mut TxContext
        ) {
        assert!(gen_quantity > 0, ERROR_INVALIDE_NUMBER_OF_GENERATION);  
        assert!(gen_quantity <= 4, ERROR_INVALIDE_NUMBER_OF_GENERATION);  

        let value: u64 = coin::value(&payment);
        let inferenceCost = price_model::get_price(price_model, &model_name) * (gen_quantity as u64);
        assert!(value == inferenceCost, ERROR_INSUFFICIENT_FUNDS);

        let inference_coin = coin::take(coin::balance_mut(&mut payment), inferenceCost, ctx);
        jarjar_ai_oracle::generate(prompt_data, callback_data, model_name, inference_coin, price_model, ownerCap,ctx);

        let to = jarjar_ai_oracle::get_owner_cap_address(ownerCap);
        transfer::public_transfer(payment, to);
        
    }

    public fun callback(ai_gen_result:String, sender: address, description: String, number: String, ownerCap: &mut jarjar_ai_oracle::OwnerCap, ctx: &mut TxContext) { 
        assert!(tx_context::sender(ctx) == jarjar_ai_oracle::get_owner_cap_address(ownerCap), ERROR_NOT_ENOUGHT_PERMISSION);

        let id = object::new(ctx);
        let nft = JarJarPlaygroundNFT { id, image_url:ai_gen_result, description:description, number: number };
        transfer::public_transfer(nft, sender);
        event::emit(CallbackEvent {
            name: utf8(b"jarjar_playground"),
            description: description,
            image_url: ai_gen_result,
            number: number,
        });
    }
}