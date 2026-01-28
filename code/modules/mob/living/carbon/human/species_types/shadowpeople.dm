#define HEART_RESPAWN_THRESHHOLD 40
#define HEART_SPECIAL_SHADOWIFY 2
///cooldown between charges of the projectile absorb
#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Basic shadow person species---------------------------//
////////////////////////////////////////////////////////////////////////////////////

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadow"
	plural_form = "Shadowpeople"
	id = SPECIES_SHADOW
	sexes = 0
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NODISMEMBER,
	)
	inherent_factions = list(FACTION_FAITHLESS)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC

	mutantbrain = /obj/item/organ/internal/brain/shadow
	mutanteyes = /obj/item/organ/internal/eyes/shadow
	mutantheart = null
	mutantlungs = null

	///If the darkness healing heals all damage types, not just brute and burn
	var/powerful_heal = FALSE
	///How much damage is healed each life tick
	var/dark_healing = 1
	///How much burn damage is taken each life tick, reduced to 20% for dim light
	var/light_burning = 1
	///How many charges their projectile protection has
	var/shadow_charges = 0

	species_language_holder = /datum/language_holder/darkspawn

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)

/datum/species/shadow/proc/regen_shadow()
	shadow_charges = min(shadow_charges++, initial(shadow_charges))

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	. = ..()
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = GET_SIMPLE_LUMCOUNT(T)
		switch(light_amount)
			if(0 to SHADOW_SPECIES_DIM_LIGHT)
				var/list/healing_types = list(CLONE, BURN, BRUTE)
				if(powerful_heal)
					healing_types |= list(STAMINA, TOX, OXY, BRAIN) //heal additional damage types
					H.AdjustAllImmobility(-dark_healing * 40)
					H.SetSleeping(0)
				H.heal_ordered_damage(dark_healing, healing_types)
			if(SHADOW_SPECIES_DIM_LIGHT to SHADOW_SPECIES_BRIGHT_LIGHT) //not bright, but still dim
				var/datum/antagonist/darkspawn/dude = IS_DARKSPAWN(H)
				if(dude)
					if(HAS_TRAIT(dude, TRAIT_DARKSPAWN_LIGHTRES))
						return
					if(HAS_TRAIT(dude, TRAIT_DARKSPAWN_CREEP))
						return
				to_chat(H, span_userdanger("The light singes you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 40 * light_amount), TRUE)
				H.adjustCloneLoss(light_burning * 0.2)
			if(SHADOW_SPECIES_BRIGHT_LIGHT to INFINITY) //but quick death in the light
				var/datum/antagonist/darkspawn/dude = IS_DARKSPAWN(H)
				if(dude)
					if(HAS_TRAIT(dude, TRAIT_DARKSPAWN_CREEP))
						return
				to_chat(H, span_userdanger("The light burns you!"))
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
				H.adjustCloneLoss(light_burning)

/datum/species/shadow/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/shadow/get_species_description()
	return "Victims of a long extinct space alien. Their flesh is a sickly \
		seethrough filament, their tangled insides in clear view. Their form \
		is a mockery of life, leaving them mostly unable to work with others under \
		normal circumstances."

/datum/species/shadow/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Shadowborn",
			SPECIES_PERK_DESC = "Their skin blooms in the darkness. All kinds of damage, \
				no matter how extreme, will heal over time as long as there is no light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Nightvision",
			SPECIES_PERK_DESC = "Their eyes are adapted to the night, and can see in the dark with no problems.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Lightburn",
			SPECIES_PERK_DESC = "Their flesh withers in the light. Any exposure to light is \
				incredibly painful for the shadowperson, charring their skin.",
		),
	)

	return to_add

/// the key to some of their powers
/obj/item/organ/internal/brain/shadow
	name = "shadowling tumor"
	desc = "Something that was once a brain, before being remolded by a shadowling. It has adapted to the dark, irreversibly."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

/obj/item/organ/internal/brain/shadow/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return
	var/light_amount = GET_SIMPLE_LUMCOUNT(owner_turf)
	var/delta_time = min(round(DELTA_WORLD_TIME(SSclient_mobs), 0.1), 8) // compensate for lag, but avoid potentially taking a shitload of damage all at once

	// 1 damage per second
	if(light_amount >= SHADOW_SPECIES_DIM_LIGHT) //if there's enough light, start dying
		var/datum/antagonist/darkspawn/darkspawn = IS_DARKSPAWN(owner)
		if(darkspawn)
			if(HAS_TRAIT(darkspawn, TRAIT_DARKSPAWN_LIGHTRES) || HAS_TRAIT(darkspawn, TRAIT_DARKSPAWN_CREEP))
				return
		owner.take_overall_damage(brute = delta_time, burn = delta_time, required_bodytype = BODYTYPE_ORGANIC)
	else //heal in the dark
		owner.heal_overall_damage(brute = delta_time, burn = delta_time, required_bodytype = BODYTYPE_ORGANIC)

