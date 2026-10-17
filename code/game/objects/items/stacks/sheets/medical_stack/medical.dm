/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/medical/stack_medical.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	item_flags = NOBLUDGEON|SKIP_FANTASY_ON_SPAWN
	cost = 250
	source = /datum/robot_energy_storage/medical
	merge_type = /obj/item/stack/medical
	/// Sound played when heal doafter begins
	var/heal_sound
	/// How long it takes to apply it to yourself
	var/self_delay = 5 SECONDS
	/// How long it takes to apply it to someone else
	var/other_delay = 0
	/// If we've still got more and the patient is still hurt, should we keep going automatically?
	var/repeating = FALSE
	/// How much brute we heal per application. This is the only number that matters for simplemobs
	var/heal_brute
	/// How much burn we heal per application
	var/heal_burn
	/// How much we reduce bleeding per application on cut wounds
	var/stop_bleeding
	/// How much sanitization to apply to burn wounds on application
	var/sanitization
	/// How much we add to flesh_healing for burn wounds on application
	var/flesh_regeneration

/obj/item/stack/medical/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!begin_heal_loop(interacting_with, user, auto_change_zone = TRUE))
		return NONE // [ITEM_INTERACT_BLOCKING] would be redundant as we are nobludgeon
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/medical/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!begin_heal_loop(interacting_with, user, auto_change_zone = FALSE))
		return NONE // see above
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/medical/Initialize(mapload, new_amount, merge = TRUE, list/mat_override = null, mat_amt = 1)
	. = ..()
	register_item_context()

/obj/item/stack/medical/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(!isliving(target))
		return NONE
	if(iscarbon(target))
		context[SCREENTIP_CONTEXT_LMB] = "Auto Heal"
		context[SCREENTIP_CONTEXT_RMB] = "Manual Heal"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Heal"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/stack/medical/apply_fantasy_bonuses(bonus)
	. = ..()
	if(heal_brute)
		heal_brute = modify_fantasy_variable("heal_brute", heal_brute, bonus)
	if(heal_burn)
		heal_burn = modify_fantasy_variable("heal_burn", heal_burn, bonus)
	if(stop_bleeding)
		stop_bleeding = modify_fantasy_variable("stop_bleeding", stop_bleeding, bonus/10)
	if(sanitization)
		sanitization = modify_fantasy_variable("sanitization", sanitization, bonus/10)
	if(flesh_regeneration)
		flesh_regeneration = modify_fantasy_variable("flesh_regeneration", flesh_regeneration, bonus/10)

/obj/item/stack/medical/remove_fantasy_bonuses(bonus)
	heal_brute = reset_fantasy_variable("heal_brute", heal_brute)
	heal_burn = reset_fantasy_variable("heal_burn", heal_burn)
	stop_bleeding = reset_fantasy_variable("stop_bleeding", stop_bleeding)
	sanitization = reset_fantasy_variable("sanitization", sanitization)
	flesh_regeneration = reset_fantasy_variable("flesh_regeneration", flesh_regeneration)
	return ..()

/// Used to begin the recursive healing loop.
/// Returns TRUE if we entered the loop, FALSE if we didn't
/obj/item/stack/medical/proc/begin_heal_loop(mob/living/patient, mob/living/user, auto_change_zone = TRUE)
	if(DOING_INTERACTION_WITH_TARGET(user, patient))
		return FALSE
	var/heal_zone = check_zone(user.zone_selected)
	if(!try_heal_checks(patient, user, heal_zone))
		return FALSE
	SSblackbox.record_feedback("nested tally", "medical_item_used", 1, list("[auto_change_zone ? "auto" : "manual"]", "[type]"))
	patient.balloon_alert(user, "treating [parse_zone(heal_zone)]...")
	INVOKE_ASYNC(src, PROC_REF(try_heal), patient, user, heal_zone, FALSE, iscarbon(patient) && auto_change_zone) // auto change is useless for non-carbons
	return TRUE

