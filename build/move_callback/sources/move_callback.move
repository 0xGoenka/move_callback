/// Module: move_callback
module move_callback::move_callback {
    use std::string::{utf8, String};
    use sui::coin::Coin;
    use sui::coin;
    use sui::sui::SUI;
    use sui::package;
    use sui::display;
    use jarjar_ai_oracle::jarjar_ai_oracle::{Self};
    use jarjar_ai_oracle::price_model::{Self};
    use move_callback::free_mint::{Self};

    const ERROR_INSUFFICIENT_FUNDS: u64 = 1;
    const ERROR_NOT_ENOUGHT_PERMISSION: u64 = 2;
    const ERROR_MAX_SUPPLY_REACHED: u64 = 3;

    const FREE_MINT_INFERENCE_COST: u64 = 100_000_000; 
    const INFERENCE_COST: u64 = 200_000_000;

    public struct MOVE_CALLBACK has drop {}

    public struct JarJarNFT has key, store {
        id: UID,
        name: String,
        image_url: String,
        description: String,
    }

    public struct MintCap has key {
        id: UID,
        total_minted: u64,
        max_supply: u64,
    }

    #[allow(lint(self_transfer))]
    fun init(otw: MOVE_CALLBACK, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            // For `name` one can use the `Hero.name` property
            utf8(b"{name}"),
            // For `link` one can build a URL using an `id` property
            utf8(b"{image_url}"),
            // For `image_url` use an IPFS template + `image_url` property.
            utf8(b"{image_url}"),
            // Description is static for all `Hero` objects.
            utf8(b"{description}"),
            // Project URL is usually static
            utf8(b"https://jarjar.xyz"),
            // Creator field can be any
            utf8(b"https://x.com/JARJARxyz"),
        ];

        let publisher = package::claim(otw, ctx);

        let mut display = display::new_with_fields<JarJarNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

        let cap = MintCap {
            id: object::new(ctx),
            total_minted: 0,
            max_supply: 400,
        };
        transfer::share_object(cap);
    }

    public fun generate(
        prompt_data: String,
        callback_data: String,
        model_name: String,
        mut payment: Coin<SUI>,
        price_model: &mut price_model::PriceModel,
        ownerCap: &mut jarjar_ai_oracle::OwnerCap,
        freemint_ticket: option::Option<free_mint::JarJarFreemint>,
        cap: &mut MintCap,
        ctx: &mut TxContext
        ) {

        let value: u64 = coin::value(&payment);

        if (option::is_none(&freemint_ticket)) {
            assert!(value == INFERENCE_COST, ERROR_INSUFFICIENT_FUNDS);
            assert!(cap.total_minted < cap.max_supply, ERROR_MAX_SUPPLY_REACHED);

        } else {
            assert!(value == FREE_MINT_INFERENCE_COST, ERROR_INSUFFICIENT_FUNDS);
        };

        let inference_coin = coin::take(coin::balance_mut(&mut payment), FREE_MINT_INFERENCE_COST, ctx);

        jarjar_ai_oracle::generate(prompt_data, callback_data, model_name, inference_coin, price_model,ownerCap,ctx);
        let to = jarjar_ai_oracle::get_owner_cap_address(ownerCap);
        transfer::public_transfer(payment, to);
        free_mint::destroy_ticket(freemint_ticket);
        cap.total_minted = cap.total_minted + 1;
    }

    public fun callback(ai_gen_result:String, sender: address, name:String, description:String, ownerCap: &mut jarjar_ai_oracle::OwnerCap, ctx: &mut TxContext) { 
        assert!(tx_context::sender(ctx) == jarjar_ai_oracle::get_owner_cap_address(ownerCap), ERROR_NOT_ENOUGHT_PERMISSION);

        let id = object::new(ctx);
        let nft = JarJarNFT { id, name, image_url:ai_gen_result, description };
        transfer::public_transfer(nft, sender);
    }

    public fun get_mint_status(cap: &MintCap): (u64, u64) {
       (cap.total_minted, cap.max_supply + 100)
    }
}

