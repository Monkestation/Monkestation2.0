/obj/item/bong
	name = "bong"
	desc = "Technically known as a water pipe."
	icon = 'icons/obj/bong.dmi'
	lefthand_file = 'icons/mob/inhands/items/bong_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/bong_righthand.dmi'
	icon_state = "bongoff"
	inhand_icon_state = "bongoff"
	var/icon_on = "bongon"
	var/icon_off = "bongoff"
	var/lit = FALSE
	var/useable_bonghits = 4
	var/bonghits = 0
	var/chem_volume = 30
	var/list_reagents = null
	var/packeditem = FALSE
	var/quarter_volume = 0

/obj/item/bong/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)

/obj/item/bong/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/lighting_text = tool.ignition_effect(src,user)
	if(lighting_text)
		if(bonghits <= 0)
			to_chat(user, "<span class='warning'>There is nothing to smoke!</span>")
			return ITEM_INTERACT_BLOCKING
		light(lighting_text)
		name = "lit [initial(name)]"
		return ITEM_INTERACT_SUCCESS

	if(!istype(tool, /obj/item/food/grown))
		return NONE

	var/obj/item/food/grown/G = tool
	if(packeditem)
		to_chat(user, "<span class='warning'>It is already packed!</span>")
		return ITEM_INTERACT_BLOCKING

	if(!HAS_TRAIT(G, TRAIT_DRIED))
		to_chat(user, "<span class='warning'>It has to be dried first!</span>")
		return ITEM_INTERACT_BLOCKING

	to_chat(user, "<span class='notice'>You stuff [tool] into [src].</span>")
	bonghits = useable_bonghits
	packeditem = TRUE
	if(tool.reagents)
		tool.reagents.trans_to(src, tool.reagents.total_volume, transfered_by = user)
		quarter_volume = reagents.total_volume/useable_bonghits
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/bong/attack_self(mob/user)
	var/turf/location = get_turf(user)
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>You put out [src].</span>")
		lit = FALSE
		icon_state = icon_off
		inhand_icon_state = icon_off
		return
	if(!lit && bonghits > 0)
		to_chat(user, "<span class='notice'>You empty [src] onto [location].</span>")
		new /obj/effect/decal/cleanable/ash(location)
		packeditem = FALSE
		bonghits = 0
		reagents.clear_reagents()
	return

/obj/item/bong/attack(mob/target_mob, mob/user, def_zone)
	. = ..()
	if(!packeditem || !lit || target_mob != user)
		return

	target_mob.visible_message("<span class='notice'>[user] starts taking a hit from the [src].</span>")
	playsound(src, 'sound/chemistry/heatdam.ogg', 50, TRUE)
	if(!do_after(user, 4 SECONDS))
		return

	to_chat(target_mob, "<span class='notice'>You finish taking a hit from the [src].</span>")
	if(reagents.total_volume)
		reagents.trans_to(target_mob, quarter_volume, transfered_by = user, methods = VAPOR)
		bonghits--
	var/turf/open/pos = get_turf(src)
	if(istype(pos) && pos.air.return_pressure() < 2*ONE_ATMOSPHERE)
		pos.atmos_spawn_air("water_vapor=10;TEMP=T20C + 20")
	if(bonghits > 0)
		return

	to_chat(target_mob, "<span class='notice'>Your [name] goes out.</span>")
	lit = FALSE
	packeditem = FALSE
	icon_state = icon_off
	inhand_icon_state = icon_off
	name = "[initial(name)]"
	reagents.clear_reagents() //just to make sure

/obj/item/bong/proc/light(flavor_text = null)
	if(lit)
		return
	if(!(flags_1 & INITIALIZED_1))
		icon_state = icon_on
		inhand_icon_state = icon_on
		return

	lit = TRUE
	name = "lit [name]"
	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	// allowing reagents to react after being lit
	reagents.flags &= ~(NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	inhand_icon_state = icon_on
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)

/datum/crafting_recipe/bong
	name = "Bong"
	result = /obj/item/bong
	reqs = list(/obj/item/stack/sheet/iron = 5,
				/obj/item/stack/sheet/glass = 10)
	time = 2 SECONDS
	category = CAT_CHEMISTRY
