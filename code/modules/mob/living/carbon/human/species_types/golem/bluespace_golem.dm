//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	id = SPECIES_GOLEM_BLUESPACE
	fixed_mut_color = "#3333ff"
	meat = /obj/item/stack/ore/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, you are spatially unstable: You will teleport when hit, and you can teleport manually at a long distance."
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")
	examine_limb_id = SPECIES_GOLEM

	var/datum/action/cooldown/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] teleports!"), span_danger("You destabilize and teleport!"))
	new /obj/effect/particle_effect/sparks(get_turf(H))
	playsound(get_turf(H), SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	do_teleport(H, get_turf(H), 6, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(isitem(AM))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H && (M.istate & ISTATE_HARM))
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/cooldown/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jaunt"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	cooldown_time = 17.5 SECONDS

/datum/action/cooldown/unstable_teleport/Activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message(span_warning("[H] starts vibrating!"), span_danger("You start charging your bluespace core..."))
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(teleport), H), 1.5 SECONDS)
	return TRUE

/datum/action/cooldown/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	StartCooldown()
	H.visible_message(span_warning("[H] disappears in a shower of sparks!"), span_danger("You teleport!"))
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 12, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
