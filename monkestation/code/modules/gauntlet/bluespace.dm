//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/obj/item/badmin_stone/bluespace
	name = "Bluespace Stone"
	desc = "Stare into the abyss, and the abyss stares back..."
	color = "#266ef6"
	stone_type = BLUESPACE_STONE
	ability_text = list(
		"HELP INTENT: Teleport target to safe location. Only works every 75 seconds.",
		"DISARM INTENT: Steal item someone is holding.",
		"HARM INTENT: Teleport to specified location."
	)
	spell_types = list(
		/datum/action/cooldown/spell/infinity/bluespace_stone_shield,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/bluespace_stone
	)
	var/next_help = 0

/obj/item/badmin_stone/bluespace/disarm_act(atom/target, mob/user, proximity_flag)
	if(isliving(target))
		var/mob/living/living_target = target
		var/obj/target_object = living_target.get_active_held_item()
		if(target_object && !istype(target_object, /obj/item/badmin_stone) && !istype(target_object, /obj/item/badmin_gauntlet) && living_target.dropItemToGround(target_object))
			living_target.visible_message(span_danger("[living_target]'s [target_object] disappears from their hands!"), span_danger("Our [target_object] disappears!"))
			target_object.forceMove(get_turf(user))
			user.equip_to_slot(target_object, ITEM_SLOT_BACKPACK)
			user.changeNext_move(CLICK_CD_CLICK_ABILITY)

/obj/item/badmin_stone/bluespace/help_act(atom/target, mob/user, proximity_flag)
	if(next_help > world.time)
		to_chat(span_danger("You need to wait [DisplayTimeText(next_help - world.time)] to do that again!"))
		return
	if(proximity_flag && isliving(target))
		if(do_after(user, 25, target = target))
			target.visible_message(span_danger("[target] warps away!"), span_notice("We warp [target == user ? "ourselves" : target] to a safe location."))
			var/turf/potential_T = find_safe_turf(extended_safety_checks = TRUE)
			do_teleport(target, potential_T, channel = TELEPORT_CHANNEL_BLUESPACE)
			next_help = world.time + 75 SECONDS

/obj/item/badmin_stone/bluespace/harm_act(atom/target, mob/user, proximity_flag)
	var/turf/to_teleport = get_turf(target)
	if(do_after(user, 3, target = user))
		var/turf/start = get_turf(user)
		if(isliving(user))
			var/mob/living/living_user = user
			living_user.stamina.adjust(-15)
		user.visible_message(span_danger("[user] warps away!"), span_notice("We warp ourselves to our desired location."))
		user.forceMove(to_teleport)
		start.Beam(to_teleport, "bsa_beam", time=25)
		user.changeNext_move(CLICK_CD_CLICK_ABILITY)


/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/infinity/bluespace_stone_shield
	name = "Bluespace Stone: Portal Shield"
	desc = "Summon a portal shield which sends all projectiles into nullspace. Lasts for 15 seconds, or 5 hits."
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "bluespace"
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/infinity/bluespace_stone_shield/cast(atom/cast_on)
	. = ..()
	var/obj/item/shield/bluespace_stone/bluespace_shield = new
	if(isliving(cast_on))
		var/mob/living/living_caster = cast_on
		if(living_caster.put_in_hands(bluespace_shield, TRUE))
			living_caster.visible_message(span_danger("A portal manifests in [cast_on]'s hands!"))

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/bluespace_stone
	name = "Bluespace Stone: Bluespace Jaunt"
	spell_requirements = NONE
	antimagic_flags = NONE
	jaunt_duration = 100
	invocation_type = INVOCATION_NONE
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "bluespace"

/////////////////////////////////////////////
/////////////////// ITEMS ///////////////////
/////////////////////////////////////////////

/obj/item/shield/bluespace_stone
	name = "bluespace energy shield"
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	icon = 'monkestation/icons/obj/infinity.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/shields_righthand.dmi'
	icon_state = "portalshield"
	worn_icon_state = "portalshield"
	inhand_icon_state = "portalshield"
	var/hits = 0

/obj/item/shield/bluespace_stone/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLUESPACE_STONE_TRAIT)
	QDEL_IN(src, 150)

/obj/item/shield/bluespace_stone/IsReflect()
	return TRUE

/obj/item/shield/bluespace_stone/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	hits += 1
	if(hits > 5)
		to_chat(owner, span_danger("[src] disappears!"))
		qdel(src)
	return FALSE
