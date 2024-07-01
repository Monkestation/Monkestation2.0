/obj/item/storage/toolbox/emergency/turret/gang
	turret_type = /obj/machinery/porta_turret/syndicate/toolbox/gang

/obj/item/storage/toolbox/emergency/turret/gang/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/extra_examine/gang, span_syndradio("When hit with a combat wrench this disguised duel mode turret will expand to full size and help protect your gang."))

/obj/item/storage/toolbox/emergency/turret/gang/set_faction(obj/machinery/porta_turret/turret, mob/user)
	var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(user) //this is already checked but there is no good way to pass args so here we are
	turret.faction = list("[REF(antag_datum.gang_team)]")

/obj/item/storage/toolbox/emergency/turret/gang/construction_checks(mob/living/user)
	if(!IS_GANGMEMBER(user))
		balloon_alert(user, "\The [src] refuses to expand!")
		return FALSE
	return TRUE

/obj/machinery/porta_turret/syndicate/toolbox/gang
	stun_projectile = /obj/projectile/bullet/toolbox_turret/non_lethal
	lethal_projectile = /obj/projectile/bullet/toolbox_turret

/obj/machinery/porta_turret/syndicate/toolbox/gang/examine(mob/user)
	. = ..()
	if(isobserver(user) || faction_check_atom(user))
		. += span_syndradio("It is current set to [mode ? "lethal" : "disable"] mode. Toggle modes with [span_bold("Alt-Click")]") //mode is a bool

/obj/machinery/porta_turret/syndicate/toolbox/gang/AltClick(mob/user)
	. = ..()
	if(faction_check_atom(user))
		setState(on, !mode)
		balloon_alert(user, "Set to [mode ? "lethal" : "disable"] mode.")

/obj/projectile/bullet/toolbox_turret/non_lethal
	damage_type = STAMINA
	damage = 35 //same as a disabler/paco
