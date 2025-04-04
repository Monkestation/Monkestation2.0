/// Sends the target a fake adminhelp sound
/datum/smite/fake_bwoink
	name = "Fake bwoink"

/datum/smite/fake_bwoink/effect(client/user, mob/living/target)
	. = ..()
	send_sound_without_reverb(target, 'sound/effects/adminhelp.ogg') // monkestation edit: send_sound_without_reverb
