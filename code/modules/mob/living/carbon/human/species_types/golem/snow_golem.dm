/datum/species/golem/snow
	name = "Snow Golem"
	id = SPECIES_GOLEM_SNOW
	fixed_mut_color = null //custom sprites
	armor = 45 //down from 55
	burnmod = 3 //melts easily
	info_text = "As a <span class='danger'>Snow Golem</span>, you are extremely vulnerable to burn damage, but you can generate snowballs and shoot cryokinetic beams. You will also turn to snow when dying, preventing any form of recovery."
	prefix = "Snow"
	special_names = list("Flake", "Blizzard", "Storm")
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
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/snow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/snow,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/snow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/snow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/snow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/snow,
	)

	/// A ref to our "throw snowball" spell we get on species gain.
	var/datum/action/cooldown/spell/conjure_item/snowball/snowball
	/// A ref to our cryobeam spell we get on species gain.
	var/datum/action/cooldown/spell/pointed/projectile/cryo/cryo

/datum/species/golem/snow/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] turns into a pile of snow!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/sheet/mineral/snow(get_turf(H))
	new /obj/item/food/grown/carrot(get_turf(H))
	qdel(H)

/datum/species/golem/snow/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_SNOWSTORM_IMMUNE, SPECIES_TRAIT)

	snowball = new(grant_to)
	snowball.StartCooldown()
	snowball.Grant(grant_to)

	cryo = new(grant_to)
	cryo.StartCooldown()
	cryo.Grant(grant_to)

/datum/species/golem/snow/on_species_loss(mob/living/carbon/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_SNOWSTORM_IMMUNE, SPECIES_TRAIT)
	QDEL_NULL(snowball)
	QDEL_NULL(cryo)
	return ..()
