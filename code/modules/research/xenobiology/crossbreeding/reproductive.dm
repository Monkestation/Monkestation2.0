/*
Reproductive extracts:
	When fed three biomass cubes, produces between
	1 and 4 normal slime extracts of the same color.
*/


/obj/item/slimecross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	effect_desc = "When fed biomass cubes it produces more extracts. Bio bag compatible as well."
	var/extract_type = /obj/item/slime_extract/
	var/cooldown = 3 SECONDS
	var/feedAmount = 3
	var/current_nutrition = 0
	var/last_produce = 0

/obj/item/slimecross/reproductive/examine()
	. = ..()
	. += span_danger("It appears to have eaten [current_nutrition] Biomass Cube[p_s()]")

/obj/item/slimecross/reproductive/item_interaction(mob/living/user, obj/item/target_item, list/modifiers)

	if((last_produce + cooldown) > world.time)
		to_chat(user, span_warning("[src] is still digesting!"))
		return ITEM_INTERACT_BLOCKING

	if(istype(target_item, /obj/item/storage/bag/xeno))
		var/cubes_inserted = FALSE
		for(var/obj/item/stack/biomass/target_cube in target_item.contents)
			cubes_inserted = TRUE
			if(insert_cubes(user, target_cube))
				break
		if(!cubes_inserted)
			to_chat(user, span_warning("There are no biomass cubes in the bio bag!"))
			return ITEM_INTERACT_BLOCKING
		else
			target_item.atom_storage.refresh_views()
			return ITEM_INTERACT_SUCCESS

	else if(istype(target_item, /obj/item/stack/biomass))
		insert_cubes(user, target_item)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/slimecross/reproductive/proc/insert_cubes(user, obj/item/stack/biomass/target_cube)
	var/inserted_cubes = min(feedAmount - current_nutrition, target_cube.get_amount())
	target_cube.use(inserted_cubes)
	current_nutrition += inserted_cubes
	to_chat(user, span_notice("You feed [inserted_cubes] Biomass Cube[p_s()] to [src], and it pulses gently."))
	playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
	if(current_nutrition >= feedAmount)
		var/cores = rand(1,4)
		playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
		last_produce = world.time
		to_chat(user, span_notice("[src] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!"))
		for(var/i in 1 to cores)
			new extract_type(drop_location())
		current_nutrition = 0
		return TRUE
	return FALSE

/obj/item/slimecross/reproductive/grey
	extract_type = /obj/item/slime_extract/grey
	slime_type = /datum/slime_type/grey

/obj/item/slimecross/reproductive/orange
	extract_type = /obj/item/slime_extract/orange
	slime_type = /datum/slime_type/orange

/obj/item/slimecross/reproductive/purple
	extract_type = /obj/item/slime_extract/purple
	slime_type = /datum/slime_type/purple

/obj/item/slimecross/reproductive/blue
	extract_type = /obj/item/slime_extract/blue
	slime_type = /datum/slime_type/blue

/obj/item/slimecross/reproductive/metal
	extract_type = /obj/item/slime_extract/metal
	slime_type = /datum/slime_type/metal

/obj/item/slimecross/reproductive/yellow
	extract_type = /obj/item/slime_extract/yellow
	slime_type = /datum/slime_type/yellow

/obj/item/slimecross/reproductive/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	slime_type = /datum/slime_type/darkpurple

/obj/item/slimecross/reproductive/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	slime_type = /datum/slime_type/darkblue

/obj/item/slimecross/reproductive/silver
	extract_type = /obj/item/slime_extract/silver
	slime_type = /datum/slime_type/silver

/obj/item/slimecross/reproductive/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	slime_type = /datum/slime_type/bluespace

/obj/item/slimecross/reproductive/sepia
	extract_type = /obj/item/slime_extract/sepia
	slime_type = /datum/slime_type/sepia

/obj/item/slimecross/reproductive/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	slime_type = /datum/slime_type/cerulean

/obj/item/slimecross/reproductive/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	slime_type = /datum/slime_type/pyrite

/obj/item/slimecross/reproductive/red
	extract_type = /obj/item/slime_extract/red
	slime_type = /datum/slime_type/red

/obj/item/slimecross/reproductive/green
	extract_type = /obj/item/slime_extract/green
	slime_type = /datum/slime_type/green

/obj/item/slimecross/reproductive/pink
	extract_type = /obj/item/slime_extract/pink
	slime_type = /datum/slime_type/pink

/obj/item/slimecross/reproductive/gold
	extract_type = /obj/item/slime_extract/gold
	slime_type = /datum/slime_type/gold

/obj/item/slimecross/reproductive/oil
	extract_type = /obj/item/slime_extract/oil
	slime_type = /datum/slime_type/oil

/obj/item/slimecross/reproductive/black
	extract_type = /obj/item/slime_extract/black
	slime_type = /datum/slime_type/black

/obj/item/slimecross/reproductive/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	slime_type = /datum/slime_type/lightpink

/obj/item/slimecross/reproductive/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	slime_type = /datum/slime_type/adamantine

/obj/item/slimecross/reproductive/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	slime_type = /datum/slime_type/rainbow
