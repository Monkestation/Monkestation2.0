/datum/mutation/dwarfism
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/dwarfism/setup()
	. = ..()
	if(isnull(owner))
		return

	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_FAST_CLIMBER, GENETIC_MUTATION)
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		ADD_TRAIT(owner, TRAIT_STABLE_DWARF, GENETIC_MUTATION)

/datum/mutation/dwarfism/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_FAST_CLIMBER, GENETIC_MUTATION)
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		REMOVE_TRAIT(owner, TRAIT_STABLE_DWARF, GENETIC_MUTATION)

/datum/mutation/strong
	instability = 25
	power_coeff = 1
	var/list/affected_limbs = list(
		BODY_ZONE_L_ARM = null,
		BODY_ZONE_R_ARM = null,
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/datum/mutation/strong/Destroy()
	for(var/body_part as anything in affected_limbs)
		if(!isnull(affected_limbs[body_part]))
			unregister_limb(null, affected_limbs[body_part])
	return ..()

/datum/mutation/strong/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_BORG_PUNCHER, GENETIC_MUTATION)
	RegisterSignal(owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(register_limb))
	RegisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(unregister_limb))
	for(var/body_part as anything in affected_limbs)
		var/obj/item/bodypart/limb = owner.get_bodypart(check_zone(body_part))
		if(!limb)
			continue

		register_limb(owner, limb, initial = TRUE)

/datum/mutation/strong/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_BORG_PUNCHER, GENETIC_MUTATION)
	UnregisterSignal(owner, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_CARBON_POST_REMOVE_LIMB))
	for(var/body_part as anything in affected_limbs)
		var/obj/item/bodypart/limb = owner.get_bodypart(check_zone(body_part))
		if(!limb)
			continue

		unregister_limb(owner, limb)

/datum/mutation/strong/setup()
	. = ..()
	if(isnull(owner) || GET_MUTATION_POWER(src) == 1)
		return

	for(var/body_part as anything in affected_limbs)
		var/obj/item/bodypart/limb = affected_limbs[body_part]
		limb.unarmed_damage_low += ((2 * GET_MUTATION_POWER(src)) - 2) // Bit cursed? Yep. Works with any mutation power? Yep.
		limb.unarmed_damage_high += ((2 * GET_MUTATION_POWER(src)) - 2)

/datum/mutation/strong/proc/register_limb(mob/living/carbon/human/owner, obj/item/bodypart/new_limb, special, initial = FALSE)
	SIGNAL_HANDLER
	if(new_limb.body_zone == BODY_ZONE_HEAD || new_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[new_limb.body_zone] = new_limb
	RegisterSignal(new_limb, COMSIG_QDELETING, PROC_REF(limb_gone))
	if(initial)
		new_limb.unarmed_damage_low += 2
		new_limb.unarmed_damage_high += 2
		return

	new_limb.unarmed_damage_low += (2 * GET_MUTATION_POWER(src))
	new_limb.unarmed_damage_high += (2 * GET_MUTATION_POWER(src))

/datum/mutation/strong/proc/unregister_limb(mob/living/carbon/human/owner, obj/item/bodypart/lost_limb, special)
	SIGNAL_HANDLER
	if(lost_limb.body_zone == BODY_ZONE_HEAD || lost_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[lost_limb.body_zone] = null
	UnregisterSignal(lost_limb, COMSIG_QDELETING)
	lost_limb.unarmed_damage_low -= (2 * GET_MUTATION_POWER(src))
	lost_limb.unarmed_damage_high -= (2 * GET_MUTATION_POWER(src))

/datum/mutation/strong/proc/limb_gone(obj/item/bodypart/deleted_limb)
	SIGNAL_HANDLER
	if(affected_limbs[deleted_limb.body_zone])
		affected_limbs[deleted_limb.body_zone] = null
		UnregisterSignal(deleted_limb, COMSIG_QDELETING)

/datum/mutation/stimmed
	instability = 20
	power_coeff = 1

/datum/mutation/stimmed/on_life(seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_STASIS) || owner.stat == DEAD)
		return

	owner.reagents.remove_all(GET_MUTATION_POWER(src) * REM * seconds_per_tick)

/datum/mutation/acidflesh
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/acidflesh/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(13 / GET_MUTATION_ENERGY(src), seconds_per_tick))
		if(COOLDOWN_FINISHED(src, msgcooldown))
			to_chat(owner, span_danger("Your acid flesh bubbles..."))
			COOLDOWN_START(src, msgcooldown, 20 SECONDS)
		if(prob(15))
			owner.acid_act(rand(30, 50) * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_userdanger("Your bubbling flesh pops! It burns!"))
			playsound(owner,'sound/weapons/sear.ogg', 50, TRUE)

