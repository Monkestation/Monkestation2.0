/obj/item/rabbit_locator
	name = "Accursed Red Queen card"
	desc = "Hunts down the white rabbits.\n<b>This does <i>NOT</i> track down monster targets, it tracks down the rabbits you must collect.</b>"
	icon = 'icons/obj/items/monster_hunter.dmi'
	icon_state = "locator"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///the hunter the card is tied too
	var/datum/antagonist/monsterhunter/hunter
	COOLDOWN_DECLARE(locator_timer)
	///the sound channel every ping plays on, so a new ping cuts off the last one
	var/sound_channel

/obj/item/rabbit_locator/Initialize(mapload, datum/antagonist/monsterhunter/owner)
	. = ..()
	sound_channel = SSsounds.reserve_sound_channel(src)
	if(!QDELETED(owner))
		hunter = owner
		hunter.locator = src

/obj/item/rabbit_locator/Destroy()
	SSsounds.free_sound_channel(sound_channel)
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
	var/obj/effect/bnuuy = get_nearest_rabbit(user)
	if(QDELETED(bnuuy))
		to_chat(user, span_warning("Can't feel any hints..."))
		return
	var/turf/bnuuy_turf = get_turf(bnuuy)
	var/distance = get_dist(user_turf, bnuuy_turf)
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
		to_chat(user, span_warning("Here... the white rabbit is definitely here!"))
	COOLDOWN_START(src, locator_timer, 3 SECONDS)
	if(!sound_value)
		return
	// straight to the client so the volume sliders and falloff can't eat it, only direction is 3D here
	var/sound/ping = sound('sound/effects/rabbitlocator.ogg')
	ping.volume = sound_value / 2
	ping.channel = sound_channel
	var/dx = bnuuy_turf.x - user_turf.x
	var/dy = bnuuy_turf.y - user_turf.y
	var/dz = bnuuy_turf.z - user_turf.z
	var/spread = abs(dx) + abs(dy) + abs(dz)
	if(spread)
		ping.x = 3 * dx / spread
		ping.y = 3 * dz / spread
		ping.z = 3 * dy / spread
		ping.falloff = 3
		// stereo can't tell north from south, so rabbits to the south sound dull, like they're behind you
		var/list/echo_settings = list(0, 0, -10000, -10000, 0, 0, 0, 0.25, 1.5, 1.0, 0, 1.0, 0, 0, 0, 0, 1.0, 7)
		echo_settings[2] = -3000 * max(0, -dy) / spread
		ping.echo = echo_settings
	SEND_SOUND(user, ping)

/obj/item/rabbit_locator/proc/get_nearest_rabbit(mob/user)
	var/dist = 1000
	if(!length(hunter?.rabbits))
		return
	var/obj/effect/selected_bunny
	for(var/obj/effect/bnnuy/located as anything in hunter.rabbits)
		if(get_dist(user, located) < dist)
			dist = get_dist(user, located)
			selected_bunny = located
	if(QDELETED(selected_bunny))
		return
	var/z_difference = abs(selected_bunny.z - user.z)
	if(dist < 50 && z_difference != 0)
		to_chat(user, span_warning("[z_difference] [z_difference == 1 ? "floor" : "floors"] [selected_bunny.z > user.z ? "above" : "below"]..."))
	return selected_bunny
