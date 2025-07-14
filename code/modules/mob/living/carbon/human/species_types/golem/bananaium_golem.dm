//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	id = SPECIES_GOLEM_BANANIUM
	fixed_mut_color = "#ffff00"
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_CLUMSY,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)
	mutanttongue = /obj/item/organ/internal/tongue/bananium
	meat = /obj/item/stack/ore/bananium
	info_text = "As a <span class='danger'>Bananium Golem</span>, you are made for pranking. Your body emits natural honks, and you can barely even hurt people when punching them. Your skin also bleeds banana peels when damaged."
	prefix = "Bananium"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/bananium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/bananium,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/bananium,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/bananium,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

	/// Cooldown for producing honks
	COOLDOWN_DECLARE(honkooldown)
	/// Cooldown for producing bananas
	COOLDOWN_DECLARE(banana_cooldown)
	/// Time between possible banana productions
	var/banana_delay = 10 SECONDS
	/// Same as the uranium golem. I'm pretty sure this is vestigial.
	var/active = FALSE

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	COOLDOWN_START(src, honkooldown, 0)
	COOLDOWN_START(src, banana_cooldown, banana_delay)
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	var/obj/item/organ/internal/liver/liver = C.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		ADD_TRAIT(liver, TRAIT_COMEDY_METABOLISM, SPECIES_TRAIT)

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

	var/obj/item/organ/internal/liver/liver = C.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		REMOVE_TRAIT(liver, TRAIT_COMEDY_METABOLISM, SPECIES_TRAIT)

/datum/species/golem/bananium/random_name(gender,unique,lastname)
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[uppertext(clown_name)]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(COOLDOWN_FINISHED(src, banana_cooldown) && M != H && (M.istate & ISTATE_HARM))
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if((user != H) && COOLDOWN_FINISHED(src, banana_cooldown))
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(isitem(AM))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(!active && COOLDOWN_FINISHED(src, honkooldown))
		active = TRUE
		playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, TRUE)
		COOLDOWN_START(src, honkooldown, rand(2 SECONDS, 8 SECONDS))
		active = FALSE
	..()

/datum/species/golem/bananium/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, FALSE)

/datum/species/golem/bananium/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_CLOWN
