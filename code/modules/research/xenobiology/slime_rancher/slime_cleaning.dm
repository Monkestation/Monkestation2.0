/// nutrition a dissolved mess gives, same as a wanted item
#define SLIME_CLEAN_NUTRITION 5

/// Whether this is a mess a cleaner slime will eat.
/mob/living/basic/slime/proc/can_dissolve(atom/movable/mess)
	var/static/list/dissolvable_cache
	if(isnull(dissolvable_cache))
		dissolvable_cache = typecacheof(list(
			/obj/effect/decal/cleanable/ants,
			/obj/effect/decal/cleanable/ash,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/confetti,
			/obj/effect/decal/cleanable/dirt,
			/obj/effect/decal/cleanable/food,
			/obj/effect/decal/cleanable/fuel_pool,
			/obj/effect/decal/cleanable/generic,
			/obj/effect/decal/cleanable/glass,
			/obj/effect/decal/cleanable/glitter,
			/obj/effect/decal/cleanable/greenglow,
			/obj/effect/decal/cleanable/insectguts,
			/obj/effect/decal/cleanable/molten_object,
			/obj/effect/decal/cleanable/piss_stain,
			/obj/effect/decal/cleanable/shreds,
			/obj/effect/decal/cleanable/vomit,
			/obj/effect/decal/cleanable/wrapping,
			/obj/effect/decal/remains,
			/mob/living/basic/mouse,
			/mob/living/basic/cockroach,
			/obj/item/shard,
			/obj/item/food/breadslice/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/egg/rotten,
		))
		// stupid snowflake code to don't touch the slime mutation food subtypes
		for(var/slime_food_subtype in typesof(/mob/living/basic/cockroach/rockroach, /mob/living/basic/cockroach/iceroach, /mob/living/basic/cockroach/gemroach))
			dissolvable_cache[slime_food_subtype] = FALSE

	if(!isturf(mess.loc))
		return FALSE
	return is_type_in_typecache(mess, dissolvable_cache) || HAS_TRAIT(mess, TRAIT_TRASH_ITEM)

/// Sets cleaner_slime and resets the AI's cleaning state.
/mob/living/basic/slime/proc/set_cleaner_slime(enabled)
	cleaner_slime = !!enabled
	if(isnull(ai_controller))
		return
	ai_controller.CancelActions()
	ai_controller.clear_blackboard_key(BB_SLIME_CLEAN_TARGET)
	update_ai_movement_type()

/mob/living/basic/slime/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, cleaner_slime)) // special setter bc it messes with AI stuff
			set_cleaner_slime(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
	return ..()

/// Eats a mess for nutrition. Returns TRUE if it did.
/mob/living/basic/slime/proc/try_dissolve(atom/movable/mess)
	if(!cleaner_slime || !can_dissolve(mess))
		return FALSE
	visible_message(span_notice("[src] dissolves \the [mess]."))
	balloon_alert_to_viewers("cleaned")
	qdel(mess)
	adjust_nutrition(SLIME_CLEAN_NUTRITION)
	return TRUE

#undef SLIME_CLEAN_NUTRITION