/obj/item/organ/internal/eyes/shadow
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	color_cutoffs = list(20, 10, 40)
	pepperspray_protect = TRUE

////////////////////////////////////////////////////////////////////////////////////
//------------------------Midround antag exclusive species------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * A highly aggressive subset of shadowlings
 */
/datum/species/shadow/nightmare
	name = "Nightmare"
	id = SPECIES_NIGHTMARE
	examine_limb_id = SPECIES_SHADOW
	burnmod = 1.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NOBLOOD,
		// monkestation addition: pain system
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
		// monkestation end
	)

	mutantheart = /obj/item/organ/internal/heart/nightmare
	mutantbrain = /obj/item/organ/internal/brain/shadow/nightmare
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/nightmare,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/nightmare,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)
	shadow_charges = 1

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE

////////////////////////////////////////////////////////////////////////////////////
//----------------------Roundstart antag exclusive species------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/species/shadow/darkspawn
	name = "Darkspawn"
	id = SPECIES_DARKSPAWN
	examine_limb_id = SPECIES_DARKSPAWN
	changesource_flags = MIRROR_BADMIN //never put this in the pride pool because they look super valid and can never be changed off of
	siemens_coeff = 0
	armor = 10
	brutemod = 0.8
	burnmod = 1
	heatmod = 1.5
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE | ITEM_SLOT_EYES
	inherent_traits = list(
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_HUSK,
		TRAIT_NOBLOOD,
		TRAIT_NOGUNS,
		TRAIT_NO_JUMPSUIT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_GENELESS,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOGUNS,
		TRAIT_SPECIESLOCK, //never let them swap off darkspawn, it can cause issues
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
		TRAIT_NEVER_WOUNDED,
		)
	mutanteyes = /obj/item/organ/internal/eyes/darkspawn
	mutantears = /obj/item/organ/internal/ears/darkspawn

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow/darkspawn,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow/darkspawn,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/darkspawn,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/darkspawn,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow/darkspawn,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow/darkspawn,
	)

	powerful_heal = TRUE
	shadow_charges = 3

/datum/species/shadow/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.fully_replace_character_name(null, nightmare_name())

/datum/species/shadow/darkspawn/spec_updatehealth(mob/living/carbon/human/H)
	var/datum/antagonist/darkspawn/antag = IS_DARKSPAWN(H)
	if(antag)
		dark_healing = antag.dark_healing
		light_burning = antag.light_burning
		if(H.physiology)
			H.physiology.brute_mod = antag.brute_mod
			H.physiology.burn_mod = antag.burn_mod
			H.physiology.stamina_mod = antag.stam_mod

/datum/species/shadow/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'sound/creatures/darkspawn/darkspawn_death.ogg', 50, FALSE)

/datum/species/shadow/darkspawn/check_roundstart_eligible()
	return FALSE

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Darkspawn organs----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/organ/internal/eyes/darkspawn //special eyes that innately have night vision without having a toggle that adds action clutter
	name = "darkspawn eyes"
	desc = "It turned out they had them after all!"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD //far more durable eyes than most
	healing_factor = 2 * STANDARD_ORGAN_HEALING
	lighting_cutoff = LIGHTING_CUTOFF_HIGH
	color_cutoffs = list(12, 0, 50)
	sight_flags = SEE_MOBS

/obj/item/organ/internal/ears/darkspawn //special ears that are a bit tankier and have innate sound protection
	name = "darkspawn ears"
	desc = "It turned out they had them after all!"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD //far more durable ears than most
	healing_factor = 2 * STANDARD_ORGAN_HEALING
	bang_protect = 1

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Nightmare organs----------------------------------//
////////////////////////////////////////////////////////////////////////////////////

/obj/item/organ/internal/brain/shadow/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-x-d"
	///Our associated shadow jaunt spell, for all nightmares
	var/datum/action/cooldown/spell/jaunt/shadow_walk/our_jaunt
	///Our associated terrorize spell, for antagonist nightmares
	var/datum/action/cooldown/spell/pointed/terrorize/terrorize_spell

/obj/item/organ/internal/brain/shadow/nightmare/on_insert(mob/living/carbon/brain_owner)
	. = ..()
	if(brain_owner.dna.species.id != SPECIES_NIGHTMARE)
		brain_owner.set_species(/datum/species/shadow/nightmare)
		visible_message(span_warning("[brain_owner] thrashes as [src] takes root in [brain_owner.p_their()] body!"))

	our_jaunt = new(brain_owner)
	our_jaunt.Grant(brain_owner)

	if(brain_owner.mind?.has_antag_datum(/datum/antagonist/nightmare)) //Only a TRUE NIGHTMARE is worthy of using this ability
		terrorize_spell = new(src)
		terrorize_spell.Grant(brain_owner)

	RegisterSignal(brain_owner, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(dodge_bullets))

