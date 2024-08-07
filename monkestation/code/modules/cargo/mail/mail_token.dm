/obj/item/stack/mail_token
    name = "mail token"
    desc = "A plastic mail token. Part of a new program to get Nanotrasen cargo employees to deliver mail. Can be exported to Central Command for an increase to the budget."
    singular_name = "mail token"
    icon = 'monkestation/code/modules/cargo/mail/mail.dmi'
    w_class = WEIGHT_CLASS_TINY
    icon_state = "mailtokens"
    item_flags = NOBLUDGEON
    resistance_flags = FLAMMABLE
    merge_type = /obj/item/stack/mail_token
    max_amount = 10
    novariants = TRUE

/obj/item/stack/mail_token/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
    . = ..()
    update_appearance()

/obj/item/stack/mail_token/update_icon_state()
	. = ..()
	var/amount = get_amount()
	if(amount <= 1)
		icon_state = "mailtoken-1"
	if(amount > 1 && amount < 3)
		icon_state = "mailtoken-2"
	if(amount > 2 && amount < 4)
		icon_state = "mailtoken-3"
	if(amount > 3 && amount < 7)
		icon_state = "mailtoken-5"
	if(amount >= 7)
		icon_state = "mailtokens"

/datum/export/stack/mail_token
	cost = CARGO_CRATE_VALUE
	unit_name = "mail token"
	k_elasticity = 0
	export_types = list(/obj/item/stack/mail_token)
