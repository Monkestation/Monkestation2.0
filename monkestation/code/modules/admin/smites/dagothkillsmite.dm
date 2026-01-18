// Dagoth KILL Smite! (ported from Biblefart code) - Dexee
// tweaked the name of this to make it extremely apparent that someone's gonna get fucked up. completely and utterly apparent. will be making a separate funny smite that doesn't kill

/datum/smite/dagothkillsmite
	name = "Dagoth KILL Smite"

/datum/smite/dagothkillsmite/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/human/Person = target
	var/turf/T = get_step(get_step(Person, NORTH), NORTH)
	to_chat(Person,span_ratvar("What a grand and intoxicating innocence. Perish."))
	T.Beam(Person, icon_state="lightning[rand(1,12)]", time = 1.5 SECONDS)
	Person.unequip_everything()
	Person.Paralyze(1.5 SECONDS)
	playsound(target, 'sound/magic/lightningshock.ogg', vol = 50, vary = TRUE)
	playsound(target, 'monkestation/sound/misc/dagothgod.ogg', vol = 80)
	Person.electrocution_animation(1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_kill_smite), Person), 1.5 SECONDS)

/datum/smite/dagothkillsmite/proc/finish_kill_smite(mob/living/carbon/human/victim)
	playsound(get_turf(victim), 'sound/effects/explosion3.ogg', vol = 75, vary = TRUE)
	victim.gib()
