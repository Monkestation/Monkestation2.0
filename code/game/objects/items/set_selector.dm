/obj/item/set_selector
	name = "Set Selector"
	desc = "A beacon used to summon various items."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	///Our stock list, set by our spawner
	var/list/stock_list

/obj/item/set_selector/Initialize(mapload, list/stock)
	. = ..()
	stock_list = stock

/obj/item/set_selector/attack_self(mob/user, modifiers)
	. = ..()
	if(!length(stock_list))
		balloon_alert(user, "no stock left")
		return

	var/alist/name_list = alist() //cant just store this because we need to store stocks left
	for(var/atom/stock_item as anything in stock_list)
		name_list[stock_item::name] = stock_item

	var/atom/created = name_list[tgui_input_list(user, "select what to create", "[name]", name_list)]
	if(!created)
		return

	stock_list[created]--
	if(!stock_list[created])
		stock_list -= created

	moveToNullspace()
	qdel(src)
	created = create_item(created)
	if(isitem(created))
		user.put_in_active_hand(created)

/obj/item/set_selector/proc/create_item(atom/selected)
	return new selected(get_turf(src))

/obj/item/set_selector/wand_belt
	name = "Untransformed Wand"
	desc = "A small wand able to be transformed for a myriad of uses."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "shrinkwand"

/obj/item/set_selector/wand_belt/create_item(obj/item/gun/magic/wand/selected)
	selected = new selected(get_turf(src))
	selected.max_charges = selected::max_charges
	selected.charges = selected.max_charges
	return selected
