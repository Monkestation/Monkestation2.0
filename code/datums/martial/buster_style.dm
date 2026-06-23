#define STATUS_EFFECT_DOUBLEDOWN	/datum/status_effect/doubledown
#define BUSTER_SOURCE	"buster_source"
#define BUSTER_STUN_DURATION	0.3 SECONDS
#define GRAPPLE_DRAG_TIME	1.2 SECONDS
#define BUSTER_COLOR "#00B6FF"

/datum/martial_art/buster_style
	name = "Buster Style"
	id = MARTIALART_BUSTERSTYLE
	help_verb = /mob/living/carbon/human/proc/buster_style_help

	var/datum/action/cooldown/spell/touch/buster/slam/slam_action = new()
	var/datum/action/cooldown/spell/touch/buster/grapple/grapple_action = new()
	var/datum/action/cooldown/mob_cooldown/charge/buster_mop/mop_action = new()
	var/datum/action/cooldown/spell/conjure_item/buster_wire/wire_action = new()
	var/datum/action/cooldown/spell/touch/buster/megabuster/megabuster_action = new()

	/// Used to check which arm this martial art is connected to
	var/arm_index

/datum/martial_art/buster_style/teach(mob/living/carbon/owner, make_temporary = FALSE, arm_index)
	if(!istype(owner))
		return FALSE
	. = ..()
	if(!.)
		return
	src.arm_index = arm_index
	to_chat(owner, span_userdanger("You know the arts of [name]!"))
	slam_action.Grant(owner)
	slam_action.arm_index = arm_index
	grapple_action.Grant(owner)
	grapple_action.arm_index = arm_index
	mop_action.Grant(owner)
	mop_action.arm_index = arm_index
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED_SECONDARY, PROC_REF(on_secondary_attack))
	wire_action.Grant(owner)
	wire_action.arm_index = arm_index
	megabuster_action.Grant(owner)
	megabuster_action.arm_index = arm_index

	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, type)
	var/datum/species/owner_species = owner.dna?.species
	if(owner_species)
		owner_species.no_equip_flags |= ITEM_SLOT_GLOVES
		owner_species.update_no_equip_flags(owner, owner_species.no_equip_flags)

/datum/martial_art/buster_style/on_remove(mob/living/carbon/owner)
	to_chat(owner, span_userdanger("You suddenly forget the arts of [name]..."))
	slam_action.Remove(owner)
	grapple_action.Remove(owner)
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_RANGED_SECONDARY)
	mop_action.Remove(owner)
	wire_action.Remove(owner)
	megabuster_action.Remove(owner)

	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, type)
	var/datum/species/owner_species = owner.dna?.species
	if(owner_species)
		owner_species.no_equip_flags &= ~ITEM_SLOT_GLOVES
		owner_species.update_no_equip_flags(owner, owner_species.no_equip_flags)

	return ..()

/datum/martial_art/buster_style/can_use(mob/living/L)
	. = ..()
	var/obj/item/bodypart/limb = get_prefered_attacking_limb(L)
	if(!limb || limb.bodypart_disabled)
		return FALSE

/datum/martial_art/buster_style/get_prefered_attacking_limb(mob/living/martial_artist, mob/living/target)
	return martial_artist.get_bodypart(arm_index % 2 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)

/datum/martial_art/buster_style/harm_act(mob/living/attacker, mob/living/defender)
	if(!(attacker.istate & ISTATE_HARM))
		return ..()
	if(slam_action.Trigger() && slam_action.attached_hand?.interact_with_atom(defender, attacker))
		return MARTIAL_ATTACK_SUCCESS
	qdel(slam_action.attached_hand)
	return MARTIAL_ATTACK_FAIL

/datum/martial_art/buster_style/disarm_act(mob/living/attacker, mob/living/defender)
	if(!(attacker.istate & ISTATE_HARM))
		return ..()
	if(attacker == defender)
		if(wire_action.Trigger())
			return MARTIAL_ATTACK_SUCCESS
		return MARTIAL_ATTACK_FAIL
	if(grapple_action.attached_hand || grapple_action.Trigger())
		grapple_action.attached_hand?.interact_with_atom(defender, attacker)
		return MARTIAL_ATTACK_SUCCESS
	return MARTIAL_ATTACK_FAIL

/datum/martial_art/buster_style/proc/on_secondary_attack(mob/living/source, atom/attacked_atom, modifiers)
	if(!(source.istate & ISTATE_HARM))
		return
	if(mop_action.Trigger())
		return COMPONENT_CANCEL_ATTACK_CHAIN

/mob/living/carbon/human/proc/buster_style_help()
	set name = "Buster Style"
	set desc = "You mentally practice the stunts you can pull with the buster arm."
	set category = "Buster Style"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You think about what stunts you can pull with the power of a buster arm.</i></b>"

	combined_msg += "[span_notice("Slam")]: Your punch has been replaced with a slam attack that places enemies behind you and smashes them against \
	whatever person, wall, or object is there for bonus damage. Has a 0.8 second cooldown."
	combined_msg += "[span_notice("Grapple")]: Right-clicking an enemy allows you to drag them for up to [GRAPPLE_DRAG_TIME/10] seconds and throw them at a \
	target destination with left-click. Throwing them into unanchored people and objects will knock them back and deal additional damage to existing thrown \
	targets. Unanchored structures and vending machines can be tossed as well. If the target's limb is at its limit, tear it off. Has a 3 second cooldown."
	combined_msg +=  "[span_notice("Mop the Floor")]: Right-clicking away from you in a direction sends you flying forward, damaging enemies in front of you by dragging them \
	along the ground. Ramming victims into something solid does additional damage to them and the object. Has a 4 second cooldown."
	combined_msg += "[span_notice("Wire Snatch")]:By right-clicking yourself, you equip a grappling wire which can be used to move yourself or other objects. Landing a \
	shot on a person will immobilize them for 1 seconds and reel them in. Extending the wire has a 5 second cooldown."
	combined_msg +=  "[span_notice("Megabuster")]: Charge up your buster arm to put a powerful attack in the corresponding hand. The energy only lasts 5 seconds \
	but does hefty damage to its target, even breaking walls down when hitting things into them or connecting the attack directly. \
	Attacking a living target sends them flying and dismembers their limb if its damaged enough. Has a 15 second cooldown."

	combined_msg += span_warning("You can't perform any of the moves if you have an occupied hand. Additionally, if your buster arm should become disabled, so shall your moves.")
	combined_msg += span_notice("<b>After landing an attack, you become immune to damage slowdown and all incoming damage by 25% for 2 seconds.</b>")

	to_chat(usr, boxed_message(combined_msg.Join("\n")))

