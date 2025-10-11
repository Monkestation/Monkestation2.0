// Deprecated, you do not need to use this type for melee weapons.
/obj/item/melee
	item_flags = NEEDS_PERMIT

/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon = 'icons/obj/weapons/whip.dmi'
	icon_state = "chain"
	inhand_icon_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 1
	pain_damage = 12
	throwforce = 7
	demolition_mod = 0.25
	wound_bonus = 15
	bare_wound_bonus = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	attack_verb_simple = list("flog", "whip", "lash", "discipline")
	hitsound = 'sound/weapons/chainhit.ogg'
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/melee/chainofcommand/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/melee/synthetic_arm_blade
	name = "synthetic arm blade"
	desc = "A grotesque blade that on closer inspection seems to be made out of synthetic flesh, it still feels like it would hurt very badly as a weapon."
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED

/obj/item/melee/synthetic_arm_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 6 SECONDS, \
	effectiveness = 80, \
	)
	//very imprecise

/obj/item/melee/sabre
	name = "officer's sabre"
	desc = "An elegant weapon, its monomolecular edge is capable of cutting through flesh and bone with ease."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "sabre"
	inhand_icon_state = "sabre"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 20 // MONKESTATION EDIT ORG 15
	throwforce = 10
	demolition_mod = 0.75 //but not metal
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	block_sound = 'sound/weapons/parry.ogg'
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	wound_bonus = 5 // MONKESTATION EDIT ORG 10
	bare_wound_bonus = 20 // MONKESTATION EDIT ORG 25

/obj/item/melee/sabre/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 3 SECONDS, \
	effectiveness = 95, \
	bonus_modifier = 5, \
	)
	//fast and effective, but as a sword, it might damage the results.

/obj/item/melee/sabre/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/melee/sabre/on_exit_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/sabre = container.real_location
	if(istype(sabre))
		playsound(sabre, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/sabre/on_enter_storage(datum/storage/container)
	var/obj/item/storage/belt/sabre/sabre = container.real_location
	if(istype(sabre))
		playsound(sabre, 'sound/items/sheath.ogg', 25, TRUE)

/obj/item/melee/sabre/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to cut off all [user.p_their()] limbs with [src]! it looks like [user.p_theyre()] trying to commit suicide!"))
	var/i = 0
	ADD_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)
	if(iscarbon(user))
		var/mob/living/carbon/Cuser = user
		var/obj/item/bodypart/holding_bodypart = Cuser.get_holding_bodypart_of_item(src)
		var/list/limbs_to_dismember
		var/list/arms = list()
		var/list/legs = list()
		var/obj/item/bodypart/bodypart

		for(bodypart in Cuser.bodyparts)
			if(bodypart == holding_bodypart)
				continue
			if(bodypart.body_part & ARMS)
				arms += bodypart
			else if (bodypart.body_part & LEGS)
				legs += bodypart

		limbs_to_dismember = arms + legs
		if(holding_bodypart)
			limbs_to_dismember += holding_bodypart

		var/speedbase = abs((4 SECONDS) / limbs_to_dismember.len)
		for(bodypart in limbs_to_dismember)
			i++
			addtimer(CALLBACK(src, PROC_REF(suicide_dismember), user, bodypart), speedbase * i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), (5 SECONDS) * i)
	return MANUAL_SUICIDE

/obj/item/melee/sabre/proc/suicide_dismember(mob/living/user, obj/item/bodypart/affecting)
	if(!QDELETED(affecting) && !(affecting.bodypart_flags & BODYPART_UNREMOVABLE) && affecting.owner == user && !QDELETED(user))
		playsound(user, hitsound, 25, TRUE)
		affecting.dismember(BRUTE)
		user.adjustBruteLoss(20)

/obj/item/melee/sabre/proc/manual_suicide(mob/living/user, originally_nodropped)
	if(!QDELETED(user))
		user.adjustBruteLoss(200)
		user.death(FALSE)
	REMOVE_TRAIT(src, TRAIT_NODROP, SABRE_SUICIDE_TRAIT)

