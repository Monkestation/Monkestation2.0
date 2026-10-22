/datum/species/golem/cloth
	name = "Cloth Golem"
	id = SPECIES_GOLEM_CLOTH
	sexes = FALSE
	info_text = "As a <span class='danger'>Cloth Golem</span>, you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable. \
	Being made of cloth, your body is immune to spirits of the damned and runic golems. You are faster than that of other golems, but weaker and less resilient."
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	armor = 15 //feels no pain, but not too resistant
	burnmod = 2 // don't get burned
	prefix = "Cloth"
	special_names = null
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cloth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cloth,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cloth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cloth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cloth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cloth,
	)

/datum/species/golem/cloth/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/cloth/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

/datum/species/golem/cloth/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/golem/cloth/random_name(gender,unique,lastname)
	var/pharaoh_name = pick("Neferkare", "Hudjefa", "Khufu", "Mentuhotep", "Ahmose", "Amenhotep", "Thutmose", "Hatshepsut", "Tutankhamun", "Ramses", "Seti", \
	"Merenptah", "Djer", "Semerkhet", "Nynetjer", "Khafre", "Pepi", "Intef", "Ay") //yes, Ay was an actual pharaoh
	var/golem_name = "[pharaoh_name] \Roman[rand(1,99)]"
	return golem_name

/datum/species/golem/cloth/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/golem/cloth/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.on_fire)
		H.visible_message(span_danger("[H] burns into ash!"))
		H.dust(just_ash = TRUE)
		return

	H.visible_message(span_danger("[H] falls apart into a pile of bandages!"))
	new /obj/structure/cloth_pile(get_turf(H), H)
	..()

/datum/species/golem/cloth/get_species_description()
	return "A wrapped up Mummy! They descend upon Space Station Thirteen every year to spook the crew! \"Return the slab!\""


// Calls parent, as Golems have a species-wide perk we care about.
/datum/species/golem/cloth/create_pref_unique_perks()
	var/list/to_add = ..()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "recycle",
		SPECIES_PERK_NAME = "Reformation",
		SPECIES_PERK_DESC = "A boon quite similar to Ethereals, Mummies collapse into \
			a pile of bandages after they die. If left alone, they will reform back \
			into themselves. The bandages themselves are very vulnerable to fire.",
	))

	return to_add

// Override to add a perk elaborating on just how dangerous fire is.
/datum/species/golem/cloth/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "fire-alt",
		SPECIES_PERK_NAME = "Incredibly Flammable",
		SPECIES_PERK_DESC = "Mummies are made entirely of cloth, which makes them \
			very vulnerable to fire. They will not reform if they die while on \
			fire, and they will easily catch alight. If your bandages burn to ash, you're toast!",
	))

	return to_add

/obj/structure/cloth_pile
	name = "pile of bandages"
	desc = "It emits a strange aura, as if there was still life within it..."
	max_integrity = 50
	armor_type = /datum/armor/structure_cloth_pile
	icon = 'icons/obj/objects.dmi'
	icon_state = "pile_bandages"
	resistance_flags = FLAMMABLE

	var/revive_time = 90 SECONDS
	var/mob/living/carbon/human/cloth_golem

/datum/armor/structure_cloth_pile
	melee = 90
	bullet = 90
	laser = 25
	energy = 80
	bomb = 50
	fire = -50
	acid = -50

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.unequip_everything()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, span_notice("You start gathering your life energy, preparing to rise again..."))
		addtimer(CALLBACK(src, PROC_REF(revive)), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/burn()
	visible_message(span_danger("[src] burns into ash!"))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(HAS_TRAIT_FROM_ONLY(cloth_golem, TRAIT_SUICIDED, REF(cloth_golem)))
		QDEL_NULL(cloth_golem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/mummy_animation(get_turf(src))
	cloth_golem.revive(ADMIN_HEAL_ALL)
	sleep(2 SECONDS)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message(span_danger("[src] rises and reforms into [cloth_golem]!"),span_userdanger("You reform into yourself!"))
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.get_temperature())
		visible_message(span_danger("[src] bursts into flames!"))
		fire_act()