/datum/action/cooldown/buster
	check_flags = AB_CHECK_HANDS_BLOCKED| AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	button_icon = 'icons/mob/actions/actions_arm.dmi'

/datum/action/cooldown/buster/IsAvailable(feedback = FALSE)
	. = ..()
	if(!isliving(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_PACIFISM))
		return FALSE

////////////////// Hand Actions //////////////////
/datum/action/cooldown/spell/touch/buster
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	button_icon = 'icons/mob/actions/actions_arm.dmi'

	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	overlay_icon_state = null
	active_overlay_icon_state = null
	panel = null
	invocation = null
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	draw_message = span_notice("Your fingers on your arm begin to tense up.")
	drop_message = span_notice("You relax your arm.")

	/// Used to check which arm this martial art is connected to
	var/arm_index
	var/hand_phrase = "begin to tense up."

/datum/action/cooldown/spell/touch/buster/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .

	var/mob/living/O = owner
	var/obj/item/bodypart/limb = O.get_bodypart(arm_index % 2 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	if(!limb || limb.bodypart_disabled)
		to_chat(owner, span_warning("Your [limb.name] isn't in a functional state right now!"))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/touch/buster/create_hand(mob/living/carbon/cast_on)
	SHOULD_CALL_PARENT(FALSE)

	var/obj/item/melee/touch_attack/new_hand = new hand_path(cast_on, src)
	if(!cast_on.put_in_hand(new_hand, arm_index))
		qdel(new_hand)
		reset_spell_cooldown()
		to_chat(cast_on, span_warning("Your [arm_index % 2 ? "left" : "right"] hand is full!"))
		return FALSE

	attached_hand = new_hand
	register_hand_signals()
	cast_on.visible_message(span_warning("The fingers on [cast_on]'s [arm_index % 2 ? "left" : "right"] buster arm [hand_phrase]"), draw_message)
	return TRUE

/datum/action/cooldown/spell/touch/buster/proc/harm(mob/living/user, atom/movable/target, damage)
	if(isliving(target))
		var/mob/living/target_living = target
		var/obj/item/bodypart/limb_to_hit = target_living.get_bodypart(user?.zone_selected)
		var/armor = target_living.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target_living.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus = CANT_WOUND)
	else
		if(target.uses_integrity)
			target.take_damage(damage)

/datum/action/cooldown/spell/touch/buster/proc/non_living_type_check(atom/thing)
	return isstructure(thing) || ismachinery(thing) || ismecha(thing)

/*---------------------------------------------------------------
	start of slam section
---------------------------------------------------------------*/
/datum/action/cooldown/spell/touch/buster/slam
	name = "Slam"
	desc = "Grab the target in front of you and slam them back onto the ground. If there's a solid \
			object or wall behind you when the move is successfully performed then the target will \
			take additional damage."
	button_icon_state = "suplex"
	cooldown_time = 0.8 SECONDS
	hand_path = /obj/item/melee/touch_attack/buster_slam
	var/slam_impact_damage = 20
	var/slam_crash_damage = 10
	var/object_crush_damage = 5

/datum/action/cooldown/spell/touch/buster/slam/can_hit_with_hand(atom/movable/victim, mob/caster)
	. = ..()
	if(!.)
		return
	if(victim.throwing)
		return FALSE

/datum/action/cooldown/spell/touch/buster/slam/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	caster.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)

	var/turf/behind = get_step(caster, get_dir(victim, caster))
	if(caster.loc == behind)
		behind = get_step(caster, REVERSE_DIR(caster.dir))
	ADD_TRAIT(caster, TRAIT_UNDENSE, BUSTER_SOURCE)
	RegisterSignal(victim, COMSIG_MOVABLE_IMPACT, PROC_REF(slam_impact))
	RegisterSignal(victim, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(slam_landed))
	victim.throw_at(behind, 2, 2, caster)
	playsound(victim,'sound/effects/meteorimpact.ogg', 60, 1)
	playsound(caster, 'sound/effects/gravhit.ogg', 20, 1)
	return TRUE

/datum/action/cooldown/spell/touch/buster/slam/proc/slam_impact(mob/living/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	var/mob/thrower = throwingdatum.thrower
	if(hit_atom == thrower)
		return
	var/found = FALSE
	if(isclosedturf(hit_atom))
		harm(thrower, source, slam_crash_damage)
		found = TRUE
	else if(isobj(hit_atom))
		harm(thrower, source, slam_crash_damage)
		harm(thrower, hit_atom, object_crush_damage)
		found = TRUE
	else if(isliving(hit_atom))
		var/mob/living/living_atom = hit_atom
		harm(null, living_atom, slam_crash_damage)
		living_atom.Knockdown(1, prevent_drop = TRUE)
		to_chat(living_atom, span_userdanger("[thrower] slams [source] into you!"))

	if(found)
		to_chat(source, span_warning("[thrower] slams you into [hit_atom]!"))
	if(QDELETED(hit_atom))
		return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/datum/action/cooldown/spell/touch/buster/slam/proc/slam_landed(mob/living/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_THROW_LANDED))
	var/mob/user = throwing_datum.thrower
	var/turf/slam_destination = get_turf(source)
	user.visible_message(span_warning("[user] turns around and slams [source] against [slam_destination]!"), ignored_mobs = list(source))
	to_chat(source, span_userdanger("[user] turns around and slams you against [slam_destination]!"))
	REMOVE_TRAIT(user, TRAIT_UNDENSE, BUSTER_SOURCE)

	// source.Knockdown(1, prevent_drop = TRUE)
	slam_destination.break_tile()
	user.face_atom(source)
	harm(user, source, slam_impact_damage)
	if(isanimal_or_basicmob(source) && source.stat == DEAD)
		source.visible_message(span_warning("[source] explodes into gore on impact!"))
		source.gib()