/obj/item/melee/beesword
	name = "The Stinger"
	desc = "Taken from a giant bee and folded over one thousand times in pure honey. Can sting through anything."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "beesword"
	inhand_icon_state = "stinger"
	worn_icon_state = "stinger"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	throwforce = 10
	attack_speed = CLICK_CD_RAPID
	block_chance = 20
	armour_penetration = 100
	attack_verb_continuous = list("slashes", "stings", "prickles", "pokes")
	attack_verb_simple = list("slash", "sting", "prickle", "poke")
	hitsound = 'sound/weapons/rapierhit.ogg'
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/beesword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight, and also you aren't going to really block someone full body tackling you with a sword
	return ..()

/obj/item/melee/beesword/afterattack(atom/target, mob/user, click_parameters)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/toxin, 4)

/obj/item/melee/beesword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is stabbing [user.p_them()]self in the throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(get_turf(src), hitsound, 75, TRUE, -1)
	return TOXLOSS

/obj/item/melee/supermatter_sword
	name = "supermatter sword"
	desc = "In a station full of bad ideas, this might just be the worst."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "supermatter_sword"
	inhand_icon_state = "supermatter_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	force = 0.001
	armour_penetration = 1000
	force_string = "INFINITE"
	item_flags = NEEDS_PERMIT|NO_BLOOD_ON_ITEM
	var/obj/machinery/power/supermatter_crystal/shard
	var/balanced = 1

/obj/item/melee/supermatter_sword/Initialize(mapload)
	. = ..()
	shard = new /obj/machinery/power/supermatter_crystal(src)
	qdel(shard.countdown)
	shard.countdown = null
	START_PROCESSING(SSobj, src)
	visible_message(span_warning("[src] appears, balanced ever so perfectly on its hilt. This isn't ominous at all."))
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(eat_bullets))

/obj/item/melee/supermatter_sword/process()
	if(balanced || throwing || ismob(src.loc) || isnull(src.loc))
		return
	if(!isturf(src.loc))
		var/atom/target = src.loc
		forceMove(target.loc)
		consume_everything(target)
	else
		var/turf/turf = get_turf(src)
		if(!isspaceturf(turf))
			consume_turf(turf)

/obj/item/melee/supermatter_sword/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(.)
		return .

	if(A == user)
		user.dropItemToGround(src, TRUE)
	else
		user.do_attack_animation(A)
	consume_everything(A)
	return TRUE

/obj/item/melee/supermatter_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(ismob(hit_atom))
		var/mob/mob = hit_atom
		if(src.loc == mob)
			mob.dropItemToGround(src, TRUE)
	consume_everything(hit_atom)

/obj/item/melee/supermatter_sword/pickup(user)
	..()
	balanced = 0

/obj/item/melee/supermatter_sword/ex_act(severity, target)
	visible_message(
		span_danger("The blast wave smacks into [src] and rapidly flashes to ash."),
		span_hear("You hear a loud crack as you are washed with a wave of heat.")
	)
	consume_everything()

/obj/item/melee/supermatter_sword/acid_act()
	visible_message(span_danger("The acid smacks into [src] and rapidly flashes to ash."),\
	span_hear("You hear a loud crack as you are washed with a wave of heat."))
	consume_everything()
	return TRUE

/obj/item/melee/supermatter_sword/proc/eat_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	visible_message(
		span_danger("[hitting_projectile] smacks into [source] and rapidly flashes to ash."),
		null,
		span_hear("You hear a loud crack as you are washed with a wave of heat."),
	)
	consume_everything(hitting_projectile)
	return COMPONENT_BULLET_BLOCKED

/obj/item/melee/supermatter_sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] touches [src]'s blade. It looks like [user.p_theyre()] tired of waiting for the radiation to kill [user.p_them()]!"))
	user.dropItemToGround(src, TRUE)
	shard.Bumped(user)

/obj/item/melee/supermatter_sword/proc/consume_everything(target)
	if(isnull(target))
		shard.Bump(target)
	else if(!isturf(target))
		shard.Bumped(target)
	else
		consume_turf(target)

