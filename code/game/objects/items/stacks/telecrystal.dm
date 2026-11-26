/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	dye_color = DYE_SYNDICATE
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/telecrystal
	novariants = FALSE

/obj/item/stack/telecrystal/attack(mob/target, mob/user)
	if(target == user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		for(var/obj/item/implant/uplink/I in target)
			if(I?.imp_in)
				var/datum/component/uplink/hidden_uplink = I.GetComponent(/datum/component/uplink)
				if(hidden_uplink)
					hidden_uplink.add_telecrystals(amount)
					use(amount)
					to_chat(user, span_notice("You press [src] onto yourself and charge your hidden uplink."))
	else
		return ..()

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20

GLOBAL_LIST_INIT(telecrystal_recipes, list ( \
	new/datum/stack_recipe("telecrystal tile", /obj/item/stack/tile/mineral/telecrystal, 1, 4, 20, check_density = FALSE, category = CAT_TILES), \
))

/obj/item/stack/telecrystal/get_main_recipes()
	. = ..()
	. += GLOB.telecrystal_recipes
