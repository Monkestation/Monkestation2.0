/// Legally distinct lego death
/datum/smite/disassemble
	name = "Disassemble"

/datum/smite/disassemble/effect(client/user, mob/living/target)
	. = ..()
	playsound(target, 'sound/effects/fall_apart.ogg', vol = 40, vary = TRUE)
	target.gib(FALSE, FALSE, FALSE, TRUE, TRUE)

