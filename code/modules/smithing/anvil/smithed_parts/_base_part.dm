/obj/item/var/stamina_cost = 0

/obj/item/smithed_part
	name = "unfinished smithed item"
	desc = "A forged item."

	icon = 'icons/modules/smithing/forge_items.dmi'
	base_icon_state = "chain"
	icon_state = "chain"

	//* A note about Force: A 100% quality weapon with a 140 combined TOUGH/HARD should be:                      */
	//* 1 Handed weapons: 20 force 75 AP,                                                                        */
	//* 2 Handed weapons: 28 force 60 AP. Wielded                                                                */
	//* 200 TOUGH/HARD Should NEVER EXCEED 1.25X                                                                 */
	//* If your attack delay is higher, feel free to nudge around a bit; aim for 2x as slow meaning 1.5x damage. */

	wound_bonus = 0
	bare_wound_bonus = 0
	var/base_name = "generic item"
	///Used if wielded and can be
	var/wield_force = 0
	///Used if not wielded and can be
	var/unwield_force = 0

	///While smithing, we want to get this to 0, then heat
	var/hit_counter = 0
	///Just how many hits until we have worked enough
	var/hits_left = 100

	///Quality, starts at 0 and goes up or down based on minigame
	var/smithed_quality = 0
	///What is base desc when finished and assembled?
	var/finished_desc = "A forged item."

/obj/item/smithed_part/Initialize(mapload, obj/item/created_from, quality)
	. = ..()
	smithed_quality = quality
	if(!created_from)
		created_from = new /obj/item/stack/sheet/mineral/gold(src)

	if(isstack(created_from) && !created_from.material_stats)
		var/obj/item/stack/stack = created_from
		create_stats_from_material(stack.material_type)
	else
		create_stats_from_material_stats(created_from.material_stats)

	if(material_stats.thermal <= 50)
		resistance_flags |= FIRE_PROOF
	if(material_stats.thermal <= 20)
		resistance_flags |= LAVA_PROOF

	name = "unfinished [material_stats.material_name] [base_name]"

/obj/item/smithed_part/update_name(updates)
	. = ..()
	if(smithed_quality < 100)
		name = "[material_stats.material_name] [base_name]"
	else
		name = "flawless [material_stats.material_name] [base_name]"

/obj/item/smithed_part/weapon_part
	var/complete = FALSE
	var/hilt_icon_state
	var/left_weapon_inhand = 'icons/modules/smithing/forge_weapon_l.dmi'
	var/right_weapon_inhand = 'icons/modules/smithing/forge_weapon_r.dmi'
	var/weapon_inhand_icon_state
	var/hilt_icon
	var/weapon_name

/obj/item/smithed_part/weapon_part/examine(mob/user)
	. = ..()
	var/list/text_adds = forge_text()
	if(text_adds)
		. += text_adds
	if(!complete)
		. += "It's not finished yet."

///Shows when you inspect an anvil with it, make sure to update anvil proc cool_text for anvil runechat!
/obj/item/smithed_part/weapon_part/proc/forge_text()
	. = null
	if(complete)
		return
	switch(hit_counter)
		if(35 to INFINITY)
			. = "Looks like it's freshly heated, ready for hammering."
		if(25 to 34)
			. = "Still hot, plenty of work able to be done."
		if(15 to 24)
			. = "Rather hot, but it's starting to cool down."
		if(5 to 14)
			. = "Its almost cooled too much, it will need heated soon."
		if(4)
			. = "Just a few more hits till its perfect..."
		if(3)
			. = "Almost perfect, just a liiiitle more..."
		if(2)
			. = "Just a two more..."
		if(1)
			. = "One more hit for good measure."
		if(0)
			if(hits_left >= 1)
				. = "Perfect, ready to be re-heated"
			else
				. = "Perfect, ready to be finished in an Assembly Bench."
		if(-INFINITY to -1)
			if(hits_left >= 1)
				. = "Oh, its cold, I should probably stop hitting it and re-heat it..."
			else
				. = "Oh, its cold, I think I should stop hitting it and finish it..."

/obj/item/smithed_part/weapon_part/update_name(updates)
	. = ..()
	if(complete)
		if(smithed_quality < 100)
			name = "[material_stats.material_name] [weapon_name]"
		else
			name = "flawless [material_stats.material_name] [weapon_name]"

/obj/item/smithed_part/weapon_part/update_overlays()
	. = ..()
	if(complete)
		. += mutable_appearance(hilt_icon, hilt_icon_state, appearance_flags = KEEP_APART)

/obj/item/smithed_part/weapon_part/proc/finish_weapon()
	smithed_quality = max(smithed_quality, 0)
	complete = TRUE

	hit_counter = 0
	hits_left = 0

	inhand_icon_state = weapon_inhand_icon_state
	lefthand_file = left_weapon_inhand
	righthand_file = right_weapon_inhand
	update_appearance()

	name = "[material_stats.material_name] [base_name]"
	var/damage_state
	desc = finished_desc
	switch(smithed_quality)
		if(0 to 24)
			damage_state = "damage-4"
			desc += " It looks of poor quality... Quality:[smithed_quality]"
		if(25 to 49)
			damage_state = "damage-3"
			desc += " It looks slightly under average. Quality:[smithed_quality]"
		if(50 to 59)
			damage_state = "damage-2"
			desc += " It looks pretty average quality. Quality:[smithed_quality]"
		if(60 to 89)
			damage_state = "damage-1"
			desc += " It looks well forged! Quality:[smithed_quality]"
		if(90 to 99)
			damage_state = null
			desc += " It looks about as perfect as can be! Quality:[smithed_quality]"
		if(100 to 125)
			damage_state = null
			desc += " It's utterly flawless! Quality:[smithed_quality]"

	if(damage_state)
		add_filter("damage_filter", 1, alpha_mask_filter(icon = icon('icons/modules/smithing/forge_items.dmi', damage_state), flags = MASK_INVERSE))
	if(material_stats)
		for(var/datum/material_trait/trait as anything in material_stats.material_traits)
			var/datum/material_trait/newtrait = new trait.type
			//Why are we calling this here? Because we modify force and other stats that are normally in init
			newtrait.post_parent_init(src)
	update_name()

/datum/export/smithed_part
	unit_name = "smithed good"
	k_elasticity = 0
	export_types = list(/obj/item/smithed_part,/obj/item/clothing/smithed_clothes)
	cost = 1

/datum/export/smithed_part/get_cost(obj/item/smithed_part/O, apply_elastic)
	var/total_val = round(CARGO_CRATE_VALUE * (O.smithed_quality / 100))
	if(istype(O,/obj/item/smithed_part/weapon_part))
		var/obj/item/smithed_part/weapon_part/weap = O
		if(weap.complete)
			total_val += round(CARGO_CRATE_VALUE * 0.75)
	if(O.material_stats)
		for(var/datum/material_trait/trait in O.material_stats.material_traits)
			total_val += trait.value_bonus
	return round(((O.material_stats.density + O.material_stats.hardness)/5) + total_val)
