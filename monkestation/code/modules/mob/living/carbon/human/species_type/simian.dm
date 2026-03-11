/datum/species/monkey/simian
	name = "Simian"
	id = SPECIES_SIMIAN
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
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

/datum/species/monkey/simian/get_species_lore()
	return list(
		"Simians have always been looked down upon. Stolen from Ooga-9 as throwaway test subjects, \
		these sentient apes have been fighting for their freedom as long as Nanotrasen records go, \
		through a secret organization called Jungle Fever.",

		"Once the Monkey Cube was created however, Nanotrasen no longer saw use for using sentient creatures, \
		and granted Simians basic rights and continued employment at the corporation.",

		"This was a great happenstance for the orgnization, which suddenly gained a massive following as it suddenly became legal \
		and was even praised for their work in the Simian resistance. \
		This eventually led to bankrolling from large simian-owned companies such as Bananotrasen.",

		"Their organization collectivizes itself through what they call the Alpha, the one wielding the largest stick.",
	)

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

///The Simian Big Stick. I found it in the forest and kept it.
/obj/item/staff/big_stick
	name = "big stick"
	desc = "A big stick, probably found in the latest trip to the forest. God it looks cool though."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throw_speed = 0.1
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/stick.dmi'
	worn_icon = 'icons/mob/clothing/back/stick.dmi'
	icon_state = "stick"
	base_icon_state = "stick"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	block_chance = 40

	///The simian holding the stick. Eek ook.
	var/mob/living/simian_affected

/obj/item/staff/big_stick/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 10, \
		force_wielded = 14, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/staff/big_stick/Destroy(force)
	simian_affected = null
	return ..()

/obj/item/staff/big_stick/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/staff/big_stick/equipped(mob/living/user, slot, initial)
	if(!issimianspecies(user))
		return ..()
	ADD_TRAIT(src, TRAIT_BLIND_TOOL, INNATE_TRAIT)
	AddComponent(/datum/component/limbless_aid)
	. = ..()
	simian_affected = user
	simian_affected.hud_add_simian_alpha()
	RegisterSignal(simian_affected, COMSIG_SPECIES_LOSS, PROC_REF(on_species_change))
	RegisterSignal(simian_affected, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

/obj/item/staff/big_stick/dropped(mob/living/user, silent)
	remove_effects()
	return ..()

///When the simian holding us swaps species, we're no longer a 'simian' so aren't an Alpha anymore.
/obj/item/staff/big_stick/proc/on_species_change(mob/living/carbon/source, datum/species/lost_species)
	SIGNAL_HANDLER
	remove_effects()

///Called when examined, Simians get a special text for stick holders.
/obj/item/staff/big_stick/proc/on_examined(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(issimianspecies(user))
		examine_list += span_danger("[source.p_theyre(TRUE)] wielding the big stick! They are the Leader of the Simians!")

/obj/item/staff/big_stick/proc/remove_effects()
	REMOVE_TRAIT(src, TRAIT_BLIND_TOOL, INNATE_TRAIT)
	qdel(GetComponent(/datum/component/limbless_aid))
	if(isnull(simian_affected))
		return
	simian_affected.hud_remove_simian_alpha()
	UnregisterSignal(simian_affected, COMSIG_SPECIES_LOSS)
	simian_affected = null
