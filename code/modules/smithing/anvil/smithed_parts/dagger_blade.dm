/obj/item/smithed_part/weapon_part/dagger_blade
	icon_state = "daggerblade"
	base_name = "dagger blade"
	weapon_name = "dagger"

	finished_desc = "A forged dagger, made for throwing. Not great in the hand."

	weapon_inhand_icon_state = "dagger"
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "dagger-hilt"

/obj/item/smithed_part/weapon_part/dagger_blade/finish_weapon()
	tool_behaviour = TOOL_KNIFE
	sharpness = SHARP_POINTY
	embed_type = /datum/embedding/dagger_blade
	armour_penetration = 35 * (smithed_quality / 100)

	attack_speed = CLICK_CD_FAST_MELEE

	wound_bonus = -5 //aint cutting shit
	bare_wound_bonus = 20 //Unless you are unarmored.

	throwforce = floor(((material_stats.density + material_stats.hardness) / 7.5) * (smithed_quality * 0.01))
	force = floor(throwforce * 0.2)
	w_class = WEIGHT_CLASS_SMALL
	..()

/datum/embedding/dagger_blade
	embed_chance = 65
	pain_mult = 4
	fall_chance = 10
	ignore_throwspeed_threshold = TRUE