// you can't become double-giant
/datum/mutation/gigantism/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return

	if(acquirer && HAS_TRAIT_FROM(acquirer, TRAIT_GIANT, QUIRK_TRAIT))
		return FALSE

/datum/mutation/gigantism
	power_coeff = 1
	var/datum/component/tackling_component

/datum/mutation/gigantism/Destroy()
	tackling_component = null
	return ..()

/datum/mutation/gigantism/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(. || GET_MUTATION_POWER(src) <= 1)
		return
	QDEL_NULL(tackling_component)

/datum/mutation/gigantism/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1) // Psst, the tackling component's stats are just copied from the gorilla gloves, but doubled stamina cost
		tackling_component = owner.AddComponent(/datum/component/tackler, stamina_cost = 60, base_knockdown = 1.25 SECONDS, range = 5, speed = 1, skill_mod = 2, min_distance = 0)

/datum/mutation/spastic
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/spastic/setup()
	. = ..()
	if(isnull(owner))
		return

	var/datum/status_effect/spasms/status_effect = locate(/datum/status_effect/spasms) in owner.status_effects
	if(status_effect)
		status_effect.mutation_synchronizer = GET_MUTATION_SYNCHRONIZER(src)
		status_effect.mutation_power = GET_MUTATION_POWER(src)
		status_effect.mutation_energy = GET_MUTATION_ENERGY(src)

/datum/mutation/extrastun
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/// Triggers on moved(). Randomly makes the owner trip
/datum/mutation/extrastun/proc/on_move()
	SIGNAL_HANDLER

	if(prob(99.25 + (0.25 * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src)))) // The brawl mutation
		return
	if(owner.buckled || owner.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || owner.throwing || owner.movement_type & (VENTCRAWLING | FLYING | FLOATING))
		return // Remove the 'edge' cases
	to_chat(owner, span_danger("You trip over your own feet."))
	owner.Knockdown((3 SECONDS) * GET_MUTATION_POWER(src))

/datum/mutation/headless
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/headless/on_acquiring(mob/living/carbon/human/owner)
	if(!owner || !istype(owner))
		return FALSE

	var/obj/item/organ/internal/ears/cat/super/ears = owner.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears && istype(ears))
		return FALSE

	. = ..()

/datum/mutation/headless/setup()
	. = ..()
	if(isnull(owner))
		return

	var/obj/item/bodypart/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return

	if(GET_MUTATION_POWER(src) > 1)
		chest.receive_damage(10 * GET_MUTATION_POWER(src))

	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Keep in mind, when getting HARS we are guaranteed at LEAST 15 brute damage
		chest.heal_damage(5 / GET_MUTATION_SYNCHRONIZER(src))

/datum/mutation/radproof
	name = "Radproof"
	desc = "Adapts the host's body to be better suited at preventing cancer caused by radioactivity at the expense of it's ability to handle toxic matter."
	quality = POSITIVE
	text_gain_indication = span_warning("You can't feel it in your bones!")
	instability = 35
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/radproof/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_RADIMMUNE, GENETIC_MUTATION)
	owner.physiology?.tox_mod *= 1.5

/datum/mutation/radproof/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, GENETIC_MUTATION)
	owner.physiology?.tox_mod /= 1.5
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.tox_mod /= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_RADHEALING, GENETIC_MUTATION)

/datum/mutation/radproof/setup()
	. = ..()
	if(isnull(owner))
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.tox_mod *= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_RADHEALING, GENETIC_MUTATION)

/datum/mutation/thickskin
	name = "Thick skin"
	desc = "The user's skin acquires a leathery texture, and becomes more resilient to harm."
	quality = POSITIVE
	text_gain_indication = span_notice("Your skin feels dry and heavy.")
	text_lose_indication = span_notice("Your skin feels soft again...")
	instability = 30
	difficulty = 18
	power_coeff = 1

/datum/mutation/thickskin/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] += 10
	armorlist[BULLET] += 10
	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

