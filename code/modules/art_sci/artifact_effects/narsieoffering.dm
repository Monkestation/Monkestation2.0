/datum/artifact_effect/narsieoffering
	examine_discovered = "Makes an offering to the dark gods."
	type_name = "Dark Altar Effect"
	weight = ARTIFACT_COMMON * 2 //Very rare despite high weight

	examine_hint = span_warning("You feel calm and safe around this...")
	valid_origins = list(/datum/artifact_origin/narsie)

	valid_activators = list(/datum/artifact_activator/touch/carbon)

	research_value = TECHWEB_DISCOUNT_MINOR / 2
	discovered_credits = CARGO_CRATE_VALUE*5//Cult artifact anyone?

	/// How much blood is taken when used
	var/blood_to_take = 1

	/// How much blood is stored
	var/stored_blood = 0

	COOLDOWN_DECLARE(force_take_cooldown)
	///List of valid items this artifact can spawn when full on blood (needs 3 bodys of blood.)
	var/static/list/obj/valid_spawns = list(
		/obj/item/soulstone/anybody = 1, //Lucky you.
		/obj/item/clothing/suit/hooded/cultrobes = 20,
		/obj/item/clothing/suit/hooded/cultrobes/alt = 20,
		/obj/item/clothing/suit/hooded/cultrobes/hardened = 10,
		/obj/item/sharpener/cult = 35,
		/obj/item/shield/mirror = 15
	)

/datum/artifact_effect/narsieoffering/setup()
	blood_to_take = round(rand(BLOOD_VOLUME_NORMAL*0.1,BLOOD_VOLUME_NORMAL*0.9))

/datum/artifact_effect/narsieoffering/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src,force_take_cooldown))
		to_chat(user,"You feel [our_artifact.holder] is not yet ready for what it has planned...")
		return
	if(!user.blood_volume || !iscarbon(user))
		to_chat(user, span_info("You feel a need to give your non existant blood."))
		return
	if(user.blood_volume <= blood_to_take)
		to_chat(user,span_info("You feel a need to give more blood, but [our_artifact.holder] deems you too weak to do so!"))
		return
	var/yoinked_blood = min(blood_to_take,user.blood_volume)
	user.blood_volume -= yoinked_blood
	stored_blood += yoinked_blood
	to_chat(user, span_boldwarning("You are compelled to give blood to the [our_artifact.holder]; and feel your blood draining from your body!"))
	COOLDOWN_START(src, force_take_cooldown, 5 SECONDS)

	if(stored_blood < BLOOD_VOLUME_NORMAL*3)
		return
	var/turf/our_turf = get_turf(our_artifact.holder);
	var/obj/tomake = pick_weight(valid_spawns)
	var/obj/chosen = new tomake(our_turf)
	to_chat(user, span_info("[our_artifact.holder] is pleased with your work, and [chosen] appears from seemingly nowhere!"))
	stored_blood -= BLOOD_VOLUME_NORMAL*3