/**
 * What actually handles printing the message that we're starting to heal someone, and trying to heal them
 *
 * This proc is recursively called until we run out of charges OR until the patient is fully healed
 * OR until the target zone is fully healed (if auto_change_zone is FALSE)
 *
 * * patient - The mob we're trying to heal
 * * user - The mob that's trying to heal the patient
 * * healed_zone - The zone we're trying to heal on the patient
 * Disregarded if auto_change_zone is TRUE
 * * silent - If we should not print the message that we're starting to heal the patient
 * Used so looping the proc doesn't spam messages
 * * auto_change_zone - Handles the behavior when we finish healing a zone
 * If auto_change_zone is set to TRUE, it picks the next most damaged zone to heal
 * If auto_change_zone is set to FALSE, it'll give the user a chance to pick a new zone to heal
 */
/obj/item/stack/medical/proc/try_heal(mob/living/patient, mob/living/user, healed_zone, silent = FALSE, auto_change_zone = TRUE)
	if(heal_sound)
		playsound(patient, heal_sound, 33, FALSE)
	if(patient == user)
		if(!silent)
			user.balloon_alert(user, "treating [parse_zone(healed_zone)]...")
			user.visible_message(
				span_notice("[user] starts to apply [src] on [user.p_them()]self..."),
				span_notice("You begin applying [src] on yourself..."),
			)
		if(!do_after(
			user,
			self_delay * (auto_change_zone ? 1 : 0.9),
			patient,
			extra_checks = CALLBACK(src, PROC_REF(can_heal), patient, user, healed_zone),
		))
			return
		if(!auto_change_zone)
			healed_zone = check_zone(user.zone_selected)
		if(!try_heal_checks(patient, user, healed_zone))
			return

	else if(other_delay)
		if(!silent)
			patient.balloon_alert(user, "treating [parse_zone(healed_zone)]...")
			user.visible_message(
				span_notice("[user] starts to apply [src] on [patient]."),
				span_notice("You begin applying [src] on [patient]..."),
			)
		if(!do_after(
			user,
			other_delay * (auto_change_zone ? 1 : 0.9),
			patient,
			extra_checks = CALLBACK(src, PROC_REF(can_heal), patient, user, healed_zone),
		))
			return
		if(!auto_change_zone)
			healed_zone = check_zone(user.zone_selected)
		if(!try_heal_checks(patient, user, healed_zone))
			return

	else
		if(!silent)
			user.visible_message(
				span_notice("[user] applies [src] on [patient]."),
				span_notice("You apply [src] on [patient]."),
			)

	if(iscarbon(patient))
		if(!heal_carbon(patient, user, healed_zone))
			return
	else if(isanimal_or_basicmob(patient))
		if(!heal_simplemob(patient, user))
			return
	else
		CRASH("Stack medical item healing a non-carbon, non-animal mob [patient] ([patient.type])")

	log_combat(user, patient, "healed", src)
	if(!use(1) || !repeating || amount <= 0)
		var/atom/alert_loc = QDELETED(src) ? user : src
		alert_loc.balloon_alert(user, repeating ? "all used up!" : "treated [parse_zone(healed_zone)]")
		return

	// first, just try looping
	// 1. we can keep healing the current target
	// 2. the user's changed their target (and thus we should heal that limb instead)
	var/preferred_target = check_zone(user.zone_selected)
	if(try_heal_checks(patient, user, preferred_target, silent = TRUE))
		if(preferred_target != healed_zone)
			patient.balloon_alert(user, "treating [parse_zone(preferred_target)]...")
		try_heal(patient, user, preferred_target, TRUE, auto_change_zone)
		return

	// second, handle what happens otherwise
	if(!iscarbon(patient))
		// behavior 0: non-carbons have no limbs so we can assume they are fully healed
		patient.balloon_alert(user, "fully treated")
	else if(auto_change_zone)
		// behavior 1: automatically pick another zone to heal
		try_heal_auto_change_zone(patient, user, preferred_target, healed_zone)
	else
		// behavior 2: assess injury, giving the user time to manually pick another zone
		try_heal_manual_target(patient, user)