/datum/mutation/thickskin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] -= 10
	armorlist[BULLET] -= 10
	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_EMBED_RESISTANCE, GENETIC_MUTATION)

/datum/mutation/thickskin/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_EMBED_RESISTANCE, GENETIC_MUTATION)

/datum/mutation/hypermarrow
	name = "Hyperactive Bone Marrow"
	desc = "A mutation that stimulates the subject's bone marrow causes it to work three times faster than usual."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones ache for a moment.")
	text_lose_indication = span_notice("You feel something in your bones calm down.")
	instability = 20
	difficulty = 12
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/hypermarrow/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(gain_blood))

/datum/mutation/hypermarrow/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		UnregisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/mutation/hypermarrow/proc/gain_blood(mob/living/carbon/human/gene_owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER // Btw the signal sender handles if our owner gets the no_blood trait after being injected
	if(gene_owner.stat == DEAD)
		return

	if(gene_owner.blood_volume <= BLOOD_VOLUME_NORMAL)
		gene_owner.blood_volume += (2 * GET_MUTATION_POWER(src) * seconds_per_tick - 1)
		gene_owner.adjust_nutrition((GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src) * seconds_per_tick - 0.8) * HUNGER_FACTOR)

/datum/mutation/bloodyhell // Technically could be easily made a child of bone marrow, but signals dont like that.
	name = "Polycythemia"
	desc = "A mutation that stimulates the subjects bone marrow's blood production capability and removes the subject's bone marrow's usual safeties against overproducing blood."
	quality = NEGATIVE
	text_gain_indication = span_warning("For a brief moment you feel a pain in your heart as you feel it beating faster.")
	text_lose_indication = span_notice("You feel your heart slowing down to its usual speed.")
	instability = 15
	conflicts = list(/datum/mutation/anemia)
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/bloodyhell/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(gain_blood))

/datum/mutation/bloodyhell/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		UnregisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/mutation/bloodyhell/proc/gain_blood(mob/living/carbon/human/gene_owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(gene_owner.stat == DEAD)
		return

	if(gene_owner.blood_volume > (BLOOD_VOLUME_NORMAL * 1.4))
		// We actually NEED to add effects here because normally you get NO downsides for excess blood
		var/blood_difference = (gene_owner.blood_volume / BLOOD_VOLUME_MAXIMUM) * 100
		if(SPT_PROB(blood_difference, seconds_per_tick))
			if(prob(20))
				to_chat(gene_owner, span_warning("You feel bloated."))
			gene_owner.adjustOxyLoss(floor(blood_difference / 20))

	if(gene_owner.blood_volume < BLOOD_VOLUME_MAXIMUM)
		gene_owner.blood_volume += (2 * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src) * seconds_per_tick)

/datum/mutation/anemia
	name = "Anemia"
	desc = "This mutation causes damage to the oxygen carrying properties of blood cells to a high degree in the subject."
	quality = NEGATIVE
	text_gain_indication = span_warning("You feel slightly woozy for a moment.") // No lose indicator, its a slow recovery
	instability = 10
	conflicts = list(/datum/mutation/bloodyhell)
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/anemia/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(lose_blood))

/datum/mutation/anemia/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		UnregisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/mutation/anemia/proc/lose_blood(mob/living/carbon/human/gene_owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(gene_owner.stat == DEAD)
		return

	if(gene_owner.blood_volume > BLOOD_VOLUME_SAFE - (75 * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src)))
		gene_owner.blood_volume -= (seconds_per_tick)

/datum/mutation/densebones
	name = "Bone Densification"
	desc = "A mutation that gives the subject a rare form of increased bone density, making their entire body slightly more resilient to low kinetic blows."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones get denser.")
	text_lose_indication = span_notice("You feel your bones get lighter.")
	instability = 25
	difficulty = 16
	power_coeff = 1

/datum/mutation/densebones/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] += 5
	armorlist[WOUND] += 10
	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

/datum/mutation/densebones/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	var/datum/armor/owner_armor = owner.get_armor()
	var/list/armorlist = owner_armor.get_rating_list()
	armorlist[MELEE] -= 5
	armorlist[WOUND] -= 10
	owner.set_armor(owner_armor.generate_new_with_specific(armorlist))

	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)

/datum/mutation/densebones/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)

