//Radioactive puncher, hits for burn but only as hard as human, slightly more durable against brute but less against everything else
/datum/species/golem/uranium
	name = "Uranium Golem"
	id = SPECIES_GOLEM_URANIUM
	fixed_mut_color = "#77ff00"
	meat = /obj/item/stack/ore/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, your very touch burns and irradiates organic lifeforms. You don't hit as hard as most golems, but you are far more durable against blunt force trauma."
	var/last_event = 0
	var/active = null
	armor = 40
	brutemod = 0.5
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown", "235")
	COOLDOWN_DECLARE(radiation_emission_cooldown)
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/uranium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/uranium,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

/datum/species/golem/uranium/proc/radiation_emission(mob/living/carbon/human/H)
	if(!COOLDOWN_FINISHED(src, radiation_emission_cooldown))
		return
	else
		radiation_pulse(H, max_range = 1, threshold = RAD_VERY_LIGHT_INSULATION, chance = 3)
		COOLDOWN_START(src, radiation_emission_cooldown, 2 SECONDS)

/datum/species/golem/uranium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(COOLDOWN_FINISHED(src, radiation_emission_cooldown) && M != H && (M.istate & ISTATE_HARM))
		radiation_emission(H)

/datum/species/golem/uranium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(COOLDOWN_FINISHED(src, radiation_emission_cooldown) && user != H)
		radiation_emission(H)
