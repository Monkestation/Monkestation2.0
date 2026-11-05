/obj/item/var/stamina_cost = 0

/obj/item/smithed_part
	name = "generic smithed item"
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

	///what its made of
	var/datum/material_stats/made_of
	///Quality, autoset from minigame.
	var/smithed_quality = 100
	///What is base desc when finished and assembled?
	var/finished_desc = "A forged item."

/obj/item/smithed_part/Initialize(mapload, obj/item/created_from, quality)
	. = ..()

	smithed_quality = max(quality, 5)

	if(!created_from)
		created_from = new /obj/item/stack/sheet/mineral/gold(src)


	if(isstack(created_from) && !created_from.material_stats)
		var/obj/item/stack/stack = created_from
		create_stats_from_material(stack.material_type)
	else
		create_stats_from_material_stats(created_from.material_stats)

	name = "[material_stats.material_name] [base_name]"
	made_of = material_stats
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

	if(material_stats.thermal <= 50)
		resistance_flags |= FIRE_PROOF
	if(material_stats.thermal <= 20)
		resistance_flags |= LAVA_PROOF

	if(damage_state)
		add_filter("damage_filter", 1, alpha_mask_filter(icon = icon('icons/modules/smithing/forge_items.dmi', damage_state), flags = MASK_INVERSE))


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
	complete = TRUE
	inhand_icon_state = weapon_inhand_icon_state
	lefthand_file = left_weapon_inhand
	righthand_file = right_weapon_inhand
	update_appearance()
	if(material_stats)
		for(var/datum/material_trait/trait as anything in material_stats.material_traits)
			var/datum/material_trait/newtrait = new trait.type
			//Why are we calling this here? Because we modify force and other stats that are normally in init
			newtrait.post_parent_init(src)

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
	if(O.made_of)
		for(var/datum/material_trait/trait in O.made_of.material_traits)
			total_val += trait.value_bonus
	return round(((O.made_of.density + O.made_of.hardness)/5) + total_val)
