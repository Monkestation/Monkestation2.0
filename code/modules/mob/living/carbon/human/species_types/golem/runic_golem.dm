/datum/species/golem/runic
	name = "Runic Golem"
	id = SPECIES_GOLEM_CULT
	sexes = FALSE
	info_text = "As a <span class='danger'>Runic Golem</span>, you possess eldritch powers granted by the Elder Goddess Nar'Sie."
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_NOBLOOD,
	)
	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	prefix = "Runic"
	special_names = null
	inherent_factions = list(FACTION_CULT)
	species_language_holder = /datum/language_holder/golem/runic
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cult,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cult,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cult,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cult,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cult,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cult,
	)

	/// A ref to our jaunt spell that we get on species gain.
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/golem/jaunt
	/// A ref to our gaze spell that we get on species gain.
	var/datum/action/cooldown/spell/pointed/abyssal_gaze/abyssal_gaze
	/// A ref to our dominate spell that we get on species gain.
	var/datum/action/cooldown/spell/pointed/dominate/dominate

/datum/species/golem/runic/random_name(gender,unique,lastname)
	var/edgy_first_name = pick("Razor","Blood","Dark","Evil","Cold","Pale","Black","Silent","Chaos","Deadly","Coldsteel")
	var/edgy_last_name = pick("Edge","Night","Death","Razor","Blade","Steel","Calamity","Twilight","Shadow","Nightmare") //dammit Razor Razor
	var/golem_name = "[edgy_first_name] [edgy_last_name]"
	return golem_name

/datum/species/golem/runic/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species)
	. = ..()
	// Create our species specific spells here.
	// Note we link them to the mob, not the mind,
	// so they're not moved around on mindswaps
	jaunt = new(grant_to)
	jaunt.StartCooldown()
	jaunt.Grant(grant_to)

	abyssal_gaze = new(grant_to)
	abyssal_gaze.StartCooldown()
	abyssal_gaze.Grant(grant_to)

	dominate = new(grant_to)
	dominate.StartCooldown()
	dominate.Grant(grant_to)

/datum/species/golem/runic/on_species_loss(mob/living/carbon/C)
	// Aaand cleanup our species specific spells.
	// No free rides.
	QDEL_NULL(jaunt)
	QDEL_NULL(abyssal_gaze)
	QDEL_NULL(dominate)
	return ..()

/datum/species/golem/runic/handle_chemical(datum/reagent/chem, mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	if(istype(chem, /datum/reagent/water/holywater))
		H.adjustFireLoss(4 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)

	if(chem.type == /datum/reagent/fuel/unholywater)
		H.adjustBruteLoss(-4 * REM * seconds_per_tick)
		H.adjustFireLoss(-4 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
