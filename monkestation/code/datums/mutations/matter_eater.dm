#define EAT_FAILED (1 << 0)
	#define EAT_FAILED_NO_COOLDOWN (1 << 1)
#define EAT_SUCCESS (1 << 2)
#define EAT_VOMIT (1 << 3)
#define EAT_DELETE (1 << 4)

/datum/mutation/human/consumption
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	quality = POSITIVE
	text_gain_indication = span_userdanger("You feel... How hungry?")
	text_lose_indication = span_notice("You don't feel quite so hungry anymore.")
	instability = 40
	difficulty = 12
	power_path = /datum/action/cooldown/spell/pointed/consumption
	conflicts = list(/datum/mutation/human/consumption/syndicate)
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/consumption/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		REMOVE_TRAIT(owner, TRAIT_STABILIZED_EATER, GENETIC_MUTATION)

/datum/mutation/human/consumption/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/pointed/consumption/to_modify = .
	to_modify.healing_multiplier *= GET_MUTATION_POWER(src)
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		ADD_TRAIT(owner, TRAIT_STABILIZED_EATER, GENETIC_MUTATION)

/datum/action/cooldown/spell/pointed/consumption
	name = "Eat Matter"
	desc = "Eat just about anything!"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "regurgitate"

	cooldown_time = 1 MINUTE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	antimagic_flags = NONE
	cast_range = 1
	aim_assist = FALSE

	var/healing_multiplier = 1
	var/list/consumed_objects = list()
	var/currently_eating = FALSE

/datum/action/cooldown/spell/pointed/consumption/Destroy(force)
	if(owner)
		var/turf/owner_turf = get_turf(owner)
		owner.visible_message(span_danger("[owner] vomits what seems to be [length(consumed_objects)] things!"))
		for(var/obj/object as anything in consumed_objects)
			clean_references(object)
			object.forceMove(get_turf(owner_turf))

	consumed_objects = null
	return ..()

/datum/action/cooldown/spell/pointed/consumption/IsAvailable(feedback = FALSE)
	if(owner)
		var/mob/living/carbon/human = owner
		if(istype(owner) && human.is_mouth_covered())
			if(feedback)
				owner.balloon_alert(owner, "mouth blocked!")
			return FALSE

	return ..()

/// Called when the spell is activated / the click ability is set to our spell
/datum/action/cooldown/spell/pointed/consumption/on_activation(mob/on_who)
	. = ..()
	if(owner)
		owner.visible_message(span_warning("[owner] widens their mouth to an unsettling degree."))

/// Called when the spell is deactivated / the click ability is unset from our spell
/datum/action/cooldown/spell/pointed/consumption/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(owner)
		owner.visible_message(span_notice("[owner] hinges their jaw back into place."))