/obj/item/melee/touch_attack/buster_slam
	name = "slam"
	desc = "Guess who's gettin' their ass kicked!?"
	color = BUSTER_COLOR
	icon_state = "greyscale"
	inhand_icon_state = "greyscale"
/*---------------------------------------------------------------
	end of slam section
---------------------------------------------------------------*/

/*---------------------------------------------------------------
	start of grab section
---------------------------------------------------------------*/
/datum/action/cooldown/spell/touch/buster/grapple
	name = "Grapple"
	desc = "Prepare your hand for grabbing. Throw your target and inflict more damage \
			if they hit a solid object. If the targeted limb is horribly bruised, you'll \
			tear it off when throwing the victim."
	button_icon_state = "lariat"
	cooldown_time = 3 SECONDS
	hand_path = /obj/item/melee/touch_attack/buster_grapple

	/// When set, throwing the hand will throw the target
	var/datum/weakref/atom_to_throw
	var/initial_throw_damage = 15
	var/living_crash_damage = 7
	var/object_crash_damage = 50

/datum/action/cooldown/spell/touch/buster/grapple/remove_hand(mob/living/hand_owner, reset_cooldown_after)
	. = ..()
	set_atom_to_throw(null)

/datum/action/cooldown/spell/touch/buster/grapple/is_valid_target(atom/cast_on)
	return non_living_type_check(cast_on) || ..()

/datum/action/cooldown/spell/touch/buster/grapple/proc/set_atom_to_throw(atom/new_atom)
	var/atom/resolved_atom = atom_to_throw?.resolve()
	if(resolved_atom)
		if(isliving(resolved_atom))
			var/mob/living/living_thrown = resolved_atom
			if(istype(living_thrown.buckled, /obj/structure/bed/grip))
				living_thrown.buckled.unbuckle_mob(living_thrown)
			REMOVE_TRAIT(living_thrown, TRAIT_UNDENSE, BUSTER_SOURCE)
		else
			SSmove_manager.stop_looping(resolved_atom)
			if(HAS_TRAIT_FROM(resolved_atom, TRAIT_UNDENSE, BUSTER_SOURCE))
				REMOVE_TRAIT(resolved_atom, TRAIT_UNDENSE, BUSTER_SOURCE)
				resolved_atom.set_density(TRUE)
		UnregisterSignal(resolved_atom, list(COMSIG_MOVABLE_MOVED))
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	atom_to_throw = WEAKREF(new_atom)
	if(new_atom)
		RegisterSignal(new_atom, COMSIG_MOVABLE_MOVED, PROC_REF(distance_check))
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(distance_check))
		if(isliving(new_atom))
			ADD_TRAIT(new_atom, TRAIT_UNDENSE, BUSTER_SOURCE) // for the sake of noncarbons not playing nice with lying down
		else if(new_atom.density)
			ADD_TRAIT(new_atom, TRAIT_UNDENSE, BUSTER_SOURCE) // doesn't do anything but needed for restoring density
			new_atom.set_density(FALSE)

/datum/action/cooldown/spell/touch/buster/grapple/proc/distance_check(atom/movable/mover, atom/old_loc, direction)
	SIGNAL_HANDLER
	var/grappled_atom = atom_to_throw?.resolve()
	if(!grappled_atom)
		return
	if(get_dist(owner, grappled_atom) > 1)
		spell_feedback()
		remove_hand(owner)

/datum/action/cooldown/spell/touch/buster/grapple/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(non_living_type_check(victim))
		var/obj/grabbed_object = victim
		var/message = "[caster] grabs [grabbed_object]"
		// animate(I, time = 0.2 SECONDS, pixel_y = 20)
		if(grabbed_object.anchored)
			if(istype(grabbed_object, /obj/machinery/vending))
				grabbed_object.set_anchored(FALSE)
				message += " and tears it off the bolts securing it"
			else
				return
		victim.add_fingerprint(caster, FALSE)
		caster.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
		playsound(caster, 'sound/effects/servostep.ogg', 60, FALSE, -1)

		grabbed_object.visible_message(span_warning("[message]!"))
		set_atom_to_throw(grabbed_object)
		grabbed_object.forceMove(get_turf(caster))
		SSmove_manager.home_onto(grabbed_object, caster, timeout = GRAPPLE_DRAG_TIME)
	else if(isliving(victim))
		var/mob/living/living_victim = victim
		if(living_victim.anchored)
			return
		victim.add_fingerprint(caster, FALSE)
		caster.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
		playsound(caster, 'sound/effects/servostep.ogg', 60, FALSE, -1)

		var/obj/structure/bed/grip/grabbing_bed = new(get_turf(caster))
		living_victim.visible_message(span_warning("[caster] grabs [living_victim] and lifts [living_victim.p_them()] off the ground!"), \
			span_userdanger("[caster] grapples you and lifts you up into the air! Resist [caster.p_their()] grip!"))
		set_atom_to_throw(living_victim)
		grabbing_bed.buckle_mob(living_victim) //makes the victim follow with an invisible bed
		SSmove_manager.home_onto(grabbing_bed, caster)
	return FALSE

// Don't pass in damage to use crash-related damage values
/datum/action/cooldown/spell/touch/buster/grapple/harm(mob/living/user, atom/target, damage)
	if(!damage)
		if(isliving(target))
			damage = living_crash_damage
		else if(non_living_type_check(target))
			damage = object_crash_damage
	return ..()

