//if it needs a rework illusions could be a damage reaction only and it instead applies druggy type status effects on hit
/datum/blobstrain/reagent/reforming_synapse
	name = "Reforming Synapse"
	description = "will do low brain damage and create illusions to attack your targets."
	analyzerdescdamage = "Does low brain damage and creates hostile illusions."
	analyzerdesceffect = "Will do low brain damage and create hostile illusions."
	color = "#ff5cd6"
	complementary_color = "#b938da"
	blobbernaut_message = "slams" //need something better
	message = "The blob sends your head spinning"
	reagent = /datum/reagent/blob/reforming_synapse

/datum/blobstrain/reagent/reforming_synapse/attack_living(mob/living/attacked, list/nearby_blobs, mob/eye/blob/attacker)
	. = ..()
	if(attacked.stat < DEAD)
		create_illusion(attacked, attacker)

/datum/blobstrain/reagent/reforming_synapse/proc/create_illusion(mob/living/target, mob/creator)
	if(HAS_TRAIT(target, TRAIT_BLOB_ALLY))
		return

	var/mob/living/spawned_from
	for(var/mob/living/possible_spawn in shuffle(view(4, target)))
		if(HAS_TRAIT(possible_spawn, TRAIT_BLOB_ALLY) || possible_spawn == target)
			continue
		spawned_from = possible_spawn
		break

	var/turf/spawn_turf
	if(!spawned_from)
		spawned_from = target
		spawn_turf = pick(RANGE_TURFS(4, target)) //technically this can spawn behind walls but ehh
	else
		spawn_turf = get_turf(spawned_from)

	var/mob/living/simple_animal/hostile/illusion/blob/fake_clone = new(spawn_turf)
	fake_clone.faction = list(ROLE_BLOB) | creator?.faction
	fake_clone.copy_parent(spawned_from, 10 SECONDS)
	fake_clone.GiveTarget(target)

/datum/reagent/blob/reforming_synapse
	name = "Reforming Synapse"
	taste_description = "brain death"
	color = "#ff5cd6"

/datum/reagent/blob/reforming_synapse/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(iscarbon(exposed_mob))
		exposed_mob.apply_damage(max(trunc(reac_volume/5), 2), BRAIN)
	else
		exposed_mob.apply_damage(trunc(reac_volume/3), BRUTE) //our damage is VERY low due to dealing brain, so our damage is boosted vs things without brains