/datum/mutation/cerebral
	name = "Cerebral Neuroplasticity"
	desc = "A mutation that reorganizes the subject's brain, giving them more stamina while allowing for a slightly quicker recovery speed if exhausted."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your brain get sturdier.")
	text_lose_indication = span_notice("You feel your brain getting weaker. ")
	instability = 60
	power_coeff = 1

/datum/mutation/cerebral/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	owner.physiology?.stamina_mod *= 0.7
	owner.physiology?.stun_mod *= 0.85

/datum/mutation/cerebral/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.physiology?.stamina_mod /= 0.7
	owner.physiology?.stun_mod /= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		owner.physiology?.stamina_mod /= 0.85
		owner.physiology?.stun_mod /= 0.925

/datum/mutation/cerebral/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		owner.physiology?.stamina_mod *= 0.85
		owner.physiology?.stun_mod *= 0.925

/datum/mutation/fat
	name = "Obesity"
	desc = "A strange mutation that forces the body to rapidly produce lipid tissue."
	quality = NEGATIVE
	text_gain_indication = span_notice("You feel blubbery and lethargic!")
	text_lose_indication = span_notice("You feel fit!")

/datum/mutation/fat/on_life(seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_STASIS) || owner.stat == DEAD)
		return

	if(owner.nutrition <= NUTRITION_LEVEL_FAT)
		owner.nutrition += 25 * seconds_per_tick

/datum/mutation/horned
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("A pair of horns erupt from your head.")
	text_lose_indication = span_notice("Your horns crumble away into nothing.")

/datum/mutation/horned/on_acquiring(mob/living/carbon/human/owner)
	if(!owner || !istype(owner)) // Parent checks this, but we want to be safe when doing get_organ_slot
		return FALSE

	// First time something does get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS) btw, for very understandable reasons
	var/obj/item/organ/external/horns/owner_horns = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS)
	if(owner_horns)
		return FALSE // Lets not de-horn people with horns, that'd be very rude

	. = ..()
	if(!.)
		return

	var/obj/item/organ/external/horns/horns = new()
	horns.Insert(owner)

/datum/mutation/horned/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	// Second time something does get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS)
	var/obj/item/organ/external/horns/owner_horns = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS)
	if(owner_horns)
		qdel(owner_horns)

/datum/mutation/no_fingerprints
	name = "Invisible Fingerprints"
	desc = "Subjects finger tips melt into a singular smooth structure, causing their fingerprints to be impossible to detect."
	quality = POSITIVE
	text_gain_indication = span_notice("Your fingers feel numb.")
	text_lose_indication = span_notice("Your fingers no longer feel numb.")
	instability = 10

/datum/mutation/no_fingerprints/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_NO_FINGERPRINTS, GENETIC_MUTATION)

/datum/mutation/no_fingerprints/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_NO_FINGERPRINTS, GENETIC_MUTATION)

/datum/mutation/no_breath
	name = "Automatic Respiration"
	desc = "Subjects lungs begin to recycle CO2 into oxygen aided with melting the subjects airpipe shut making them have no need for air."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel no need to breathe.")
	text_lose_indication = span_notice("You feel the need to breathe, once more.")
	instability = 30
	difficulty = 14

/datum/mutation/no_breath/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/no_breath/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/dizzy
	name = "Dizzy"
	desc = "Causes the subjects cerebellum to shut down in certain places causing dizzyness."
	quality = NEGATIVE
	text_gain_indication = span_danger("You suddenly start feeling very dizzy...")
	text_lose_indication = span_notice("You regain your balance.")
	instability = 15
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/dizzy/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(2.5 / GET_MUTATION_ENERGY(src), seconds_per_tick))
		to_chat(owner, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
		owner.adjust_dizzy_up_to(1 MINUTE * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 3 MINUTES)

/datum/mutation/ear_cancer
	name = "Tinnitus"
	desc = "Causes the subjects to constantly hear a ringing noise."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_warning("You start hearing ringing in your ears.")
	text_lose_indication = span_notice("You no longer bleed from your ears.")
	instability = 5
	synchronizer_coeff = 1

/datum/mutation/ear_cancer/on_life(seconds_per_tick, times_fired)
	var/obj/item/organ/internal/ears/ears = owner.get_organ_slot(ORGAN_SLOT_EARS) // RIP THEM OUT TO STOP THE NOISE
	if(ears && SPT_PROB(5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick))
		to_chat(owner, span_warning("Your ears start to ring!"))
		SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg', 0, 1, 0, 250))
