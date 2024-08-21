module jarjar_ai_oracle::price_model {
    use sui::table::{Self, Table};
    use std::string::String;

    // Errors
    const EModelNotFound: u64 = 1;

    // PriceModel struct to store the pricing information
    public struct PriceModel has key {
        id: UID,
        prices: Table<String, u64>,
    }

    public struct AdminCap has key, store {
        id: UID
    }

    // Initialize the PriceModel
    fun init(ctx: &mut TxContext) {
        let price_model = PriceModel {
            id: object::new(ctx),
            prices: table::new(ctx),
        };
        transfer::share_object(price_model);

        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // Add or update a model's price
    public entry fun update_price(
        _: &AdminCap,
        price_model: &mut PriceModel,
        model_name: String,
        price: u64,
        _ctx: &mut TxContext
    ) {
        if (table::contains(&price_model.prices, model_name)) {
            let stored_price = table::borrow_mut(&mut price_model.prices, model_name);
            *stored_price = price;
        } else {
            table::add(&mut price_model.prices, model_name, price);
        }
    }

    public fun delete_model(
        _: &AdminCap,
        price_model: &mut PriceModel,
        model_name: String,
    ) {
        assert!(table::contains(&price_model.prices, model_name), EModelNotFound);
        table::remove(&mut price_model.prices, model_name);
    }

    // Get the price for a given model
    public fun get_price(price_model: &PriceModel, model_name: &String): u64 {
        assert!(table::contains(&price_model.prices, *model_name), EModelNotFound);
        *table::borrow(&price_model.prices, *model_name)
    }
}