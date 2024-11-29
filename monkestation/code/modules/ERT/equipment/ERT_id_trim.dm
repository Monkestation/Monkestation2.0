// gonna just make the green and blue alert IDs. it's fine if they have all access on red and above i am guessing
// Ordering:
// ROLES
// *Generic
// *Commander
// *Medic
// *Security Officer
// *Engineer
// *Janitor
// *Chaplain
// *Clown
// OTHER
/obj/item/card/id/advanced/centcom/ert/generic

/datum/id_trim/centcom/ert/generic
	assignment = "Emergency Response Team Intern"

/datum/id_trim/centcom/ert/generic/New()
	. = ..()
	access =  list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_SECURITY,
		)
