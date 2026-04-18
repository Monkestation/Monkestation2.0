///Physical Monkecoin item
/obj/item/stack/monkecoin
	name = "monkecoin"
	singular_name = "monkecoin"
	icon = 'monkestation/icons/obj/monkecoin.dmi'
	icon_state = "monkecoin"
	amount = 1
	max_amount = INFINITY
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	merge_type = /obj/item/stack/monkecoin
	///The value each individual monkecoin has, this is multiplied by amount.
	var/value = 100

/obj/item/stack/monkecoin/Initialize(mapload, new_amount, merge = FALSE, list/mat_override=null, mat_amt=1)
	. = ..()
	update_desc()

/obj/item/stack/monkecoin/update_desc()
	. = ..()
	var/total_worth = get_item_credit_value()
	desc = "Monkecoin, it's the backbone of the economy. "
	desc += "It's worth [total_worth] credit[(total_worth > 1) ? "s" : null] in total."
	update_icon_state()

/obj/item/stack/monkecoin/get_item_credit_value()
	return (amount*value)

/obj/item/stack/monkecoin/merge(obj/item/stack/S)
	. = ..()
	update_desc()

/obj/item/stack/monkecoin/use(used, transfer = FALSE, check = TRUE)
	. = ..()
	update_desc()

/obj/item/stack/monkecoin/update_icon_state()
	. = ..()
	var/coinpress = copytext("[amount]",1,2)
	switch(amount)
		if(1 to 9)
			icon_state = "[initial(icon_state)][coinpress]"
		if(10 to 99)
			icon_state = "[initial(icon_state)][coinpress]0"
		if(100 to 999)
			icon_state = "[initial(icon_state)][coinpress]00"
		if(1000 to 8999)
			icon_state = "[initial(icon_state)][coinpress]000"
		if(9000 to INFINITY)
			icon_state = "[initial(icon_state)]9000"

/obj/item/stack/monkecoin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to gouge [user.p_their()] eyes with the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.emote("scream")
	if(do_after(user, 5 SECONDS, src))
		return BRUTELOSS
	else
		user.visible_message(span_suicide("[user] puts the [src] down away from [user.p_their()] eyes."))
