/obj/structure/anvil
	name = "anvil"
	desc = "Great for forging. Has helpful context for when I examine or am about to interact with it. I should check it often."

	density = TRUE
	anchored = TRUE

	icon = 'icons/modules/smithing/forge_structures.dmi'
	icon_state = "anvil_empty"

	var/datum/anvil_recipe/chosen_recipe

	var/obj/item/working_material

	var/list/recipes = list()
	var/list/name_to_type = list()

	///for debugging purposes: this will always be perfect
	var/always_perfect = FALSE

/obj/structure/anvil/Initialize(mapload)
	. = ..()
	for(var/datum/anvil_recipe/recipe as anything in subtypesof(/datum/anvil_recipe))
		name_to_type |= list(initial(recipe.name) = recipe)
		var/image/new_image = image(icon = initial(recipe.output.icon), icon_state = initial(recipe.output.icon_state))
		recipes |= list(initial(recipe.name) = new_image)
	register_context()
	AddElement(/datum/element/falling_hazard, damage = 100, wound_bonus = 10, hardhat_safety = FALSE, crushes = TRUE, impact_sound = 'code/modules/smithing/sounds/forge.ogg')

/obj/structure/anvil/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_HAMMER)
		if(working_part())
			context[SCREENTIP_CONTEXT_RMB] = "Heat Material."
			context[SCREENTIP_CONTEXT_LMB] = "Strike Anvil."
	else if(held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Try put on anvil."
	if(working_material && chosen_recipe && !held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Start Forging"
		context[SCREENTIP_CONTEXT_RMB] = "Clear Recipe"
	if(!chosen_recipe && !held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Select a part to forge."
	if(!chosen_recipe && working_material && !held_item)
		context[SCREENTIP_CONTEXT_RMB] = "Empty Anvil"
	return CONTEXTUAL_SCREENTIP_SET


/obj/structure/anvil/examine(mob/user)
	. = ..()
	if(!working_part() && working_material)
		. += "[src] contains [working_material]. I could plan the recipe with a LEFT EMPTY HAND interact."
	if(working_part())
		if(istype(working_material,/obj/item/smithed_part/weapon_part))
			var/obj/item/smithed_part/weapon_part/part = working_material
			. += "[src] contains [working_material]; [part.forge_text()]"

		if(istype(working_material,/obj/item/clothing/smithed_clothes))
			var/obj/item/clothing/smithed_clothes/part = working_material
			. += "[src] contains [working_material]; [part.forge_text()]"

///Yes I am that lazy to make this a proc.
/obj/structure/anvil/proc/working_part()
	if(!working_material)
		return FALSE
	if(istype(working_material,/obj/item/smithed_part) || istype(working_material,/obj/item/clothing/smithed_clothes))
		return TRUE
	return FALSE

/obj/structure/anvil/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(anchored && !working_part())
		if(!chosen_recipe)
			var/pick = show_radial_menu(user, src, recipes, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
			if(!pick)
				return
			if(!(pick in name_to_type))
				return
			chosen_recipe = name_to_type[pick]
			return
		if(working_material && chosen_recipe && working_material.material_stats)
			//var/density_hardness = 0
			//density_hardness = working_material.material_stats.hardness + working_material.material_stats.density

			var/qual_mod = (user.mind?.get_skill_level(/datum/skill/smithing) * 10) - 35
			if(always_perfect)
				generate_item(100)
				user.balloon_alert(user,"part shaped!")
			else
				generate_item(qual_mod)
				user.balloon_alert(user,"part shaped!")
			return

/obj/structure/anvil/attack_hand_secondary(mob/user, list/modifiers)
	if(chosen_recipe && working_part())
		user.put_in_active_hand(working_material)
		visible_message("[user] takes the [working_material] off the anvil.")
		working_material = null
		user.balloon_alert(user,"item removed!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!chosen_recipe && working_material)
		user.put_in_active_hand(working_material)
		visible_message("[user] takes the [working_material] off the anvil.")
		working_material = null
		user.balloon_alert(user,"item removed!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(chosen_recipe)
		chosen_recipe = null
		visible_message("[user] changes their mind on what to make.")
		user.balloon_alert(user,"recipe reset!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	. = ..()

/obj/structure/anvil/proc/generate_item(quality)
	var/obj/output = new chosen_recipe.output
	if(istype(output,/obj/item/smithed_part))
		var/obj/item/smithed_part/new_part = chosen_recipe.output
		var/obj/item/smithed_part/boi = new new_part (get_turf(src), working_material, quality)
		boi.forceMove(src)
		var/randhits = min(rand(20,40),boi.hits_left)
		boi.hit_counter = randhits
		boi.hits_left -= randhits
		visible_message("[working_material] is shaped into a crude [boi]!")
		QDEL_NULL(working_material)
		working_material = boi
	else if(istype(output,/obj/item/clothing/smithed_clothes))
		var/obj/item/clothing/smithed_clothes/new_part = chosen_recipe.output
		var/obj/item/clothing/smithed_clothes/boi = new new_part (get_turf(src), working_material, quality)
		boi.forceMove(src)
		var/randhits = min(rand(20,40),boi.hits_left)
		boi.hit_counter = randhits
		boi.hits_left -= randhits
		visible_message("[working_material] is shaped into a crude [boi]!")
		QDEL_NULL(working_material)
		working_material = boi
	QDEL_NULL(output) //Thanks, bye

/obj/structure/anvil/attackby(obj/item/attacking_item, mob/living/user, params)
	if((isstack(attacking_item)  || istype(attacking_item, /obj/item/merged_material) || istype(attacking_item,/obj/item/smithed_part) || istype(attacking_item,/obj/item/clothing/smithed_clothes)) && !working_material)
		if(try_place_item(attacking_item, user))
			return
	if(attacking_item.tool_behaviour == TOOL_WRENCH && !working_material)
		default_unfasten_wrench(user,attacking_item,40)
		return
	if(attacking_item.tool_behaviour == TOOL_HAMMER)
		if(chosen_recipe && working_part() && params[RIGHT_CLICK])
			smith(user,TRUE)
			return
		if(chosen_recipe && working_part())
			smith(user)
			return
		return
	return ..()

/obj/structure/anvil/proc/smith(mob/user, heat = FALSE)
	if(istype(working_material,/obj/item/smithed_part/weapon_part))
		var/obj/item/smithed_part/weapon_part/in_anv = working_material
		if(in_anv.complete)
			return
		if(always_perfect)
			in_anv.smithed_quality = 100
			in_anv.hits_left = 0
			in_anv.hit_counter = 0
			return
		if(heat && in_anv.hits_left > 0)
			if(in_anv.hit_counter > 0)
				in_anv.smithed_quality -= in_anv.hit_counter
			var/randhits = min(rand(20,40),in_anv.hits_left)
			in_anv.hit_counter = randhits
			in_anv.hits_left -= randhits
			user.balloon_alert(user,"[in_anv] is re-heated,ready for hammering.")
			return
		if(heat && in_anv.hits_left <= 0)
			user.balloon_alert(user,"finished smithing!")
			return
		if(in_anv.hit_counter > 0)
			in_anv.smithed_quality++
		in_anv.hit_counter--
		if(in_anv.hit_counter % 10 == 4)
			user.balloon_alert(user,"[in_anv] sparks as it cools!")
		if(prob(0.1))
			playsound(src, 'code/modules/smithing/sounds/lead_pipe_falling.ogg', 25, TRUE,frequency = 0.8 + (0.4 * (in_anv.hit_counter/33)), mixer_channel = CHANNEL_SOUND_EFFECTS)
		else
			playsound(src, 'code/modules/smithing/sounds/forge.ogg', 25, TRUE,frequency = 0.8 + (0.4 * (in_anv.hit_counter/33)), mixer_channel = CHANNEL_SOUND_EFFECTS)
		user.mind.adjust_experience(/datum/skill/smithing,1.5)
		return
	if(istype(working_material,/obj/item/clothing/smithed_clothes))
		var/obj/item/clothing/smithed_clothes/in_anv = working_material
		if(in_anv.complete)
			return
		if(always_perfect)
			in_anv.smithed_quality = 100
			in_anv.hits_left= 0
			in_anv.hit_counter = 0
			return
		if(heat && in_anv.hits_left > 0)
			if(in_anv.hit_counter > 0)
				in_anv.smithed_quality -= in_anv.hit_counter
			var/randhits = min(rand(20,40),in_anv.hits_left)
			in_anv.hit_counter = randhits
			in_anv.hits_left -= randhits
			user.balloon_alert(user,"[in_anv] is re-heated,ready for hammering.")
			return
		if(heat && in_anv.hits_left <= 0)
			user.balloon_alert(user,"finished smithing!")
			return
		if(in_anv.hit_counter > 0)
			in_anv.smithed_quality++
		in_anv.hit_counter--
		if(in_anv.hit_counter % 10 == 4)
			user.balloon_alert(user,"[in_anv] sparks as it cools!")
		if(prob(0.1))
			playsound(src, 'code/modules/smithing/sounds/lead_pipe_falling.ogg', 25, TRUE,frequency = 0.8 + (0.4 * (in_anv.hit_counter/33)), mixer_channel = CHANNEL_SOUND_EFFECTS)
		else
			playsound(src, 'code/modules/smithing/sounds/forge.ogg', 25, TRUE,frequency = 0.8 + (0.4 * (in_anv.hit_counter/33)), mixer_channel = CHANNEL_SOUND_EFFECTS)
		user.mind.adjust_experience(/datum/skill/smithing,1.5)
		return

/obj/structure/anvil/proc/try_place_item(obj/item/item, mob/living/user)
	if(working_material && !working_part())
		working_material.forceMove(get_turf(src))
		working_material = null
		user.balloon_alert(user,"ingot replaced!")
		visible_message("[user] replaces the ingot on the anvil.")
	if(isstack(item) && !working_material)
		var/obj/item/stack/stack = item
		if(!stack.material_type)
			working_material = null
			return FALSE
		if(stack.amount == 1)
			item.forceMove(src)
			working_material = item
		else
			var/obj/item/stack/new_stack = stack.split_stack(user, 1)
			new_stack.forceMove(src)
			working_material = new_stack
	else if((istype(item, /obj/item/merged_material) || istype(item, /obj/item/smithed_part) || istype(item, /obj/item/clothing/smithed_clothes)) && !working_material)
		item.forceMove(src)
		working_material = item
	return TRUE
