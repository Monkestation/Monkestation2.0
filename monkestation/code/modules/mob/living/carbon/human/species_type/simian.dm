/datum/species/monkey/simian
	name = "Simian"
	id = SPECIES_SIMIAN
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_AUGMENTS, //Their bodytype doesn't allow augments, this prevents the futile effort.
		TRAIT_MUTANT_COLORS,
		TRAIT_FUR_COLORS,
		//Simian unique traits
		TRAIT_VAULTING,
		TRAIT_MONKEYFRIEND,
		/*Monkey traits that Simians don't have, and why.
		TRAIT_NO_BLOOD_OVERLAY, //let's them have a blood overlay, why not?
		TRAIT_NO_TRANSFORMATION_STING, //Simians are a roundstart species and can equip all, unlike monkeys.
		TRAIT_GUN_NATURAL, //Simians are Advanced tool users, this lets monkeys use guns without being smart.
		TRAIT_VENTCRAWLER_NUDE, //We don't want a roundstart species that can ventcrawl.
		TRAIT_WEAK_SOUL, //Crew innately giving less to Revenants for no real reason sucks for the rev.
		*/
	)

	//they get a normal brain instead of a monkey one,
	//which removes the tripping stuff and gives them literacy/advancedtooluser and removes primitive (unable to use mechs)
	mutantbrain = /obj/item/organ/internal/brain
	no_equip_flags = NONE
	changesource_flags = parent_type::changesource_flags & ~(WABBAJACK | SLIME_EXTRACT)
	maxhealthmod = 0.85 //small = weak
	stunmod = 1.3
	payday_modifier = 1

	species_race_mutation = /datum/mutation/race/simian
	give_monkey_species_effects = FALSE

/datum/species/monkey/simian/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	var/datum/atom_hud/data/human/simian/simian_hud = GLOB.huds[DATA_HUD_SIMIAN]
	simian_hud.show_to(human_who_gained_species)

/datum/species/monkey/simian/on_species_loss(mob/living/carbon/human/C)
	var/datum/atom_hud/data/human/simian/simian_hud = GLOB.huds[DATA_HUD_SIMIAN]
	simian_hud.hide_from(C)
	return ..()


/datum/species/monkey/simian/get_species_description()
	return "Simians are the closest siblings to Humans, unlike Monkeys, which is a term reserved for bio-engineered and mass produced \
		creations that can be packaged into a cube, known as the Monkey Cube."

/datum/species/monkey/simian/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Little Monke",
			SPECIES_PERK_DESC = "You are a weak being, and have less health than most.", // 0.85% health
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Simians run slightly faster than other species, but are still outpaced by Goblins.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Vaulting",
			SPECIES_PERK_DESC = "Simians vault over tables instead of climbing them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Easy to Keep Down",
			SPECIES_PERK_DESC = "You get back up slower from stuns.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart",
			SPECIES_PERK_NAME = "Ape Not Kill Ape",
			SPECIES_PERK_DESC = "Monkeys like you more and won't attack you. Gorillas will though.",
		),
	)

	return to_add

/datum/species/monkey/simian/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_simian_name(gender)

	var/randname = simian_name(gender)
	if(lastname)
		randname += " [lastname]"
	return randname

/datum/species/monkey/simian/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	var/obj/item/clothing/mask/translator/simian_translator = new /obj/item/clothing/mask/translator(equipping.loc)
	equipping.equip_to_slot(simian_translator, ITEM_SLOT_NECK)



/obj/item/staff/big_stick
	name = "big stick"
	desc = "A big stick, probably found in the latest trip to the forest. God it looks cool though."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throw_speed = 2
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	block_chance = 40

	var/datum/mind/last_simian

/obj/item/staff/big_stick/Initialize(mapload)
	. = ..()
/*
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 10, \
		force_wielded = 24, \
		icon_wielded = "[base_icon_state]1", \
	)
*/
/obj/item/staff/big_stick/Destroy(force)
	last_simian = null
	return ..()

/obj/item/staff/big_stick/equipped(mob/living/user, slot, initial)
	. = ..()
	if(!issimianspecies(user))
		return
	last_simian = user.mind
	user.hud_add_simian_alpha()

/obj/item/staff/big_stick/dropped(mob/living/user, silent)
	last_simian?.current?.hud_remove_simian_alpha()
	last_simian = null
	return ..()

/*
/obj/item/staff/big_stick/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()
*/