/datum/action/cooldown/spell/pointed/consumption/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(isitem(cast_on))
		var/obj/item/item = cast_on
		if(item.item_flags & ABSTRACT)
			cast_on.balloon_alert(owner, "... no.")
			return . | SPELL_CANCEL_CAST

	if(cast_on.resistance_flags & INDESTRUCTIBLE) // Gods longest if() check
		if(!istype(cast_on, /obj/machinery/power/supermatter_crystal) && !istype(cast_on, /obj/singularity) && !istype(cast_on, /obj/narsie) && !istype(cast_on, /obj/ratvar))
			cast_on.balloon_alert(owner, "jaw too small!")
			to_chat(owner, span_warning("You can't seem to unhinge your jaw enough to eat [cast_on]."))
			return . | SPELL_CANCEL_CAST

	if(iseffect(cast_on))
		cast_on.balloon_alert(owner, "what even is this?")
		return . | SPELL_CANCEL_CAST

	if(!isturf(owner.loc))
		cast_on.balloon_alert(owner, "can't eat here!")
		return . | SPELL_CANCEL_CAST

	if(is_type_in_typecache(cast_on, GLOB.oilfry_blacklisted_items))
		cast_on.balloon_alert(owner, "a[pick(list(" singularity", " supermatter", "n elder god"))] looks tastier than this.")
		return . | SPELL_CANCEL_CAST

	if(ishuman(cast_on))
		var/mob/living/carbon/human/human_target = cast_on
		if(owner.zone_selected == BODY_ZONE_PRECISE_GROIN)
			var/message = pick(list("... You wouldn't.", "nope.", "better not.", "not a good idea."))
			cast_on.balloon_alert(owner, message)
			return . | SPELL_CANCEL_CAST

		if(owner.zone_selected == BODY_ZONE_CHEST)
			cast_on.balloon_alert(owner, "too big!")
			return . | SPELL_CANCEL_CAST

		var/obj/item/bodypart/limb = human_target.get_bodypart(owner.zone_selected)
		if(!limb)
			cast_on.balloon_alert(owner, "nothing there!") // Is that a reference to project m-
			return . | SPELL_CANCEL_CAST

		if(owner.zone_selected == BODY_ZONE_HEAD)
			if(owner.pulling != cast_on)
				cast_on.balloon_alert(owner, "need grasp!")
				return . | SPELL_CANCEL_CAST

			if(owner.grab_state != GRAB_KILL)
				cast_on.balloon_alert(owner, "grasp too loose!")
				return . | SPELL_CANCEL_CAST

	StartCooldown()
	return . | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/consumption/cast(obj/cast_on)
	. = ..()
	currently_eating = TRUE
	var/result = cast_on.get_eaten(owner, src)
	currently_eating = FALSE

	if(result == EAT_FAILED)
		return

	if(result == EAT_FAILED_NO_COOLDOWN)
		next_use_time = 0
		return

	playsound(owner.loc, 'sound/items/eatfood.ogg', 100, FALSE)
	Heal()
	if(!isnum(result)) // If we're passed an object, we should vomit it
		if(islist(result)) // And if its a list, we should vomit ALL of it
			var/list/object_list = result
			for(var/atom/object as anything in object_list)
				INVOKE_ASYNC(src, PROC_REF(vomit_object), object)
		else
			INVOKE_ASYNC(src, PROC_REF(vomit_object), result)
		return

	if(result == EAT_DELETE)
		qdel(cast_on)
		return

	cast_on.forceMove(owner)
	RegisterSignal(cast_on, COMSIG_QDELETING, PROC_REF(clean_references))
	RegisterSignal(cast_on, COMSIG_MOVABLE_MOVED, PROC_REF(on_object_moved))
	consumed_objects += cast_on

	if(result == EAT_VOMIT)
		INVOKE_ASYNC(src, PROC_REF(vomit_object), cast_on)

/datum/action/cooldown/spell/pointed/consumption/proc/start_biting_animation(object, time)
	if(!time) // Just do it once
		playsound(owner.loc, 'sound/weapons/bite.ogg', 100, FALSE)
		owner.do_item_attack_animation(object, ATTACK_EFFECT_BITE)
		return

	INVOKE_ASYNC(src, PROC_REF(loop_biting_animation), object, time)

/datum/action/cooldown/spell/pointed/consumption/proc/loop_biting_animation(object, time)
	var/biting_amount = floor(time / 10 SECONDS)
	for(var/index in 1 to biting_amount)
		playsound(owner.loc, 'sound/weapons/bite.ogg', 100, FALSE)
		owner.do_item_attack_animation(object, ATTACK_EFFECT_BITE)
		sleep(10 SECONDS)
		if(!currently_eating)
			break

/datum/action/cooldown/spell/pointed/consumption/proc/clean_references(datum/source)
	SIGNAL_HANDLER
	consumed_objects -= source
	UnregisterSignal(source, COMSIG_QDELETING)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/pointed/consumption/proc/on_object_moved(atom/source)
	SIGNAL_HANDLER
	if(!owner || !source)
		return

	if(source.loc != owner)
		clean_references(source)

/datum/action/cooldown/spell/pointed/consumption/proc/Heal()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return

	human_owner.adjustBruteLoss(-15 * healing_multiplier)

/datum/action/cooldown/spell/pointed/consumption/proc/vomit_object(obj/item/object)
	if(QDELETED(object))
		return

	var/mob/living/carbon/human/human_owner = owner
	sleep(rand(5, 25))
	to_chat(owner, span_userdanger("You feel something sloshing around in your stomach..."))
	sleep(rand(5, 25))
	object.forceMove(get_turf(owner))
	clean_references(object)
	if(prob(25))
		human_owner.vomit(distance = 2)
		step(object, owner.dir)
		step(object, owner.dir)
		return
	human_owner.vomit()
	step(object, owner.dir)

/atom/proc/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	balloon_alert(hungry_boy, "what even is this?")
	return EAT_FAILED_NO_COOLDOWN