/datum/action/cooldown/spell/touch/buster/grapple/proc/lob(mob/living/user, atom/target) //proc for throwing something you picked up with grapple
	if(!atom_to_throw?.resolve())
		return FALSE

	var/atom/movable/cached_thrown = atom_to_throw.resolve()
	set_atom_to_throw(null)
	if(get_dist(cached_thrown, user) > 1) // Can't reach the thing that was supposed to be thrown
		return TRUE

	// animate(thrown, time = 0.2 SECONDS, pixel_y = 0) //to get it back to normal since it was lifted before
	if(isliving(cached_thrown)) //throwing someone by whatever limb and ripping it off if it's hurt enough
		var/mob/living/tossedliving = cached_thrown
		ADD_TRAIT(tossedliving, TRAIT_UNDENSE, BUSTER_SOURCE) // For the sake of noncarbons not playing nice with lying down
		harm(user, tossedliving, initial_throw_damage)

		var/obj/item/bodypart/limb_to_hit = tossedliving.get_bodypart(user.zone_selected)
		if(!limb_to_hit)
			limb_to_hit = tossedliving.get_bodypart(BODY_ZONE_CHEST)
		if(!(limb_to_hit.body_zone in list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)) && limb_to_hit.get_damage() >= limb_to_hit.max_damage)
			limb_to_hit.drop_limb()
			playsound(user,	'sound/misc/desecration-01.ogg', 20, 1)
			tossedliving.visible_message(span_warning("[user] throws [tossedliving] by [limb_to_hit], severing it from [tossedliving.p_them()]!"), \
				span_userdanger("[user] tears [limb_to_hit] off!"))
			// user.put_in_hands(limb_to_hit)
		else if(limb_to_hit.body_zone == BODY_ZONE_CHEST && limb_to_hit.get_damage() >= (limb_to_hit.max_damage * 0.8)) //targetting the chest works for tail removal too but who cares
			var/obj/item/organ/tail = tossedliving.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
			if(tail)
				playsound(user, 'sound/misc/desecration-02.ogg', 20, 1)
				tossedliving.visible_message(span_warning("[user] throws [tossedliving] by [tossedliving.p_their()] tail, severing it from [tossedliving.p_them()]!"), \
					span_userdanger("[user] tears your tail off!")) //"I'm taking this back."
				tail.Remove(tossedliving)
				// user.put_in_hands(T)
	else if(cached_thrown.density)
		ADD_TRAIT(cached_thrown, TRAIT_UNDENSE, BUSTER_SOURCE) // doesn't do anything but needed for restoring density
		cached_thrown.set_density(FALSE)

	cached_thrown.visible_message(span_bolddanger("[user] throws [cached_thrown]!"), span_userdanger("[user] throws you!"))
	if(prob(5))
		user.say("+Pack it up, freakshow!+", forced = "buster fist")
	user.spin(4, 1)

	cached_thrown.SpinAnimation(0.5 SECONDS, 1)
	var/datum/move_loop/loop = SSmove_manager.throw_at(cached_thrown, target, maxrange = 7, delay = 0.01 SECONDS)
	RegisterSignal(cached_thrown, COMSIG_MOVABLE_MOVED_FROM_LOOP, PROC_REF(soar_on_moved_from_loop))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(soar_post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_qdeleted))
	soar_on_moved_from_loop(cached_thrown, loop, cached_thrown.dir, get_dir(cached_thrown, target))
	return TRUE

/datum/action/cooldown/spell/touch/buster/grapple/proc/soar_on_moved_from_loop(atom/movable/source, datum/move_loop/has_target/throw_at/loop, old_dir, direction)
	SIGNAL_HANDLER
	if(!loop.lifetime)
		return
	var/turf/next_turf = get_step(source, direction)
	for(var/atom/movable/impacted_atom in next_turf.contents)
		if(impacted_atom.move_packet || impacted_atom == owner)
			continue

		if(isliving(impacted_atom)) // If the thrown mass hits a person then they get tossed
			var/mob/living/impacted_living = impacted_atom
			harm(null, impacted_living)
			impacted_living.Knockdown(BUSTER_STUN_DURATION)
			if(impacted_atom.anchored)
				continue

			impacted_living.Immobilize(BUSTER_STUN_DURATION, ignore_canstun = TRUE)
			impacted_living.SpinAnimation(0.5 SECONDS, 1)
			ADD_TRAIT(impacted_living, TRAIT_UNDENSE, BUSTER_SOURCE)
			var/datum/move_loop/new_loop = SSmove_manager.throw_at(impacted_living, loop.target, maxrange = loop.maxrange - loop.dist_travelled, delay = 0.01 SECONDS)
			RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(soar_post_move))
			RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(loop_qdeleted))
		else if(non_living_type_check(impacted_atom)) // Scoop up obstacles if theyre not nailed down
			if(!impacted_atom.density)
				continue
			harm(null, source) // Impacting stuff hurts
			harm(null, impacted_atom)
			if(QDELETED(impacted_atom) || impacted_atom.anchored)
				continue

			impacted_atom.SpinAnimation(0.5 SECONDS, 1)
			ADD_TRAIT(impacted_atom, TRAIT_UNDENSE, BUSTER_SOURCE) // doesn't do anything but needed for restoring density
			impacted_atom.set_density(FALSE)
			var/datum/move_loop/new_loop = SSmove_manager.throw_at(impacted_atom, loop.target, maxrange = loop.maxrange - loop.dist_travelled, delay = 0.01 SECONDS)
			RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(soar_post_move))
			RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(loop_qdeleted))

