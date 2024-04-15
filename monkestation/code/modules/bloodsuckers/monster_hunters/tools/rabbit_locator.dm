/obj/item/rabbit_locator
	name = "Accursed Red Queen card"
	desc = "Hunts down the white rabbits."
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "locator"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///the hunter the card is tied too
	var/datum/antagonist/monsterhunter/hunter
	COOLDOWN_DECLARE(locator_timer)


/obj/item/rabbit_locator/Initialize(mapload, datum/antagonist/monsterhunter/owner)
	. = ..()
	if(!QDELETED(owner))
		hunter = owner
		hunter.locator = src

/obj/item/rabbit_locator/Destroy()
	if(hunter?.locator == src)
		hunter.locator = null
	return ..()

/obj/item/rabbit_locator/attack_self(mob/user, modifiers)
	if(!COOLDOWN_FINISHED(src, locator_timer))
		return
	if(QDELETED(hunter))
		to_chat(user,span_warning("It's just a normal playing card!"))
		return
	if(hunter.owner.current != user)
		to_chat(user,span_warning("It's just a normal playing card!"))
		return
	var/turf/user_turf = get_turf(user)
	if(QDELETED(user_turf) || !is_station_level(user_turf.z))
		to_chat(user, span_warning("The card cannot be used here..."))
		return
	var/distance = get_minimum_distance(user)
	var/sound_value
	if(distance >= 50)
		sound_value = 0
		to_chat(user,span_warning("Too far away..."))
	if(distance >= 40 && distance < 50)
		sound_value = 20
		to_chat(user,span_warning("You feel the slightest hint..."))
	if(distance >=30 && distance < 40)
		sound_value = 40
		to_chat(user,span_warning("You feel a mild hint..."))
	if(distance >=20 && distance < 30)
		sound_value = 60
		to_chat(user,span_warning("You feel a strong hint..."))
	if(distance >= 10 && distance < 20)
		sound_value = 80
		to_chat(user,span_warning("You feel a VERY strong hint..."))
	if(distance < 10)
		sound_value = 100
		to_chat(user,span_warning("Here...its definitely here!"))
	user.playsound_local(src, 'monkestation/sound/bloodsuckers/rabbitlocator.ogg', vol = sound_value)
	COOLDOWN_START(src, locator_timer, 7 SECONDS)

/obj/item/rabbit_locator/proc/get_minimum_distance(mob/user)
	var/dist = 1000
	if(!length(hunter?.rabbits))
		return
	var/obj/effect/selected_bunny
	for(var/obj/effect/located as anything in hunter.rabbits)
		if(get_dist(user,located) < dist)
			dist = get_dist(user,located)
			selected_bunny = located
	var/z_difference = abs(selected_bunny.z - user.z)
	if(dist < 50 && z_difference != 0)
		to_chat(user,span_warning("[z_difference] [z_difference == 1 ? "floor" : "floors"] [selected_bunny.z > user.z ? "above" : "below"]..."))
	return dist