/// Picks the next damaged bodypart of the patient to heal, prioritizing the user's targeted zone
/obj/item/stack/medical/proc/try_heal_auto_change_zone(mob/living/carbon/patient, mob/living/user, preferred_target, last_zone)
	PRIVATE_PROC(TRUE)

	var/list/other_affected_limbs = list()
	for(var/obj/item/bodypart/limb as anything in patient.bodyparts)
		if(!try_heal_checks(patient, user, limb.body_zone, silent = TRUE))
			continue
		other_affected_limbs += limb.body_zone

	if(!length(other_affected_limbs))
		patient.balloon_alert(user, "fully treated")
		return

	var/next_picked = (preferred_target in other_affected_limbs) ? preferred_target : other_affected_limbs[1]
	if(next_picked != last_zone)
		user.balloon_alert(user, "treating [parse_zone(next_picked)]...")
	try_heal(patient, user, next_picked, silent = TRUE, auto_change_zone = TRUE)

/// Gives the user a second to pick a new zone to heal, then continues healing that zone
/obj/item/stack/medical/proc/try_heal_manual_target(mob/living/carbon/patient, mob/living/user)
	PRIVATE_PROC(TRUE)

	patient.balloon_alert(user, "assessing injury...")
	if(!do_after(user, 1 SECONDS, patient))
		return
	var/new_zone = check_zone(user.zone_selected)
	if(!try_heal_checks(patient, user, new_zone))
		return
	patient.balloon_alert(user, "treating [parse_zone(new_zone)]...")
	try_heal(patient, user, new_zone, silent = TRUE, auto_change_zone = FALSE)