/obj/item/melee/supermatter_sword/proc/consume_turf(turf/turf)
	var/oldtype = turf.type
	var/turf/newT = turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	if(newT.type == oldtype)
		return
	playsound(turf, 'sound/effects/supermatter.ogg', 50, TRUE)
	turf.visible_message(
		span_danger("[turf] smacks into [src] and rapidly flashes to ash."),
		span_hear("You hear a loud crack as you are washed with a wave of heat."),
	)
	shard.Bump(turf)

/obj/item/melee/roastingstick
	name = "advanced roasting stick"
	desc = "A telescopic roasting stick with a miniature shield generator designed to ensure entry into various high-tech shielded cooking ovens and firepits."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "roastingstick"
	inhand_icon_state = null
	worn_icon_state = "tele_baton"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 0
	attack_verb_continuous = list("hits", "pokes")
	attack_verb_simple = list("hit", "poke")
	/// The sausage attatched to our stick.
	var/obj/item/held_sausage
	/// Static list of things our roasting stick can interact with.
	var/static/list/ovens
	// Static list of things we can put on our roasting stick
	var/static/list/roastables
	/// The beam that links to the oven we use
	var/datum/beam/beam

/obj/item/melee/roastingstick/Initialize(mapload)
	. = ..()
	if (!ovens)
		ovens = typecacheof(list(/obj/singularity, /obj/energy_ball, /obj/machinery/power/supermatter_crystal, /obj/structure/bonfire, /obj/machinery/power/shuttle_engine/propulsion))
	if (!roastables)
		roastables = typecacheof(list(/obj/item/food, /obj/item/gun/ballistic, /obj/item/gun/energy, /obj/item/toy/plush))
	AddComponent( \
		/datum/component/transforming, \
		hitsound_on = hitsound, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_PRE_TRANSFORM, PROC_REF(attempt_transform))
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_PRE_TRANSFORM].
 *
 * If there is a sausage attached, returns COMPONENT_BLOCK_TRANSFORM.
 */
/obj/item/melee/roastingstick/proc/attempt_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(held_sausage)
		to_chat(user, span_warning("You can't retract [src] while [held_sausage] is attached!"))
		return COMPONENT_BLOCK_TRANSFORM

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback on stick extension.
 */
/obj/item/melee/roastingstick/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	inhand_icon_state = active ? "nullrod" : null
	if(user)
		balloon_alert(user, "[active ? "extended" : "collapsed"] [src]")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/roastingstick/attackby(atom/target, mob/user)
	..()
	if (is_type_in_typecache(target, roastables))
		if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
			to_chat(user, span_warning("You must extend [src] to attach anything to it!"))
			return
		if (held_sausage)
			to_chat(user, span_warning("[held_sausage] is already attached to [src]!"))
			return
		if (HAS_TRAIT(target, TRAIT_NODROP) || (target.resistance_flags & INDESTRUCTIBLE))
			to_chat(user, span_warning("You don't feel it would be wise to put [target] on [src]..."))
			return
		if (user.transferItemToLoc(target, src))
			held_sausage = target
		else
			to_chat(user, span_warning("[target] doesn't seem to want to get on [src]!"))
	update_appearance()

/obj/item/melee/roastingstick/attack_hand(mob/user, list/modifiers)
	if (held_sausage && loc == user && user.is_holding(src))
		user.put_in_hands(held_sausage)
		held_sausage = null
		update_appearance()
		return
	..()

/obj/item/melee/roastingstick/update_overlays()
	. = ..()
	if(held_sausage)
		//. += mutable_appearance(icon, "roastingstick_sausage")
		var/mutable_appearance/roastableicon = mutable_appearance(held_sausage.icon,held_sausage.icon_state)
		roastableicon.copy_overlays(held_sausage)
		roastableicon.transform = roastableicon.transform.Turn(45)
		roastableicon.transform = roastableicon.transform.Translate(14, 14)
		roastableicon.transform = roastableicon.transform.Scale(0.8, 0.8)
		roastableicon.color = held_sausage.color
		. += roastableicon

/obj/item/melee/roastingstick/handle_atom_del(atom/target)
	if (target == held_sausage)
		held_sausage = null
		update_appearance()