/obj/item/organ/internal/brain/shadow/nightmare/on_remove(mob/living/carbon/brain_owner)
	. = ..()
	QDEL_NULL(our_jaunt)
	QDEL_NULL(terrorize_spell)
	UnregisterSignal(brain_owner, COMSIG_ATOM_PRE_BULLET_ACT)

/obj/item/organ/internal/brain/shadow/nightmare/proc/dodge_bullets(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	var/turf/dodge_turf = source.loc
	SEND_SIGNAL(source, COMSIG_NIGHTMARE_SNUFF_CHECK, dodge_turf) // monkestation edit
	if(!istype(dodge_turf) || dodge_turf.get_lumcount() >= SHADOW_SPECIES_DIM_LIGHT)
		return NONE
	source.visible_message(
		span_danger("[source] dances in the shadows, evading [hitting_projectile]!"),
		span_danger("You evade [hitting_projectile] with the cover of darkness!"),
	)
	playsound(source, SFX_BULLET_MISS, 75, TRUE)
	return COMPONENT_BULLET_PIERCED

/obj/item/organ/internal/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "demon_heart-on"
	visual = TRUE
	color = "#1C1C1C"
	decay_factor = 0
	/// How many life ticks in the dark the owner has been dead for. Used for nightmare respawns.
	var/respawn_progress = 0
	/// The armblade granted to the host of this heart.
	var/obj/item/light_eater/nightmare/blade

/obj/item/organ/internal/heart/nightmare/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/organ/internal/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(
		span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"),
		span_danger("[src] feels unnaturally cold in your hands. You raise [src] to your mouth and devour it!")
	)
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)

	user.visible_message(
		span_warning("Blood erupts from [user]'s arm as it reforms into a weapon!"),
		span_userdanger("Icy blood pumps through your veins as your arm reforms itself!")
	)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/internal/heart/nightmare/on_insert(mob/living/carbon/heart_owner, special)
	. = ..()
	if(special != HEART_SPECIAL_SHADOWIFY)
		blade = new/obj/item/light_eater/nightmare
		heart_owner.put_in_hands(blade)

/obj/item/organ/internal/heart/nightmare/on_remove(mob/living/carbon/heart_owner, special)
	. = ..()
	respawn_progress = 0
	if(blade && special != HEART_SPECIAL_SHADOWIFY)
		heart_owner.visible_message(span_warning("\The [blade] disintegrates!"))
		QDEL_NULL(blade)

/obj/item/organ/internal/heart/nightmare/Stop()
	return 0

/obj/item/organ/internal/heart/nightmare/on_death(seconds_per_tick, times_fired)
	if(!owner)
		return
	var/turf/T = get_turf(owner)
	if(istype(T))
		var/light_amount = GET_SIMPLE_LUMCOUNT(T)
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			respawn_progress += seconds_per_tick SECONDS
			playsound(owner, 'sound/effects/singlebeat.ogg', 40, TRUE)
	if(respawn_progress < HEART_RESPAWN_THRESHHOLD)
		return

	owner.revive(HEAL_ALL & ~HEAL_REFRESH_ORGANS, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	if(!(owner.dna.species.id == SPECIES_SHADOW || owner.dna.species.id == SPECIES_NIGHTMARE))
		var/mob/living/carbon/old_owner = owner
		Remove(owner, HEART_SPECIAL_SHADOWIFY)
		old_owner.set_species(/datum/species/shadow)
		Insert(old_owner, HEART_SPECIAL_SHADOWIFY)
		to_chat(owner, span_userdanger("You feel the shadows invade your skin, leaping into the center of your chest! You're alive!"))
		SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
	owner.visible_message(span_warning("[owner] staggers to [owner.p_their()] feet!"))
	playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	respawn_progress = 0

//Weapon
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/darkspawn_items.dmi'
	icon_state = "light_eater"
	inhand_icon_state  = "light_eater"
	force = 18
	lefthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	wound_bonus = -40
	resistance_flags = ACID_PROOF

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/light_eater)

/obj/item/light_eater/worn_overlays(mutable_appearance/standing, isinhands, icon_file) //this doesn't work and i have no clue why
	. = ..()
	if(isinhands)
		if(!istype(src, /obj/item/light_eater/nightmare))
			. += emissive_appearance(icon, "[inhand_icon_state]_emissive", src)

#undef DARKSPAWN_REFLECT_COOLDOWN
#undef HEART_SPECIAL_SHADOWIFY
#undef HEART_RESPAWN_THRESHHOLD