/// Checks if the passed patient can be healed by the passed user
/obj/item/stack/medical/proc/can_heal(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	return patient.try_inject(user, healed_zone, injection_flags = silent ? NONE : INJECT_TRY_SHOW_ERROR_MESSAGE)

/// Checks a bunch of stuff to see if we can heal the patient, including can_heal
/// Gives a feedback if we can't ultimatly heal the patient (unless silent is TRUE)
/obj/item/stack/medical/proc/try_heal_checks(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	if(!can_heal(patient, user, healed_zone, silent))
		// has its own feedback
		return FALSE
	if(patient.stat == DEAD)
		if(!silent)
			patient.balloon_alert(user, "[patient.p_theyre()] dead!")
		return FALSE

	if(iscarbon(patient))
		var/mob/living/carbon/carbon_patient = patient
		var/obj/item/bodypart/affecting = carbon_patient.get_bodypart(healed_zone)
		if(!affecting) //Missing limb?
			if(!silent)
				carbon_patient.balloon_alert(user, "no [parse_zone(healed_zone)]!")
			return FALSE
		if(!IS_ORGANIC_LIMB(affecting)) //Limb must be organic to be healed - RR
			if(!silent)
				carbon_patient.balloon_alert(user, "[affecting.plaintext_zone] is not organic!")
			return FALSE

		var/datum/wound/burn/flesh/any_burn_wound = locate() in affecting.wounds
		var/can_heal_burn_wounds = (flesh_regeneration || sanitization) && any_burn_wound?.can_be_ointmented_or_meshed()
		var/can_suture_bleeding = stop_bleeding && affecting.cached_bleed_rate > 0
		var/brute_to_heal = heal_brute && affecting.brute_dam > 0
		var/burn_to_heal = heal_burn && affecting.burn_dam > 0

		if(!brute_to_heal && !burn_to_heal && !can_heal_burn_wounds && !can_suture_bleeding)
			if(!silent)
				if(!brute_to_heal && stop_bleeding) // no brute, no bleeding
					carbon_patient.balloon_alert(user, "[affecting.plaintext_zone] is not bleeding or bruised!")
				else if(!burn_to_heal && (flesh_regeneration || sanitization) && any_burn_wound) // no burns, existing burn wounds are treated
					carbon_patient.balloon_alert(user, "[affecting.plaintext_zone] has been fully treated!")
				else if(!affecting.brute_dam && !affecting.burn_dam) // not hurt at all
					carbon_patient.balloon_alert(user, "[affecting.plaintext_zone] is not hurt!")
				else // probably hurt in some way but we are not the right item for this
					carbon_patient.balloon_alert(user, "can't heal [affecting.plaintext_zone] with [name]!")
			return FALSE
		return TRUE

	if(isanimal_or_basicmob(patient))
		if(!heal_brute) // only brute can heal
			if(!silent)
				patient.balloon_alert(user, "can't heal with [name]!")
			return FALSE
		var/mob/living/simple_animal/critter = patient
		if(istype(critter) && !critter.healable)
			if(!silent)
				patient.balloon_alert(user, "won't work!")
			return FALSE
		if(!(patient.mob_biotypes & MOB_ORGANIC))
			if(!silent)
				patient.balloon_alert(user, "no organic tissue!")
			return FALSE
		if(patient.health == patient.maxHealth)
			if(!silent)
				patient.balloon_alert(user, "not hurt!")
			return FALSE
		return TRUE

	return FALSE

/// The healing effects on a carbon patient.
/// Since we have extra details for dealing with bodyparts, we get our own fancy proc.
/// Still returns TRUE on success and FALSE on fail
/obj/item/stack/medical/proc/heal_carbon(mob/living/carbon/patient, mob/living/user, healed_zone)
	var/obj/item/bodypart/affecting = patient.get_bodypart(healed_zone)
	user.visible_message(
		span_green("[user] applies [src] on [patient]'s [affecting.plaintext_zone]."),
		span_green("You apply [src] on [patient]'s [affecting.plaintext_zone]."),
	)
	var/previous_damage = affecting.get_damage()
	if(affecting.heal_damage(heal_brute, heal_burn))
		patient.update_damage_overlays()
	if(stop_bleeding)
		for(var/datum/wound/wound as anything in affecting.wounds)
			if(wound.blood_flow)
				wound.adjust_blood_flow(-1 * stop_bleeding * (user == patient ? 0.7 : 1))
				break // one at a time
		affecting.adjustBleedStacks(-1 * stop_bleeding, 0)
	if(flesh_regeneration || sanitization)
		for(var/datum/wound/burn/flesh/wound in affecting.wounds)
			if(wound.can_be_ointmented_or_meshed())
				wound.flesh_healing += flesh_regeneration
				wound.sanitization += sanitization
				break // one at a time
	post_heal_effects(max(previous_damage - affecting.get_damage(), 0), patient, user)
	return TRUE

/// Healing a simple mob, just a heal_bodypart_damage call
/obj/item/stack/medical/proc/heal_simplemob(mob/living/patient, mob/living/user)
	patient.heal_bodypart_damage((heal_brute * 0.5))
	user.visible_message(
		span_green("[user] applies [src] on [patient]."),
		span_green("You apply [src] on [patient]."),
	)
	return TRUE

///Override this proc for special post heal effects. Only called for carbon patients.
/obj/item/stack/medical/proc/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/living/user)
	return

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	self_delay = 4 SECONDS
	other_delay = 2 SECONDS
	grind_results = list(/datum/reagent/medicine/c2/libital = 10)
	merge_type = /obj/item/stack/medical/bruise_pack

/obj/item/stack/medical/bruise_pack/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

	/*
	The idea is for the following medical devices to work like a hybrid of the old brute packs and tend wounds,
	they heal a little at a time, have reduced healing density and does not allow for rapid healing while in combat.
	However they provice graunular control of where the healing is directed, this makes them better for curing work-related cuts and scrapes.

	The interesting limb targeting mechanic is retained and i still believe they will be a viable choice, especially when healing others in the field.
	 */

/obj/item/stack/medical/suture
	name = "suture"
	desc = "Basic sterile sutures used to seal up cuts and lacerations and stop bleeding."
	gender = PLURAL
	singular_name = "suture"
	icon_state = "suture"
	self_delay = 3 SECONDS
	other_delay = 1 SECONDS
	amount = 10
	max_amount = 10
	repeating = TRUE
	heal_brute = 10
	stop_bleeding = 0.6
	grind_results = list(/datum/reagent/medicine/antipathogenic/spaceacillin = 2)
	merge_type = /obj/item/stack/medical/suture
	heal_sound = 'sound/items/snip.ogg'

/obj/item/stack/medical/suture/emergency
	name = "emergency suture"
	desc = "A value pack of cheap sutures, not very good at repairing damage, but still decent at stopping bleeding."
	heal_brute = 5
	amount = 5
	max_amount = 5
	merge_type = /obj/item/stack/medical/suture/emergency

/obj/item/stack/medical/suture/medicated
	name = "medicated suture"
	icon_state = "suture_purp"
	desc = "A suture infused with drugs that speed up wound healing of the treated laceration."
	heal_brute = 15
	stop_bleeding = 0.75
	grind_results = list(/datum/reagent/medicine/polypyr = 1)
	merge_type = /obj/item/stack/medical/suture/medicated

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Basic burn ointment, rated effective for second degree burns with proper bandaging, though it's still an effective stabilizer for worse burns. Not terribly good at outright healing burns though."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount = 8
	max_amount = 8
	self_delay = 4 SECONDS
	other_delay = 2 SECONDS

	heal_burn = 5
	flesh_regeneration = 2.5
	sanitization = 0.25
	grind_results = list(/datum/reagent/medicine/c2/lenturi = 10)
	merge_type = /obj/item/stack/medical/ointment

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is squeezing [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is toxic?"))
	return TOXLOSS

/obj/item/stack/medical/mesh
	name = "regenerative mesh"
	desc = "A bacteriostatic mesh used to dress burns."
	gender = PLURAL
	singular_name = "mesh piece"
	icon_state = "regen_mesh"
	self_delay = 3 SECONDS
	other_delay = 1 SECONDS
	amount = 15
	heal_burn = 10
	max_amount = 15
	repeating = TRUE
	sanitization = 0.75
	flesh_regeneration = 3

	var/is_open = TRUE ///This var determines if the sterile packaging of the mesh has been opened.
	grind_results = list(/datum/reagent/medicine/antipathogenic/spaceacillin = 2)
	merge_type = /obj/item/stack/medical/mesh

/obj/item/stack/medical/mesh/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	if(amount == max_amount)  //only seal full mesh packs
		is_open = FALSE
		update_appearance()

/obj/item/stack/medical/mesh/update_icon_state()
	if(is_open)
		return ..()
	icon_state = "regen_mesh_closed"

/obj/item/stack/medical/mesh/try_heal_checks(mob/living/patient, mob/living/user, healed_zone, silent = FALSE)
	if(!is_open)
		if(!silent)
			balloon_alert(user, "open it first!")
		return FALSE
	return ..()

/obj/item/stack/medical/mesh/click_alt(mob/living/user)
	if(!is_open)
		balloon_alert(user, "open it first!")
		return CLICK_ACTION_BLOCKING
	return CLICK_ACTION_SUCCESS

/obj/item/stack/medical/mesh/attack_hand(mob/user, list/modifiers)
	if(!is_open && user.get_inactive_held_item() == src)
		balloon_alert(user, "open it first!")
		return
	return ..()

/obj/item/stack/medical/mesh/attack_self(mob/user)
	if(!is_open)
		is_open = TRUE
		balloon_alert(user, "opened")
		update_appearance()
		playsound(src, 'sound/items/poster_ripped.ogg', 20, TRUE)
		return
	return ..()

/obj/item/stack/medical/mesh/advanced
	name = "advanced regenerative mesh"
	desc = "An advanced mesh made with aloe extracts and sterilizing chemicals, used to treat burns."

	gender = PLURAL
	icon_state = "aloe_mesh"
	heal_burn = 15
	sanitization = 1.25
	flesh_regeneration = 3.5
	grind_results = list(/datum/reagent/consumable/aloejuice = 1)
	merge_type = /obj/item/stack/medical/mesh/advanced

/obj/item/stack/medical/mesh/advanced/update_icon_state()
	if(is_open)
		return ..()
	icon_state = "aloe_mesh_closed"

/obj/item/stack/medical/aloe
	name = "aloe cream"
	desc = "A healing paste for minor cuts and burns."

	gender = PLURAL
	singular_name = "aloe cream"
	icon_state = "aloe_paste"
	self_delay = 2 SECONDS
	other_delay = 1 SECONDS
	novariants = TRUE
	amount = 20
	max_amount = 20
	repeating = TRUE
	heal_brute = 3
	heal_burn = 3
	grind_results = list(/datum/reagent/consumable/aloejuice = 1)
	merge_type = /obj/item/stack/medical/aloe

/obj/item/stack/medical/aloe/fresh
	amount = 2

/obj/item/stack/medical/bone_gel
	name = "bone gel"
	singular_name = "bone gel"
	desc = "A potent medical gel that, when applied to a damaged bone in a proper surgical setting, triggers an intense melding reaction to repair the wound. Can be directly applied alongside surgical sticky tape to a broken bone in dire circumstances, though this is very harmful to the patient and not recommended."

	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "bone-gel"
	inhand_icon_state = "bone-gel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	amount = 5
	self_delay = 20
	grind_results = list(/datum/reagent/bone_dust = 10, /datum/reagent/carbon = 10)
	novariants = TRUE
	merge_type = /obj/item/stack/medical/bone_gel

/obj/item/stack/medical/bone_gel/get_surgery_tool_overlay(tray_extended)
	return "gel" + (tray_extended ? "" : "_out")

/obj/item/stack/medical/bone_gel/attack(mob/living/patient, mob/user)
	patient.balloon_alert(user, "no fractures!")
	return

/obj/item/stack/medical/bone_gel/suicide_act(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/patient = user
	patient.visible_message(span_suicide("[patient] is squirting all of [src] into [patient.p_their()] mouth! That's not proper procedure! It looks like [patient.p_theyre()] trying to commit suicide!"))
	if(!do_after(patient, 2 SECONDS))
		patient.visible_message(span_suicide("[patient] screws up like an idiot and still dies anyway!"))
		return BRUTELOSS

	patient.emote("scream")
	for(var/i in patient.bodyparts)
		var/obj/item/bodypart/bone = i // fine to just, use these raw, its a meme anyway
		var/datum/wound/blunt/bone/severe/oof_ouch = new
		oof_ouch.apply_wound(bone, wound_source = "bone gel")
		var/datum/wound/blunt/bone/critical/oof_OUCH = new
		oof_OUCH.apply_wound(bone, wound_source = "bone gel")

	for(var/i in patient.bodyparts)
		var/obj/item/bodypart/bone = i
		bone.receive_damage(brute=60)
	use(1)
	return BRUTELOSS

/obj/item/stack/medical/bone_gel/one
	amount = 1

/obj/item/stack/medical/poultice
	name = "mourning poultices"
	singular_name = "mourning poultice"
	desc = "A type of primitive herbal poultice.\nWhile traditionally used to prepare corpses for the mourning feast, it can also treat scrapes and burns on the living, however, it is liable to cause shortness of breath when employed in this manner.\nIt is imbued with ancient wisdom."
	icon_state = "poultice"
	amount = 15
	max_amount = 15
	heal_brute = 10
	heal_burn = 10
	self_delay = 40
	other_delay = 10
	repeating = TRUE
	drop_sound = 'sound/misc/moist_impact.ogg'
	mob_throw_hit_sound = 'sound/misc/moist_impact.ogg'
	hitsound = 'sound/misc/moist_impact.ogg'
	merge_type = /obj/item/stack/medical/poultice

/obj/item/stack/medical/poultice/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/living/user)
	. = ..()
	playsound(src, 'sound/misc/soggy.ogg', 30, TRUE)
	healed_mob.adjustOxyLoss(amount_healed)