/obj/item/melee/roastingstick/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return NONE
	if (!is_type_in_typecache(interacting_with, ovens))
		return NONE
	if ((istype(interacting_with, /obj/singularity) || istype(interacting_with, /obj/energy_ball)) && get_dist(user, interacting_with) < 10)
		to_chat(user, span_notice("You send [held_sausage] towards [interacting_with]."))
		playsound(src, 'sound/items/rped.ogg', 50, TRUE)
		beam = user.Beam(interacting_with, icon_state = "rped_upgrade", time = 10 SECONDS)
		finish_roasting(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/melee/roastingstick/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return NONE
	if (!is_type_in_typecache(interacting_with, ovens))
		return NONE
	to_chat(user, span_notice("You extend [src] towards [interacting_with]."))
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	finish_roasting(user, interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/melee/roastingstick/proc/finish_roasting(mob/user, atom/target)
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_ROASTING_STICK))
		return
	if(!do_after(user, 10 SECONDS, target = user, interaction_key = DOAFTER_SOURCE_ROASTING_STICK) || !held_sausage)
		QDEL_NULL(beam)
		playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
		to_chat(user, span_notice("You put [src] away."))
		return

	if(istype(held_sausage, /obj/item/gun))
		var/obj/item/gun/roastedgun = held_sausage
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
			to_chat(user, span_warning("You feel like \the [roastedgun] on [src] might accidentally hurt someone and put it away."))
			return
		if(roastedgun.can_shoot())
			to_chat(user, span_warning("\The [roastedgun] suddenly fires off a shot."))
			INVOKE_ASYNC(roastedgun, TYPE_PROC_REF(/obj/item/gun, process_fire), user, user, FALSE, zone_override=BODY_ZONE_PRECISE_GROIN)
	if(IS_EDIBLE(held_sausage))
		var/datum/component/grillable/grill_comp = held_sausage.GetComponent(/datum/component/grillable)
		if(grill_comp?.positive_result)
			grill_comp.current_cook_time += 10 SECONDS
			if(grill_comp.current_cook_time >= grill_comp.required_cook_time)
				var/atom/grilled_result = new grill_comp.cook_result(held_sausage.loc)
				if(held_sausage.custom_materials)
					grilled_result.set_custom_materials(held_sausage.custom_materials)
				if(IS_EDIBLE(grilled_result))
					BLACKBOX_LOG_FOOD_MADE(grilled_result)
				if(user.mind)
					ADD_TRAIT(grilled_result, TRAIT_FOOD_CHEF_MADE, REF(user.mind))
				qdel(held_sausage)
				held_sausage = grilled_result
		held_sausage.reagents?.add_reagent(/datum/reagent/consumable/char, 0.5)
		held_sausage.reagents?.add_reagent(/datum/reagent/consumable/nutriment, 1)
	to_chat(user, span_notice("You finish roasting [held_sausage]."))
	playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
	held_sausage.add_atom_colour(rgb(103, 63, 24), FIXED_COLOUR_PRIORITY)
	held_sausage.name = "[target.name]-roasted [held_sausage.name]"
	held_sausage.desc = "[held_sausage.desc] It has been cooked to perfection on \a [target]."
	update_appearance()

/obj/item/melee/cleric_mace
	name = "cleric mace"
	desc = "The grandson of the club, yet the grandfather of the baseball bat. Most notably used by holy orders in days past."
	icon = 'icons/obj/weapons/cleric_mace.dmi'
	icon_state = "default"
	inhand_icon_state = "default"
	worn_icon_state = "default_worn"

	greyscale_config = /datum/greyscale_config/cleric_mace
	greyscale_config_inhand_left = /datum/greyscale_config/cleric_mace_lefthand
	greyscale_config_inhand_right = /datum/greyscale_config/cleric_mace_righthand
	greyscale_config_worn = /datum/greyscale_config/cleric_mace
	greyscale_colors = "#FFFFFF"

	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_AFFECT_STATISTICS //Material type changes the prefix as well as the color.
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*6)  //Defaults to an Iron Mace.
	slot_flags = ITEM_SLOT_BELT
	force = 14
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 8
	block_chance = 10
	block_sound = 'sound/weapons/genhit.ogg'
	armour_penetration = 75
	attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
	attack_verb_simple = list("smack", "strike", "crack", "beat")
