/obj/item/skeleton_potion
	name = "strange flask"
	desc = "A strange flask with grey liquid inside of it."
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state = "skeleton_potion"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/skeleton_potion/attack_self(mob/user, modifiers)
	. = ..()
	if(!iscarbon(user))
		user.balloon_alert(user, "Only a humanoid can drink this!")
		return FALSE
	var/datum/smite/rattle_he_bones/boned = new /datum/smite/rattle_he_bones
	boned.should_log = FALSE
	boned.effect(user, user)
	user.balloon_alert(user, "You feel rattled!")
	qdel(src)