/datum/action/cooldown/spell/touch/buster/grapple/proc/loop_qdeleted(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/moving = source.moving
	UnregisterSignal(moving, COMSIG_MOVABLE_MOVED_FROM_LOOP)
	if(HAS_TRAIT_FROM(moving, TRAIT_UNDENSE, BUSTER_SOURCE))
		REMOVE_TRAIT(moving, TRAIT_UNDENSE, BUSTER_SOURCE)
		if(non_living_type_check(moving))
			moving.set_density(TRUE)

/datum/action/cooldown/spell/touch/buster/grapple/proc/soar_post_move(datum/move_loop/has_target/source, result, delay)
	SIGNAL_HANDLER

	var/atom/moving = source.moving
	if(QDELETED(moving))
		return

	if(result != MOVELOOP_SUCCESS)
		if(result == MOVELOOP_FAILURE && moving.loc != source.target)
			harm(null, moving)
			if(isanimal_or_basicmob(moving))
				var/mob/living/moving_living = moving
				if(moving_living.stat == DEAD)
					moving_living.gib()
		qdel(source)
	else
		if(isliving(moving))
			var/mob/living/moved_living = moving
			moved_living.Knockdown(BUSTER_STUN_DURATION)
			moved_living.Immobilize(BUSTER_STUN_DURATION, ignore_canstun = TRUE)

/obj/item/melee/touch_attack/buster_grapple
	name = "grapple"
	desc = "Your fingers occasionally curl as if they have their own urge to dig into something."
	color = "#f14b4b"
	icon_state = "greyscale"
	inhand_icon_state = "greyscale"

/obj/item/melee/touch_attack/buster_grapple/ignition_effect(atom/A, mob/user)
	playsound(user,'sound/misc/fingersnap2.ogg', 20, 1)
	playsound(user,'sound/effects/sparks4.ogg', 20, 1)
	do_sparks(5, TRUE, src)
	. = span_rose("With a single snap, [user] sets [A] alight with sparks from [user.p_their()] metal fingers.")

/obj/item/melee/touch_attack/buster_grapple/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/action/cooldown/spell/touch/buster/grapple/hand_spell = spell_which_made_us?.resolve()
	if(!IS_WEAKREF_OF(interacting_with, hand_spell.atom_to_throw) && hand_spell.lob(user, interacting_with))
		remove_hand_with_no_refund(user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/melee/touch_attack/buster_grapple/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/action/cooldown/spell/touch/buster/grapple/hand_spell = spell_which_made_us?.resolve()
	if(hand_spell.lob(user, interacting_with))
		remove_hand_with_no_refund(user)
	return ITEM_INTERACT_SUCCESS

/// Invisible bed helper that buckles mobs to us
/obj/structure/bed/grip
	name = "buster arm"
	icon_state = ""
	can_buckle = TRUE
	density = FALSE
	/// A weakref to what spell made us.
	var/datum/weakref/spell_which_made_us
	elevation = 0

/obj/structure/bed/grip/Initialize(mapload, datum/action/cooldown/spell/spell)
	. = ..()
	if(spell)
		spell_which_made_us = WEAKREF(spell)
	QDEL_IN(src, GRAPPLE_DRAG_TIME)

/obj/structure/bed/grip/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(!has_buckled_mobs())
		return

	for(var/mob/living/possible_mob as anything in buckled_mobs)
		// Can't be accomplished under normal circumstances because it self deletes in 1.2 seconds
		if(!do_after(possible_mob, GRAPPLE_DRAG_TIME * 2, src))
			if(possible_mob?.buckled)
				to_chat(possible_mob, span_warning("You fail to free yourself!"))
			return
		if(!possible_mob.buckled)
			return
		unbuckle_mob(possible_mob)

/obj/structure/bed/grip/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	. = ..()
	if(!QDELETED(src) && !has_buckled_mobs())
		qdel(src)
/*---------------------------------------------------------------
	end of grab section
---------------------------------------------------------------*/

/*---------------------------------------------------------------
	start of mop section
---------------------------------------------------------------*/
/datum/action/cooldown/mob_cooldown/charge/buster_mop
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	transparent_when_unavailable = TRUE

	name = "Mop the Floor"
	desc = "Launch forward and drag whoever's in front of you on the ground. The \
			longer the target is dragged the more damage they are inflicted with."
	button_icon = 'icons/mob/actions/actions_arm.dmi'
	button_icon_state = "mop"
	cooldown_time = 4 SECONDS
	click_to_activate = FALSE

	charge_delay = 0
	charge_past = 4
	charge_distance = 5
	charge_speed = 0.1 SECONDS
	destroy_objects = FALSE

	charge_damage = 8
	var/living_crash_damage = 16
	var/object_crash_damage = 5

	/// Used to check which arm this martial_art is connected to
	var/arm_index

/datum/action/cooldown/mob_cooldown/charge/buster_mop/Activate(atom/target_atom)
	if(owner.get_held_items_for_side(arm_index % 2 ? LEFT_HANDS : RIGHT_HANDS))
		to_chat(owner, span_warning("Your [arm_index % 2 ? "left" : "right"] hand is full!"))
		return FALSE
	var/mob/living/O = owner
	var/obj/item/bodypart/limb = O.get_bodypart(arm_index % 2 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	if(!limb || limb.bodypart_disabled)
		to_chat(owner, span_warning("Your [limb.name] isn't in a functional state right now!"))
		return FALSE
	// target_atom is actually the user since click_to_activate = FALSE
	target_atom = get_step(target_atom, target_atom.dir)
	return ..()

/datum/action/cooldown/mob_cooldown/charge/buster_mop/do_charge_indicator(atom/charger, atom/charge_target)
	if(!isliving(charger))
		return
	var/mob/living/user = charger
	// user.visible_message(span_warning("[user] sprints forward with [user.p_their()] hand outstretched!"))
	var/obj/effect/temp_visual/decoy/decoy = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(decoy, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)
	playsound(user,'sound/effects/gravhit.ogg', 20, 1)
	user.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
	user.stop_pulling()
	if(prob(5))
		user.say("+Let's go for a walk, little chicky!+", forced = "buster fist")
	on_moved(user, get_turf(user), user.dir)

/datum/action/cooldown/mob_cooldown/charge/buster_mop/charge_end(datum/move_loop/source)
	. = ..()
	var/mob/living/charger = source.moving
	charger.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)

/datum/action/cooldown/mob_cooldown/charge/buster_mop/pre_move(datum/move_loop/has_target/source)
	. = ..()
	var/mob/moving = source.moving
	moving.face_atom(source.target)
	drag_front_under(moving)

/datum/action/cooldown/mob_cooldown/charge/buster_mop/on_moved(atom/source, atom/oldloc, movement_dir)
	var/found = FALSE
	var/turf/current_turf = get_turf(source)
	for(var/mob/living/target in current_turf.contents)
		if(target == owner)
			continue
		hit_target(source, target, charge_damage, movement_dir)
		found = TRUE

	if(found)
		playsound(source, 'sound/effects/meteorimpact.ogg', 60, TRUE)

	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source, movement_dir)

/datum/action/cooldown/mob_cooldown/charge/buster_mop/DestroySurroundings(atom/movable/charger, movement_dir)
	var/turf/next_turf = get_step(charger, movement_dir || charger.dir)
	for(var/obj/object in next_turf.contents)
		if(!object.Adjacent(charger))
			continue
		if(!ismachinery(object) && !isstructure(object))
			continue
		if(!object.density || object.IsObscured())
			continue
		if(object.uses_integrity)
			object.take_damage(object_crash_damage)

/datum/action/cooldown/mob_cooldown/charge/buster_mop/hit_target(mob/source, mob/living/target, damage_dealt, movement_dir)
	target.add_fingerprint(source, FALSE)
	var/obj/item/bodypart/limb_to_hit = target.get_bodypart(source.zone_selected)
	var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
	target.apply_damage(damage_dealt, BRUTE, limb_to_hit, armor, wound_bonus = CANT_WOUND)
	if(!movement_dir)
		return
	if(!target.Move(get_step(target, movement_dir), movement_dir))
		target.apply_damage(living_crash_damage, BRUTE, limb_to_hit, armor, wound_bonus = CANT_WOUND)

/datum/action/cooldown/mob_cooldown/charge/buster_mop/proc/drag_front_under(mob/living/charger)
	var/turf/next_turf = get_step(charger, charger.dir)
	for(var/mob/living/target in next_turf.contents)
		if(target == owner)
			continue
		if(isanimal_or_basicmob(target) && target.stat == DEAD)
			target.visible_message(span_warning("[target] is ground into paste!"))
			target.gib()
			continue
		if(!target.IsImmobilized())
			target.visible_message(span_warning("[charger] catches [target] and drags them along!"), span_userdanger("[charger] grinds you against the ground!"))
		target.add_fingerprint(charger, FALSE)
		target.Immobilize(BUSTER_STUN_DURATION, ignore_canstun = TRUE)
		target.Knockdown(BUSTER_STUN_DURATION, prevent_drop = TRUE)
/*---------------------------------------------------------------
	end of mop section
---------------------------------------------------------------*/

/*---------------------------------------------------------------
	start of wire section
---------------------------------------------------------------*/
/datum/action/cooldown/spell/conjure_item/buster_wire
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	overlay_icon_state = null
	active_overlay_icon_state = null
	panel = null
	invocation = null
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE

	name = "Wire Snatch"
	desc = "Extend a wire for reeling in foes from a distance, immobilizing them on hit. \
			Anchored targets that are hit will pull you towards them instead."
	button_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "hook"
	cooldown_time = 5 SECONDS
	item_type = /obj/item/gun/magic/hook/buster

	/// Used to check which arm this martial art is connected to
	var/arm_index

/datum/action/cooldown/spell/conjure_item/buster_wire/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .

	if(owner.get_held_items_for_side(arm_index % 2 ? LEFT_HANDS : RIGHT_HANDS))
		to_chat(owner, span_warning("Your [arm_index % 2 ? "left" : "right"] hand is full!"))
		return . | SPELL_CANCEL_CAST
	var/mob/living/O = owner
	var/obj/item/bodypart/limb = O.get_bodypart(arm_index % 2 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	if(!limb || limb.bodypart_disabled)
		to_chat(owner, span_warning("Your [limb.name] isn't in a functional state right now!"))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/conjure_item/buster_wire/post_created(mob/cast_on, obj/item/created)
	// THIS SUCKS A LOT
	cast_on.temporarilyRemoveItemFromInventory(created, force = TRUE)
	if(!cast_on.put_in_hand(created, arm_index))
		qdel(created)
		reset_spell_cooldown()
		return
	created.item_flags |= DROPDEL
	RegisterSignal(created, COMSIG_PROJECTILE_ON_HIT, PROC_REF(qdel_source))
	RegisterSignal(created, COMSIG_QDELETING, PROC_REF(upon_item_qdel))

/datum/action/cooldown/spell/conjure_item/buster_wire/proc/qdel_source(datum/source)
	SIGNAL_HANDLER
	qdel(source)

/datum/action/cooldown/spell/conjure_item/buster_wire/proc/upon_item_qdel(datum/source)
	SIGNAL_HANDLER
	StartCooldown()

/obj/item/gun/magic/hook/buster
	ammo_type = /obj/item/ammo_casing/magic/hook/buster

/obj/item/gun/magic/hook/buster/on_thrown(mob/living/carbon/user, atom/target)
	try_fire_gun(target, user)
	return

/obj/item/ammo_casing/magic/hook/buster
	projectile_type = /obj/projectile/hook/buster
	firing_effect_type = null

/obj/projectile/hook/buster
	name = "hook"
	damage = 0
	armour_penetration = 100
	range = 8
	knockdown_time = 0
	chain_iconstate = "wire"

/obj/projectile/hook/buster/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(firer))
		return
	var/mob/living/carbon/carbon_firer = firer
	carbon_firer.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
	if(isobj(target))
		var/obj/target_object = target
		if(target_object.anchored && !isitem(target_object))
			zip(carbon_firer, target)
		else
			carbon_firer.throw_mode_on()
			target_object.throw_at(carbon_firer, 8, 2, thrower = carbon_firer, gentle = TRUE)
			target_object.visible_message(span_danger("[target_object] is pulled by [carbon_firer]'s wire!"))
		return
	if(isclosedturf(target))
		zip(carbon_firer, target)

/obj/projectile/hook/buster/hooked_target_turf(mob/living/firer, mob/living/target)
	return get_step(firer, get_dir(firer, target))

/obj/projectile/hook/buster/on_movable_hit(mob/living/firer, atom/movable/target)
	target.visible_message(span_danger("[target] is snagged by [firer]'s wire!"))

/obj/projectile/hook/buster/on_living_hit(mob/living/firer, mob/living/fresh_meat)
	if(prob(5))
		firer.say("+Not so fast!+", forced = "buster fist")

	fresh_meat.Immobilize(1 SECONDS)
	var/obj/item/bodypart/limb_to_hit = fresh_meat.get_bodypart(firer.zone_selected)
	var/armor = fresh_meat.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
	fresh_meat.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
	new /datum/forced_movement(fresh_meat, hooked_target_turf(firer, fresh_meat), 5, TRUE)

/obj/projectile/hook/buster/proc/zip(mob/living/firer, atom/target)
	to_chat(firer, span_boldwarning("You pull yourself towards [target]!"))
	new /datum/forced_movement(firer, get_turf(target), 5, TRUE)

/obj/projectile/hook/buster/on_range()
	if(!QDELETED(fired_from))
		SEND_SIGNAL(fired_from, COMSIG_ITEM_MAGICALLY_CHARGED, null, null)
	return ..()
/*---------------------------------------------------------------
	end of wire section
---------------------------------------------------------------*/

/*---------------------------------------------------------------
	start of megabuster section
---------------------------------------------------------------*/
/datum/action/cooldown/spell/touch/buster/megabuster
	name = "Mega Buster"
	desc = "Put the buster arm through its paces to gain extreme power for five seconds. Connecting the blow will devastate the target and send them flying, taking others with \
	them and sending them through walls."
	button_icon_state = "ponch"
	cooldown_time = 20 SECONDS
	hand_path = /obj/item/melee/touch_attack/buster_mega
	draw_message = span_notice("Your arm begins crackling loudly!")
	hand_phrase = "begins crackling loudly!"

	var/charge_time = 2 SECONDS

	var/flight_distance = 8
	var/living_punched_damage = 30
	var/living_collision_dam = 20
	var/object_punched_damage = 200
	var/object_collision_damage = 100
	var/wall_collision_damage = 300

/datum/action/cooldown/spell/touch/buster/megabuster/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(is_action_active())
		return . | SPELL_CANCEL_CAST
	if(!do_after(cast_on, charge_time, timed_action_flags = IGNORE_USER_LOC_CHANGE, interaction_key = BUSTER_SOURCE))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/touch/buster/megabuster/create_hand(mob/living/carbon/cast_on)
	. = ..()
	if(!.)
		return
	if(prob(5))
		cast_on.say("+Power... my power!+", forced = "buster fist")

/datum/action/cooldown/spell/touch/buster/megabuster/on_hand_dropped(datum/source, mob/living/dropper)
	remove_hand(dropper, reset_cooldown_after = FALSE) // commit or lose it

/datum/action/cooldown/spell/touch/buster/megabuster/is_valid_target(atom/cast_on)
	return iswallturf(cast_on) || non_living_type_check(cast_on) || ..()

/datum/action/cooldown/spell/touch/buster/megabuster/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/movable/victim, mob/living/carbon/caster)
	. = TRUE
	caster.apply_status_effect(STATUS_EFFECT_DOUBLEDOWN)
	if(prob(5))
		caster.say(pick("+FUCK YOU!!!+", "+Jackpot!+"), forced = "buster fist")
	playsound(victim, 'sound/effects/gravhit.ogg', 60, 1)
	var/turf/victim_turf = get_turf(victim)
	new /obj/effect/temp_visual/explosion/fast(victim_turf, 4, COLOR_WHITE)
	SSexplosions.shake_the_room(victim_turf, 1, 7, 0.5, 0.25, FALSE) // make this move very loud and noticeable

	if(isliving(victim))
		var/mob/living/living_victim = victim
		harm(caster, victim, living_punched_damage)

		var/message = span_boldwarning("[caster] blasts [living_victim] with a surge of energy and sends [living_victim.p_them()] flying!")
		var/self_message = span_userdanger("[caster] hits you with a blast of energy and sends you flying!")
		var/obj/item/bodypart/limb_to_hit = living_victim.get_bodypart(caster.zone_selected)
		if(istype(limb_to_hit, /obj/item/bodypart/head))
			message = "[caster] smashes [caster.p_their()] fist upwards into [living_victim]'s jaw, sending [living_victim.p_them()] flying!"
		if(!(limb_to_hit.body_zone in list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)) && limb_to_hit.get_damage() >= limb_to_hit.max_damage)
			limb_to_hit.drop_limb()
			message = span_boldwarning("[caster] punches [limb_to_hit] clean off with a blast of energy!")
			self_message = span_userdanger("[caster] blows [limb_to_hit] off with inhuman force!")
		living_victim.visible_message(message, self_message)
		living_victim.Paralyze(BUSTER_STUN_DURATION)
	else if(non_living_type_check(victim))
		harm(caster, victim, object_punched_damage)
		caster.visible_message(span_warning("[caster] overhead strikes [victim] with their [hand.name]!"))
		return
	else
		harm(caster, victim, wall_collision_damage)
		caster.visible_message(span_warning("[caster] smashes into [victim] with their [hand.name]!"))
		return

	if(victim.anchored)
		return

	victim.SpinAnimation(0.5 SECONDS, 2)
	ADD_TRAIT(victim, TRAIT_UNDENSE, BUSTER_SOURCE)
	var/direction = get_dir(caster, victim)
	if(get_turf(caster) == get_turf(victim))
		direction = caster.dir
	var/turf/target = get_ranged_target_turf(victim, direction, flight_distance)
	var/datum/move_loop/loop = SSmove_manager.throw_at(victim, target, maxrange = flight_distance, delay = 0.01 SECONDS)
	RegisterSignal(victim, COMSIG_MOVABLE_MOVED_FROM_LOOP, PROC_REF(soar_on_moved_from_loop))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(soar_post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_qdeleted))
	soar_on_moved_from_loop(victim, loop, victim.dir, direction)
	return

