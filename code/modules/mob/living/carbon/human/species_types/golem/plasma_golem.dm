//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = SPECIES_GOLEM_PLASMA
	fixed_mut_color = "#aa33dd"
	meat = /obj/item/stack/ore/plasma
	//Can burn and takes damage from heat
	//no RESISTHEAT, NOFIRE
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)
	info_text = "As a <span class='danger'>Plasma Golem</span>, you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")
	examine_limb_id = SPECIES_GOLEM
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, span_userdanger("You feel like you could blow up at any moment!"))
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, span_notice("You feel more stable."))
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(H, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 4, flame_range = 5, explosion_cause = src)
		if(H)
			H.investigate_log("has been gibbed as [H.p_their()] body explodes.", INVESTIGATE_DEATHS)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(0.5 * seconds_per_tick)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()


/datum/action/innate/ignite
	name = "Ignite"
	desc = "Set yourself aflame, bringing yourself closer to exploding!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, span_notice("You ignite yourself!"))
		else
			to_chat(owner, span_warning("You try to ignite yourself, but fail!"))
		H.ignite_mob() //firestacks are already there passively
