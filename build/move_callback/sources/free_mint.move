module move_callback::free_mint {
    use std::string::{utf8};
    use sui::package;
    use sui::display;

    public struct FREE_MINT has drop {}

    public struct JarJarFreemint has key, store {
        id: UID,
    }

    fun init(otw: FREE_MINT, ctx: &mut TxContext) {
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
            utf8(b"Freemint ticket for JarJar"),
            // For `link` one can build a URL using an `id` property
            utf8(b"https://c.tenor.com/zcU94gyYXcwAAAAC/tenor.gif"),
            // For `image_url` use an IPFS template + `image_url` property.
            utf8(b"https://c.tenor.com/zcU94gyYXcwAAAAC/tenor.gif"),
            // Description is static for all `Hero` objects.
            utf8(b"Freemint ticket for Jar Jar Binks Eggs NFTs the first AI collection generated at the smart contract level on $SUI"),
            // Project URL is usually static
            utf8(b"https://jarjar.xyz"),
            // Creator field can be any
            utf8(b"https://x.com/JARJARxyz"),
        ];

        let publisher = package::claim(otw, ctx);

        let mut display = display::new_with_fields<JarJarFreemint>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx)); 
        generated_freemint_ticket(ctx);
    }

    public fun destroy_ticket(freemint_ticket: option::Option<JarJarFreemint>) {
        if (option::is_some(&freemint_ticket)) {
            let ticket = option::destroy_some(freemint_ticket );
            let JarJarFreemint { id } = ticket; 
            object::delete(id);
        } else {
            option::destroy_none(freemint_ticket);
        };
    }

    #[allow(lint(self_transfer))]
    fun generated_freemint_ticket(ctx: &mut TxContext) {
        let mut i = 0;
        while (i < 2) {
            let id = object::new(ctx);
            let nft = JarJarFreemint { id };
            transfer::public_transfer(nft, tx_context::sender(ctx));
            i = i + 1;
        };
    }


}