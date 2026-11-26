///how much charge we give off to cells around us when rubbed
#define FESTIVUS_RECHARGE_VALUE (0.075 * STANDARD_CELL_CHARGE)

/mob/living/basic/festivus
	name = "festivus pole"
	desc = "Serenity now... SERENITY NOW!"
	icon = 'icons/obj/fluff/flora/pinetrees.dmi'
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	health_doll_icon = "festivus_pole"
	gender = NEUTER
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH

	response_help_continuous = "rubs"
	response_help_simple = "rub"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	base_pixel_x = -16

	speed = 1
	maxHealth = 200
	health = 200
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_HOSTILE)
	speak_emote = list("polls")

	death_message = "is hacked into pieces!"

	ai_controller = /datum/ai_controller/basic_controller/festivus_pole

	///how much charge we give off to cells around us when rubbed
	var/recharge_value = 75 KILO JOULES

/mob/living/basic/festivus/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	var/static/list/death_loot = list(/obj/item/stack/rods)
	AddElement(/datum/element/death_drops, death_loot)
	AddComponent(/datum/component/aggro_emote, emote_list = string_list(list("growls")), emote_chance = 20)
	var/datum/action/cooldown/mob_cooldown/charge_apc/charge_ability = new(src)
	charge_ability.Grant(src)
	ai_controller.set_blackboard_key(BB_FESTIVE_APC, charge_ability)

/datum/ai_controller/basic_controller/festivus_pole
	behavior_tree_json = "code/modules/mob/living/basic/festivus_pole.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // APCs
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/mob/living/basic/festivus/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.istate & ISTATE_HARM)
		return
	visible_message(span_warning("[src] crackles with static electricity!"))
	for(var/atom/affected in range(2, get_turf(src)))
		if(istype(affected, /obj/item/stock_parts/power_store/cell))
			var/obj/item/stock_parts/power_store/cell/cell = affected
			cell.give(FESTIVUS_RECHARGE_VALUE)
			cell.update_appearance()
		if(istype(affected, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/robot = affected
			if(robot.cell)
				robot.cell.give(FESTIVUS_RECHARGE_VALUE)
		if(istype(affected, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc_target = affected
			if(apc_target.cell)
				apc_target.cell.give(FESTIVUS_RECHARGE_VALUE)

#undef FESTIVUS_RECHARGE_VALUE
