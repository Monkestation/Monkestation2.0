//Nearsightedness restricts your vision by several tiles.
/datum/mutation/nearsight
	name = "Near Sightness"
	desc = "The holder of this mutation has poor eyesight."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You can't see very well.</span>"

/datum/mutation/nearsight/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.become_nearsighted(GENETIC_MUTATION)

/datum/mutation/nearsight/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_nearsighted(GENETIC_MUTATION)

///Blind makes you blind. Who knew?
/datum/mutation/blind
	name = "Blindness"
	desc = "Renders the subject completely blind."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to see anything.</span>"

/datum/mutation/blind/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.become_blind(GENETIC_MUTATION)

/datum/mutation/blind/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_blind(GENETIC_MUTATION)

///Thermal Vision lets you see mobs through walls
/datum/mutation/thermal
	name = "Thermal Vision"
	desc = "The user of this genome can visually perceive the unique human thermal signature."
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = "<span class='notice'>You can see the heat rising off of your skin...</span>"
	text_lose_indication = "<span class='notice'>You can no longer see the heat rising off of your skin...</span>"
	instability = 25
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1
	power_path = /datum/action/cooldown/spell/thermal_vision

/datum/mutation/thermal/on_losing(mob/living/carbon/human/owner)
	if(..())
		return

	// Something went wront and we still have the thermal vision from our power, no cheating.
	if(HAS_TRAIT_FROM(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		REMOVE_TRAIT(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		owner.update_sight()

/datum/mutation/thermal/setup()
	. = ..()
	var/datum/action/cooldown/spell/thermal_vision/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	to_modify.eye_damage = 10 * GET_MUTATION_SYNCHRONIZER(src)
	to_modify.thermal_duration = 10 SECONDS * GET_MUTATION_POWER(src)

/datum/action/cooldown/spell/thermal_vision
	name = "Activate Thermal Vision"
	desc = "You can see thermal signatures, at the cost of your eyesight."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "augmented_eyesight"

	cooldown_time = 25 SECONDS
	spell_requirements = NONE

	/// How much eye damage is given on cast
	var/eye_damage = 10
	/// The duration of the thermal vision
	var/thermal_duration = 10 SECONDS

/datum/action/cooldown/spell/thermal_vision/Remove(mob/living/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	remove_from.update_sight()
	return ..()

/datum/action/cooldown/spell/thermal_vision/is_valid_target(atom/cast_on)
	return isliving(cast_on) && !HAS_TRAIT(cast_on, TRAIT_THERMAL_VISION)

/datum/action/cooldown/spell/thermal_vision/cast(mob/living/cast_on)
	. = ..()
	ADD_TRAIT(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	cast_on.update_sight()
	to_chat(cast_on, span_info("You focus your eyes intensely, as your vision becomes filled with heat signatures."))
	addtimer(CALLBACK(src, PROC_REF(deactivate), cast_on), thermal_duration)

/datum/action/cooldown/spell/thermal_vision/proc/deactivate(mob/living/cast_on)
	if(QDELETED(cast_on) || !HAS_TRAIT_FROM(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	cast_on.update_sight()
	to_chat(cast_on, span_info("You blink a few times, your vision returning to normal as a dull pain settles in your eyes."))

	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_cast_on = cast_on
		carbon_cast_on.adjustOrganLoss(ORGAN_SLOT_EYES, eye_damage)

///X-ray Vision lets you see through walls.
/datum/mutation/xray
	name = "Perfect X Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	text_gain_indication = "<span class='notice'>The walls suddenly disappear!</span>"
	instability = 35
	locked = TRUE

/datum/mutation/xray/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/xray/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/xray
	conflicts = list(/datum/mutation/weaker_xray, /datum/mutation/weaker_xray/syndicate)

/datum/mutation/weaker_xray
	name = "X-Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls at the cost of their eye health."
	locked = TRUE
	power_path = /datum/action/cooldown/toggle_xray
	instability = 60
	conflicts = list(/datum/mutation/xray, /datum/mutation/weaker_xray/syndicate)
	synchronizer_coeff = 1

/datum/mutation/weaker_xray/setup()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/toggle_xray/modified_power = .
	modified_power.synchronizer = GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/toggle_xray
	name = "Toggle X-ray"
	desc = "Concentrate your eyes to see through the walls, this makes your eyes take damage and be weaker to flashes."
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "augmented_eyesight"
	var/toggle = FALSE
	var/synchronizer = 1

/datum/action/cooldown/toggle_xray/Grant(mob/granted_to)
	. = ..()
	if(!owner)
		return

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))

/datum/action/cooldown/toggle_xray/Remove(mob/removed_from)
	if(owner)
		UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
		if(toggle)
			toggle_off()
	return ..()

/datum/action/cooldown/toggle_xray/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		if(feedback)
			to_chat(owner, span_warning("You don't have eyes to use X-ray with!"))
		return FALSE

	if(eyes.organ_flags & ORGAN_FAILING)
		if(feedback)
			to_chat(owner, span_warning("You can't use your X-ray vision whilst blind!"))
		return FALSE

	if(IS_ROBOTIC_ORGAN(eyes))
		if(feedback)
			owner.balloon_alert(owner, "eyes robotic!")
		return FALSE

	return TRUE

/datum/action/cooldown/toggle_xray/Activate(atom/target)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return

	toggle = !toggle
	if(toggle)
		to_chat(owner, span_notice("You feel your eyes sting as you force them to see through solid matter."))
		eyes.flash_protect--
		eyes.apply_organ_damage(5 * synchronizer)
		ADD_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
		owner.update_sight()
		START_PROCESSING(SSobj, src)
	else
		to_chat(owner, span_notice("You adjust your eyes to no longer see past the walls."))
		toggle_off()

/datum/action/cooldown/toggle_xray/process(seconds_per_tick)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		toggle = !toggle
		toggle_off()
		return

	eyes.apply_organ_damage(seconds_per_tick * 2 * synchronizer)
	if(eyes.organ_flags & ORGAN_FAILING)
		toggle = !toggle
		toggle_off()

/datum/action/cooldown/toggle_xray/StartCooldownSelf(override_cooldown_time) // Since we're using process, this cant happen
	return

/datum/action/cooldown/toggle_xray/proc/toggle_off()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, GENETIC_MUTATION)
	STOP_PROCESSING(SSobj, src)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.flash_protect++

	owner.update_sight()

/datum/action/cooldown/toggle_xray/proc/eye_implanted(mob/living/source, obj/item/organ/gained, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = gained
	if(!istype(eyes))
		return

	eyes.flash_protect--

/datum/action/cooldown/toggle_xray/proc/eye_removed(mob/living/source, obj/item/organ/removed, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = removed
	if(!istype(eyes))
		return

	eyes.flash_protect = initial(eyes.flash_protect)
	if(toggle)
		toggle = !toggle
		toggle_off()

/datum/mutation/weaker_xray/syndicate
	name = "Refined X-Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls at the cost of their eye health. This one seems to be high-quality making it more stable."
	instability = 40
	conflicts = list(/datum/mutation/xray, /datum/mutation/weaker_xray)

///Laser Eyes lets you shoot lasers from your eyes!
/datum/mutation/laser_eyes
	name = "Laser Eyes"
	desc = "Reflects concentrated light back from the eyes."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>You feel pressure building up behind your eyes.</span>"
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = BODY_ZONE_HEAD
	power_coeff = 1
	energy_coeff = 1
	conflicts = list(/datum/mutation/laser_eyes/unstable, /datum/mutation/laser_eyes/unstable/syndicate)

/datum/mutation/laser_eyes/New(datum/mutation/copymut)
	. = ..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER))

/datum/mutation/laser_eyes/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return
	RegisterSignal(H, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/mutation/laser_eyes/on_losing(mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	UnregisterSignal(H, COMSIG_MOB_ATTACK_RANGED)

/datum/mutation/laser_eyes/get_visual_indicator()
	return visual_indicators[type][1]

///Triggers on COMSIG_MOB_ATTACK_RANGED. Does the projectile shooting.
/datum/mutation/laser_eyes/proc/on_ranged_attack(mob/living/carbon/human/source, atom/target, modifiers)
	SIGNAL_HANDLER

	if(!(source.istate & ISTATE_HARM))
		return
	to_chat(source, span_warning("You shoot with your laser eyes!"))
	source.changeNext_move(CLICK_CD_RANGE * GET_MUTATION_ENERGY(src))
	source.newtonian_move(get_dir(target, source))
	var/obj/projectile/beam/laser/laser_eyes/LE = new(source.loc)
	LE.firer = source
	LE.damage *= GET_MUTATION_POWER(src)
	LE.def_zone = ran_zone(source.zone_selected)
	LE.aim_projectile(target, source, modifiers)
	INVOKE_ASYNC(LE, TYPE_PROC_REF(/obj/projectile, fire))
	playsound(source, 'sound/weapons/gun/energy/Laser2.ogg', 75, TRUE)

///Projectile type used by laser eyes
/obj/projectile/beam/laser/laser_eyes
	name = "beam"
	icon = 'icons/effects/genetics.dmi'
	icon_state = "eyelasers"

/// Laser eyes made by a geneticist
/datum/mutation/laser_eyes/unstable
	name = "Unstable Laser Eyes"
	desc = "Reflects concentrated light back from the eyes, however this mutation is very unstable and causes damage to the user."
	instability = 60
	conflicts = list(/datum/mutation/laser_eyes, /datum/mutation/laser_eyes/unstable/syndicate)
	synchronizer_coeff = 1
	var/shots_left = 4
	var/cooldown

/datum/mutation/laser_eyes/unstable/Destroy(force)
	if(shots_left != 4)
		STOP_PROCESSING(SSobj, src)
	return ..()

/datum/mutation/laser_eyes/unstable/on_ranged_attack(mob/living/carbon/human/source, atom/target, modifiers)
	if(!(source.istate & ISTATE_HARM))
		return

	var/obj/item/organ/internal/eyes/eyes = source.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		to_chat(source, span_warning("You don't have eyes to shoot lasers!"))
		return

	if(eyes.organ_flags & ORGAN_FAILING)
		to_chat(source, span_warning("You can't shoot lasers whilst your cornea is melted!"))
		return

	if(IS_ROBOTIC_ORGAN(eyes))
		owner.balloon_alert(owner, "eyes robotic!")
		return FALSE

	if(!shots_left)
		source.balloon_alert(source, "can't fire!")
		to_chat(source, span_warning("You can't fire your laser eyes this fast!"))
		return

	. = ..()
	if(shots_left == 4)
		START_PROCESSING(SSobj, src)
	shots_left--

	var/backfire_damage = 5 * GET_MUTATION_SYNCHRONIZER(src)
	eyes.apply_organ_damage(backfire_damage)
	var/obj/item/bodypart/head/head = source.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.receive_damage(burn = backfire_damage, damage_source = src)
	else
		source.adjustFireLoss(backfire_damage)

/datum/mutation/laser_eyes/unstable/process(seconds_per_tick)
	cooldown += seconds_per_tick
	if(cooldown >= 5)
		shots_left++
		cooldown -= 5
		var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes && !(eyes.organ_flags & ORGAN_FAILING))
			owner.balloon_alert(owner, "eyes recharged!")
			return

	if(shots_left == 4)
		STOP_PROCESSING(SSobj, src)
		cooldown = 0

/datum/mutation/laser_eyes/unstable/syndicate
	name = "Stabilized Laser Eyes"
	desc = "Reflects concentrated light back from the eyes, this strain of the mutation is high-quality, yet still causes the user to take damage on use."
	conflicts = list(/datum/mutation/laser_eyes, /datum/mutation/laser_eyes/unstable)
	instability = 40

/datum/mutation/illiterate
	name = "Illiterate"
	desc = "Causes a severe case of Aphasia that prevents reading or writing."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel unable to read or write.</span>"
	text_lose_indication = "<span class='danger'>You feel able to read and write again.</span>"

/datum/mutation/illiterate/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_ILLITERATE, GENETIC_MUTATION)

/datum/mutation/illiterate/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_ILLITERATE, GENETIC_MUTATION)

/datum/mutation/meson_vision
	name = "Meson Visual Enhancement"
	desc = "A mutation that manipulates the subject's eyes in a way that makes them able to see behind walls to a limited degree."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("More information seems to reach your eyes...")
	text_lose_indication = span_notice("The amount of information reaching your eyes fades...")
	instability = 20

/datum/mutation/meson_vision/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	owner.add_traits(list(TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION), GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/meson_vision/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.remove_traits(list(TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION), GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/night_vision
	name = "Scotopic Visual Enhancement"
	desc = "A mutation that manipulates the subject's eyes in a way that makes them able to see in the dark."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("Were the lights always that bright?")
	text_lose_indication = span_notice("The ambient light level returns to normal...")
	instability = 25

/datum/mutation/night_vision/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_NIGHT_VISION, GENETIC_MUTATION)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.refresh()

	owner.update_sight()

/datum/mutation/night_vision/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, GENETIC_MUTATION)
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.refresh()

	owner.update_sight()

/datum/mutation/flash_protection
	name = "Protected Cornea"
	desc = "A mutation that causes reinforcement to subject's eyes, allowing them to protect against disorientation from bright flashes via distributing excessive photons hitting the subject's eyes."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("You stop noticing the glare from lights...")
	text_lose_indication = span_notice("Lights begin glaring again...")
	instability = 30

/datum/mutation/flash_protection/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(IS_ROBOTIC_ORGAN(eyes))
		return FALSE

	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(eye_implanted))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(eye_removed))
	if(eyes)
		eyes.flash_protect = FLASH_PROTECTION_FLASH

/datum/mutation/flash_protection/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))
	var/obj/item/organ/internal/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.flash_protect = initial(eyes.flash_protect)

/datum/mutation/flash_protection/proc/eye_implanted(mob/living/source, obj/item/organ/gained, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = gained
	if(!istype(eyes))
		return

	if(IS_ROBOTIC_ORGAN(eyes))
		return

	eyes.flash_protect = FLASH_PROTECTION_FLASH

/datum/mutation/flash_protection/proc/eye_removed(mob/living/source, obj/item/organ/removed, special)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/eyes/eyes = removed
	if(!istype(eyes))
		return

	eyes.flash_protect = initial(eyes.flash_protect)

// Colorblindness stuff begins

/datum/client_colour/monochrome/colorblind/genetic // We exist

/datum/mutation/colorblindness
	name = "Genetic achromatopy"
	desc = "This genetic sequence makes the subject occipital lobe not interpret color, rendering the patient completely colorblind."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel your brain becoming a bit more numb..?")
	text_lose_indication = span_notice("You can start seeing colors properly again.")
	instability = 5
	var/color_typepath = /datum/client_colour/monochrome/colorblind/genetic

/datum/mutation/colorblindness/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	owner.add_client_colour(color_typepath)

/datum/mutation/colorblindness/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.remove_client_colour(color_typepath)