/datum/action/cooldown/spell/touch/buster/megabuster/proc/soar_on_moved_from_loop(atom/movable/source, datum/move_loop/has_target/throw_at/loop, old_dir, direction)
	SIGNAL_HANDLER
	if(!loop.lifetime)
		return
	var/turf/next_turf = get_step(source, direction)
	if(iswallturf(next_turf))
		harm(null, source, living_collision_dam)
		if(next_turf.uses_integrity)
			harm(null, next_turf, wall_collision_damage)
		return
	for(var/atom/movable/impacted_atom as anything in next_turf)
		if(impacted_atom.move_packet || impacted_atom == owner)
			continue
		if(HasElement(impacted_atom, /datum/element/undertile))
			continue

		if(isliving(impacted_atom)) // If the thrown mass hits a person then they get tossed
			var/mob/living/impacted_living = impacted_atom
			harm(null, source, living_collision_dam)
			harm(null, impacted_living, living_collision_dam)
			impacted_living.Knockdown(BUSTER_STUN_DURATION)
			if(impacted_atom.anchored)
				continue

			impacted_living.Paralyze(BUSTER_STUN_DURATION, ignore_canstun = TRUE)
			impacted_living.SpinAnimation(0.5 SECONDS, 1)
			ADD_TRAIT(impacted_living, TRAIT_UNDENSE, BUSTER_SOURCE)
			var/datum/move_loop/new_loop = SSmove_manager.throw_at(impacted_living, loop.target, maxrange = loop.maxrange - loop.dist_travelled, delay = 0.01 SECONDS)
			RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(soar_post_move))
			RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(loop_qdeleted))
		else if(non_living_type_check(impacted_atom))
			harm(null, impacted_atom, object_collision_damage)
			if(impacted_atom.density)
				harm(null, source, living_collision_dam)

