/*
Reproductive extracts:
	When fed three biomass cubes, produces between
	1 and 4 normal slime extracts of the same colour.
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
	colour = "grey"

/obj/item/slimecross/reproductive/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"

/obj/item/slimecross/reproductive/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"

/obj/item/slimecross/reproductive/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"

/obj/item/slimecross/reproductive/metal
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"

/obj/item/slimecross/reproductive/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"

/obj/item/slimecross/reproductive/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"

/obj/item/slimecross/reproductive/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"

/obj/item/slimecross/reproductive/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"

/obj/item/slimecross/reproductive/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"

/obj/item/slimecross/reproductive/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"

/obj/item/slimecross/reproductive/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"

/obj/item/slimecross/reproductive/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"

/obj/item/slimecross/reproductive/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"

/obj/item/slimecross/reproductive/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"

/obj/item/slimecross/reproductive/pink
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"

/obj/item/slimecross/reproductive/gold
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"

/obj/item/slimecross/reproductive/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"

/obj/item/slimecross/reproductive/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"

/obj/item/slimecross/reproductive/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"

/obj/item/slimecross/reproductive/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"

/obj/item/slimecross/reproductive/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
