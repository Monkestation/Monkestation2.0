//kills unconscious targets and turns them into blob zombies, produces fragile spores when killed.  Spore produced by factories are sentient.
/datum/blobstrain/reagent/distributed_neurons
	name = "Distributed Neurons"
	description = "will do medium-low toxin damage and turns unconscious targets into blob zombies."
	effectdesc = "will also produce fragile spores when killed.  Spores produced by factories are sentient."
	shortdesc = "will do medium-low toxin damage and will kill any unconscious targets when attacked.  Spores produced by factories are sentient."
	analyzerdescdamage = "Does medium-low toxin damage and kills unconscious humans."
	analyzerdesceffect = "Produces spores when killed.  Spores produced by factories are sentient."
	color = "#E88D5D"
	complementary_color = "#823ABB"
	message_living = ", and you feel tired"
	reagent = /datum/reagent/blob/distributed_neurons

/datum/blobstrain/reagent/distributed_neurons/death_reaction(obj/structure/blob/dying, damage_flag, coefficient)
	if(prob(15))
		dying.visible_message(span_boldwarning("A spore floats free of the blob!"))
		blob_team.create_spore(get_turf(dying), /mob/living/basic/blob_minion/spore/minion/weak)

/datum/reagent/blob/distributed_neurons
	name = "Distributed Neurons"
	color = "#E88D5D"
	taste_description = "fizzing"

/datum/reagent/blob/distributed_neurons/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.6*reac_volume, TOX)
	if(overmind && ishuman(exposed_mob))
		if(exposed_mob.stat == UNCONSCIOUS || exposed_mob.stat == HARD_CRIT)
			exposed_mob.investigate_log("has been killed by distributed neurons (blob).", INVESTIGATE_DEATHS)
			exposed_mob.death() //sleeping in a fight? bad plan.
		if(exposed_mob.stat == DEAD)
			var/mob/living/basic/blob_minion/spore/minion/spore = overmind.antag_team.create_spore(get_turf(exposed_mob))
			spore.zombify(exposed_mob)
