#define DEBRIS_DENSITY(content_length) (content_length / (blob_team.blobs_legit * 0.25)) // items per blob
#define DEBRIS_GENERATION_COOLDOWN 10 SECONDS

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
	///Cooldown for gaining our generated debris
	var/debris_tick = 0

/datum/blobstrain/debris_devourer/attack_living(mob/living/attacked, list/nearby_blobs, mob/eye/blob/attacker)
	send_message(attacked)
	attacked.adjustBruteLoss(4)
	for(var/obj/structure/blob/blob in nearby_blobs)
		debris_attack(attacked, blob)

/datum/blobstrain/debris_devourer/on_sporedeath(mob/living/spore) //should refactor this to use debris_attack()
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

/datum/blobstrain/debris_devourer/before_expansion(obj/structure/blob/expanding, turf/target_turf)
	for(var/obj/item/target_item in target_turf)
		if(target_item.throwforce)
			target_item.forceMove(blob_team.main_overmind.blob_core)

/datum/blobstrain/debris_devourer/core_process()
	. = ..()
	var/obj/structure/blob/special/node/main_core = blob_team.main_overmind.blob_core
	if(debris_tick < world.time && main_core)
		new /obj/item/blob_debris(main_core)
		debris_tick = debris_tick ? (debris_tick + DEBRIS_GENERATION_COOLDOWN) : (world.time + DEBRIS_GENERATION_COOLDOWN)

/datum/blobstrain/debris_devourer/proc/debris_attack(mob/living/attacked, source, mob/thrower) //thrower gets passed to throw_at()
	var/list/core_contents = blob_team.main_overmind.blob_core?.contents
	var/content_length = length(core_contents)
	if(content_length) // Pretend the items are spread through the blob and its mobs and not in the core.
		var/obj/item/picked
		var/sanity = 0
		while(!picked && sanity < 100)
			sanity++
			picked = pick(core_contents)
			if(QDELETED(picked))
				core_contents -= picked
			else if(picked.throwforce)
				break
			picked = null

		if(!picked)
			return

		picked.forceMove(get_turf(source))
		picked.throw_at(attacked, 6, 5, thrower, TRUE, FALSE)

/datum/blobstrain/debris_devourer/blobbernaut_attack(mob/living/attacked, mob/living/blobbernaut)
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

/obj/item/blob_debris
	name = "Blob Debris"
	desc = "A piece of debris created by a blob."
	throwforce = 6
	icon = 'icons/obj/brokentiling.dmi'
	icon_state = "singular"
	item_flags = ABSTRACT

/obj/item/blob_debris/after_throw(datum/callback/callback)
	. = ..()
	qdel(src) //might need to make this be a QDEL_IN()

#undef DEBRIS_DENSITY
#undef DEBRIS_GENERATION_COOLDOWN