/turf/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability, eat_time = 45 SECONDS)
	hungry_boy.visible_message(span_danger("[hungry_boy] unhinges their jaw and begins slowly stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src, eat_time)
	if(!do_after(hungry_boy, eat_time, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole, jesus christ!"))
	acid_melt()
	return EAT_FAILED // Not really, but we handle ourselfes

/turf/open/space/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] gnashes at open [src]!"))
	return EAT_FAILED

/turf/closed/wall/r_wall/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability, eat_time = 1.5 MINUTES)
	return ..()

/obj/item/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] eats [src] in one swift bite."))
	ability.start_biting_animation(src)
	var/obj/brain = locate(/obj/item/organ/internal/brain) in contents
	if(brain)
		return EAT_VOMIT

	return EAT_SUCCESS

/obj/item/organ/internal/brain/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] eats [src]."))
	ability.start_biting_animation(src)
	return EAT_VOMIT

/obj/item/clothing/head/mob_holder/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [held_mob] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src)
	if(!do_after(hungry_boy, 5 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [held_mob]!"))
		return EAT_FAILED

	if(QDELETED(src))
		return EAT_FAILED

	held_mob.adjustBruteLoss(held_mob.health)
	held_mob.death()
	hungry_boy.visible_message(span_danger("[hungry_boy] chomps down on [held_mob], eating them whole!"))
	var/obj/brain = locate(/obj/item/organ/internal/brain) in contents
	if(brain)
		return EAT_VOMIT

	return EAT_SUCCESS

/obj/machinery/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src, 45 SECONDS)
	if(!do_after(hungry_boy, 45 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] eats [src]."))
	return EAT_SUCCESS

/obj/structure/cable/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	if(!HAS_TRAIT(hungry_boy, TRAIT_SHOCKIMMUNE))
		electrocute_mob(hungry_boy, src, src, always_shock = TRUE) // The food bites back
		return EAT_FAILED

	. = ..()
	if(. == EAT_SUCCESS)
		return EAT_DELETE

/obj/machinery/power/apc/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	if(!HAS_TRAIT(hungry_boy, TRAIT_SHOCKIMMUNE))
		electrocute_mob(hungry_boy, src, src, always_shock = TRUE)
		return EAT_FAILED

	. = ..()
	if(. == EAT_SUCCESS)
		return EAT_DELETE

/obj/structure/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src)
	if(!do_after(hungry_boy, 10 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole!"))
	return EAT_SUCCESS

/obj/structure/table/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src)
	if(!do_after(hungry_boy, 10 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole!"))
	return EAT_SUCCESS

/obj/structure/window/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins slowly stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src, 45 SECONDS)
	if(!do_after(hungry_boy, 45 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole!"))
	return EAT_DELETE

/obj/structure/window/reinforced/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins slowly stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src, 70 SECONDS)
	if(!do_after(hungry_boy, 70 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole!"))
	return EAT_DELETE

/obj/structure/closet/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	var/eat_time = 20 SECONDS
	if(anchored)
		eat_time *= 1.5

	ability.start_biting_animation(src, eat_time)
	if(!do_after(hungry_boy, eat_time, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	var/list/things_to_vomit = list()
	for(var/atom/object as anything in contents)
		if(isliving(object) || istype(object, /obj/item/organ/internal/brain) || istype(object, /obj/item/mmi) || object.resistance_flags & INDESTRUCTIBLE)
			things_to_vomit += object

	if(length(things_to_vomit))
		return things_to_vomit

	return EAT_SUCCESS

/obj/machinery/dna_vault/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src] into [hungry_boy.p_their()] gaping maw, you estimate it'll take them at least an hour!"))
	ability.start_biting_animation(src, 1 HOUR)
	if(!do_after(hungry_boy, 1 HOUR, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src], not really a suprise there."))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole, how did you allow it to happen?"))
	return EAT_SUCCESS

/obj/vehicle/sealed/mecha/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_userdanger("[hungry_boy] begins stuffing the entire [src] into [hungry_boy.p_their()] gaping maw!"))
	var/eat_time = get_integrity()
	ability.start_biting_animation(src, eat_time)
	if(!do_after(hungry_boy, eat_time, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] eats [src]."))
	var/list/mobs_to_vomit = list()
	for(var/mob/living/occupant as anything in occupants)
		if(isAI(occupant))
			continue

		mobs_to_vomit += occupant

	if(length(mobs_to_vomit))
		return mobs_to_vomit

	return EAT_SUCCESS

/mob/living/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability, eat_time = health + 1)
	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	var/datum/status_effect/pinkdamagetracker/damage_tracker = has_status_effect(/datum/status_effect/pinkdamagetracker)
	if(istype(damage_tracker)) // This is in fact harmfull
		damage_tracker.damage++

	adjustBruteLoss(1) // AI WAKE UP YOU ARE LITERALLY BEING EATEN ALIVE
	ability.start_biting_animation(src, eat_time)
	if(!do_after(hungry_boy, eat_time, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	forceMove(hungry_boy)
	adjustBruteLoss(health)
	death()
	hungry_boy.visible_message(span_danger("[hungry_boy] eats [src]."))
	return EAT_SUCCESS

/mob/living/silicon/ai/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability, eat_time = health + 1)
	if(is_anchored)
		eat_time *= 2
	return ..()

/mob/living/silicon/robot/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability, eat_time = health + 1)
	eat_time *= 2
	. = ..()
	if(. != EAT_SUCCESS || isnull(mmi) || isnull(mind) || isnull(mmi.brainmob)) // No, we can't use dump_into_mmi()
		return

	if(mmi.brainmob.stat == DEAD)
		mmi.brainmob.set_stat(CONSCIOUS)
	mind.transfer_to(mmi.brainmob)
	mmi.update_appearance()
	return mmi

/mob/living/carbon/human/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability, eat_time = health + 1)
	var/obj/item/bodypart/limb = get_bodypart(hungry_boy.zone_selected)

	hungry_boy.visible_message(span_danger("[hungry_boy] begins stuffing [src]'s [limb.name] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src, 30 SECONDS)
	if(!do_after(hungry_boy, 30 SECONDS, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	var/clumsy_failure = FALSE
	if(istype(hungry_boy) && HAS_TRAIT(hungry_boy, TRAIT_CLUMSY)) // Whoops, i bit off my head again
		if(prob(25))
			limb = hungry_boy.get_bodypart(hungry_boy.zone_selected)
			clumsy_failure = TRUE

	if(!limb || QDELETED(src))
		return EAT_FAILED

	if(!clumsy_failure)
		hungry_boy.visible_message(span_danger("[hungry_boy] [pick("chomps","bites")] off [src]'s [limb]!"))
	else
		hungry_boy.visible_message(span_danger("[hungry_boy] forgets what they were doing, before looking at their [limb] and [pick("chomping", "biting")] it off!"))

	playsound(hungry_boy.loc, 'sound/items/eatfood.ogg', 50, 0)
	limb.dismember(wounding_type = WOUND_PIERCE)

	return EAT_FAILED // We handle ourselfes

// Special cases forward

// Basically impossible since nar'sie has a HUGE gib range
/obj/narsie/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_narsiesmall("[hungry_boy] eats [src] in one bite, breaking the fabric of reality itself!"))
	ability.start_biting_animation(src)
	return EAT_DELETE

/obj/ratvar/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_narsiesmall("[hungry_boy] eats [src] in one bite, breaking the fabric of reality itself!"))
	ability.start_biting_animation(src)
	return EAT_DELETE

/obj/singularity/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_narsiesmall("[hungry_boy] eats [src] in one bite!"))
	to_chat(hungry_boy, span_userdanger("You feel strangelly... empty? Was this a good idea?"))
	ability.start_biting_animation(src)
	return EAT_SUCCESS

/obj/machinery/power/supermatter_crystal/get_eaten(mob/living/carbon/human/hungry_boy, datum/action/cooldown/spell/pointed/consumption/ability)
	hungry_boy.visible_message(span_danger("[hungry_boy] unhinges their jaw and begins slowly stuffing [src] into [hungry_boy.p_their()] gaping maw!"))
	ability.start_biting_animation(src, 1 MINUTE)
	if(!do_after(hungry_boy, 1 MINUTE, src))
		to_chat(hungry_boy, span_danger("You were interrupted before you could eat [src]!"))
		return EAT_FAILED

	hungry_boy.visible_message(span_danger("[hungry_boy] consumes [src] whole, how is that even possible?"))
	return EAT_SUCCESS

/datum/mutation/human/consumption/syndicate
	name = "Refined Matter Eater"
	desc = "Allows the subject to eat just about anything without harm. This seems to be a strain that was marked as too dangerous by Nanotrasen and thus is outlawed."
	locked = TRUE
	instability = 20
	conflicts = list(/datum/mutation/human/consumption)

#undef EAT_FAILED
#undef EAT_SUCCESS
#undef EAT_VOMIT
#undef EAT_DELETE
