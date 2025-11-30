#define DEBRIS_DENSITY(content_length) (content_length / (blob_team.blobs_legit * 0.25)) // items per blob

// Accumulates junk liberally
/datum/blobstrain/debris_devourer
	name = "Debris Devourer"
	description = "will launch accumulated debris into targets. Does very low brute damage without debris-launching." //I think this does 0 damage without launching
	analyzerdescdamage = "Does very low brute damage and may grab onto melee weapons."
	analyzerdesceffect = "Devours loose items left on the station, and releases them when attacking or attacked."
	color = "#8B1000"
	complementary_color = "#00558B"
	blobbernaut_message = "blasts"
	message = "The blob blasts you"

/datum/blobstrain/debris_devourer/attack_living(mob/living/attacked, list/nearby_blobs)
	send_message(attacked)
	for(var/obj/structure/blob/blob in nearby_blobs)
		debris_attack(attacked, blob)

/datum/blobstrain/debris_devourer/on_sporedeath(mob/living/spore)
	var/list/core_contents = blob_team.main_overmind.blob_core?.contents
	var/throw_count = 0
	while(length(core_contents) && throw_count < 3)
		var/obj/item/picked = pick(core_contents)
		if(QDELETED(picked))
			core_contents -= picked
			continue

		throw_count++
		picked.forceMove(get_turf(spore))
		picked.throw_at(get_ranged_target_turf(spore, pick(GLOB.alldirs), 6), 6, 5, spore, TRUE, FALSE)

/datum/blobstrain/debris_devourer/expand_reaction(obj/structure/blob/expanding, obj/structure/blob/new_blob, turf/target_turf, mob/eye/blob/owner, coefficient = 1)
	for(var/obj/item/target_item in target_turf)
		target_item.forceMove(blob_team.main_overmind.blob_core)

/datum/blobstrain/debris_devourer/proc/debris_attack(mob/living/attacked, source, mob/thrower = blob_team.main_overmind) //thrower gets passed to throw_at()
	var/list/core_contents = blob_team.main_overmind.blob_core?.contents
	var/content_length = length(core_contents)
	if(content_length && prob(40 * DEBRIS_DENSITY(content_length))) // Pretend the items are spread through the blob and its mobs and not in the core.
		var/obj/item/picked = pick(core_contents)
		if(QDELETED(picked))
			return

		picked.forceMove(get_turf(source))
		picked.throw_at(attacked, 6, 5, source, TRUE, FALSE)

/datum/blobstrain/debris_devourer/blobbernaut_attack(mob/living/attacked, mob/living/blobbernaut) // When this blob's blobbernaut attacks people
	debris_attack(attacked, blobbernaut, blobbernaut)

/datum/blobstrain/debris_devourer/damage_reaction(obj/structure/blob/damaged, damage, damage_type, damage_flag, coefficient = 1)
	var/content_length = length(blob_team.main_overmind.blob_core?.contents)
	return content_length ? round(max((coefficient*damage) - min(coefficient * DEBRIS_DENSITY(content_length), 10), 0)) : damage // reduce damage taken by items per blob, up to 10

/datum/blobstrain/debris_devourer/examine(mob/user)
	. = ..()
	var/content_length = length(blob_team.main_overmind.blob_core?.contents) || 0
	if(isobserver(user))
		. += span_notice("Absorbed debris is currently reducing incoming damage by [round(max(min(DEBRIS_DENSITY(content_length), 10),0))]")
	else
		switch(round(max(min(DEBRIS_DENSITY(content_length), 10),0)))
			if(0)
				. += span_notice("There is not currently enough absorbed debris to reduce damage.")
			if(1 to 3)
				. += span_notice("Absorbed debris is currently reducing incoming damage by a very low amount.") // these roughly correspond with force description strings
			if(4 to 7)
				. += span_notice("Absorbed debris is currently reducing incoming damage by a low amount.")
			if(8 to 10)
				. += span_notice("Absorbed debris is currently reducing incoming damage by a medium amount.")

#undef DEBRIS_DENSITY
