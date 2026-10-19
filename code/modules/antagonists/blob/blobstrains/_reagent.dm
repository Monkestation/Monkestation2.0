/datum/blobstrain/reagent // Blobs that mess with reagents, all "legacy" ones // what do you mean "legacy" you never added an alternative
	///The type of reagent we inject
	var/datum/reagent/reagent
	///How much we inject into mobs when attacking them
	var/amount_injected = 25
	///How much do blobbernauts inject into a mob when attacking them
	var/blobbernaut_amount_injected = 20

/datum/blobstrain/reagent/New(mob/eye/blob/new_overmind)
	. = ..()
	if(ispath(reagent))
		reagent = new reagent()

/datum/blobstrain/reagent/attack_living(mob/living/attacked, list/nearby_blobs, mob/eye/blob/attacker)
	reagent.expose_mob(attacked, VAPOR, amount_injected, TRUE, (attacked.getarmor(null, BIO) * 0.01), attacker)
	send_message(attacked)

/datum/blobstrain/reagent/blobbernaut_attack(mob/living/attacked, blobbernaut)
	//this will do between 10 and 20 damage(reduced by mob protection), depending on chemical, plus 4 from base brute damage.
	reagent.expose_mob(attacked, VAPOR, blobbernaut_amount_injected, FALSE, (attacked.getarmor(null, BIO) * 0.01))

/datum/blobstrain/reagent/on_sporedeath(mob/living/basic/spore)
	var/burst_range = (spore.type == /mob/living/basic/blob_minion/spore) ? 1 : 0
	do_chem_smoke(range = burst_range, holder = spore, location = get_turf(spore), reagent_type = reagent.type)

// These can only be applied by blobs. They are what (reagent) blobs are made out of.
/datum/reagent/blob
	name = "Unknown"
	description = "shouldn't exist and you should adminhelp immediately."
	color = "#FFFFFF"
	taste_description = "bad code and slime"
	chemical_flags = NONE
	penetrates_skin = NONE

/// Used by blob reagents to calculate the reaction volume they should use when exposing mobs.
/datum/reagent/blob/proc/return_mob_expose_reac_volume(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	if(exposed_mob.stat == DEAD || HAS_TRAIT(exposed_mob, TRAIT_BLOB_ALLY))
		return 0 //the dead, and blob mobs, don't cause reactions
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/// Exists to earmark the new overmind arg used by blob reagents.
/datum/reagent/blob/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	return ..()