/datum/action/cooldown/spell/touch/buster/megabuster/proc/soar_post_move(datum/move_loop/has_target/source, result, delay)
	SIGNAL_HANDLER

	var/mob/living/moving = source.moving
	if(QDELETED(moving) || !istype(moving))
		return

	if(result != MOVELOOP_SUCCESS)
		qdel(source)
		if(isanimal_or_basicmob(moving))
			var/mob/living/moving_living = moving
			if(moving_living.stat == DEAD)
				moving_living.gib()
	else
		moving.Paralyze(BUSTER_STUN_DURATION, ignore_canstun = TRUE)

/datum/action/cooldown/spell/touch/buster/megabuster/proc/loop_qdeleted(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/moving = source.moving
	UnregisterSignal(moving, COMSIG_MOVABLE_MOVED_FROM_LOOP)
	REMOVE_TRAIT(moving, TRAIT_UNDENSE, BUSTER_SOURCE)

/obj/item/melee/touch_attack/buster_mega
	name = "megabuster"
	desc = "And if I become a demon, so be it. I will endure the exile. Anything to protect her."
	icon_state = "fist"
	inhand_icon_state = "zapper"

/obj/item/melee/touch_attack/buster_mega/Initialize(mapload, datum/action/cooldown/spell/spell)
	. = ..()
	var/datum/action/spell_instance = spell_which_made_us?.resolve()
	if(spell_instance)
		addtimer(CALLBACK(src, PROC_REF(timed_out), spell_instance.owner), 5 SECONDS, TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/item/melee/touch_attack/buster_mega/proc/timed_out(mob/spell_owner)
	if(QDELETED(spell_owner))
		return
	to_chat(spell_owner, span_warning("My [name] fizzles out!"))
	remove_hand_with_no_refund(spell_owner) // commit or lose it
/*---------------------------------------------------------------
	end of megabuster section
---------------------------------------------------------------*/

/datum/status_effect/doubledown
	id = "doubledown"
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/doubledown

/atom/movable/screen/alert/status_effect/doubledown
	name = "Doubling Down"
	desc = "You take 25% less damage from all sources, time go all in!"
	icon_state = "aura"

/datum/status_effect/doubledown/on_apply()
	. = ..()
	if(!.)
		return
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	human_owner.ignore_slowdown(id)
	human_owner.physiology.brute_mod *= 0.75
	human_owner.physiology.burn_mod *= 0.75
	human_owner.physiology.tox_mod *= 0.75
	human_owner.physiology.oxy_mod *= 0.75
	human_owner.physiology.clone_mod *= 0.75
	human_owner.physiology.stamina_mod *= 0.75
	human_owner.AddComponent(/datum/component/after_image, count = 1, image_color = BUSTER_COLOR)
	human_owner.AddElement(/datum/element/perma_fire_overlay, fire_stacks = MOB_BIG_FIRE_STACK_THRESHOLD, fire_color = BUSTER_COLOR)
	human_owner.log_message("gained buster damage reduction", LOG_ATTACK)
	if(prob(1))
		human_owner.say("+DOUBLE DOWN!+", forced = "buster fist")
	return TRUE

/datum/status_effect/doubledown/on_remove()
	. = ..()
	var/mob/living/carbon/human/human_owner = owner
	human_owner.unignore_slowdown(id)
	human_owner.physiology.brute_mod /= 0.75
	human_owner.physiology.burn_mod /= 0.75
	human_owner.physiology.tox_mod /= 0.75
	human_owner.physiology.oxy_mod /= 0.75
	human_owner.physiology.clone_mod /= 0.75
	human_owner.physiology.stamina_mod /= 0.75
	var/datum/component/after_image = human_owner.GetComponent(/datum/component/after_image)
	qdel(after_image)
	human_owner.RemoveElement(/datum/element/perma_fire_overlay, fire_stacks = MOB_BIG_FIRE_STACK_THRESHOLD, fire_color = BUSTER_COLOR)
	owner.log_message("lost buster damage reduction", LOG_ATTACK)

#undef BUSTER_SOURCE
#undef STATUS_EFFECT_DOUBLEDOWN
#undef BUSTER_STUN_DURATION
#undef GRAPPLE_DRAG_TIME
#undef BUSTER_COLOR
