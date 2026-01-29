//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS
	starting_tc = 1 //a free TC, as a treat
	///What type of antag datum do we give the person we implant
	var/datum/antagonist/gang_member/antag_type = /datum/antagonist/gang_member
	///If set to TRUE then we force our implanting
	var/debug = FALSE
	///Do we have a communicator
	var/has_communicator = FALSE
	///Do we let them get their given_gear_type
	var/give_gear = FALSE
	///A ref to the gang that is currently tracking us
	var/datum/team/gang/tracked_by

/obj/item/implant/uplink/gang/Initialize(mapload)
	. = ..()
	has_communicator = initial(antag_type.rank) >= GANG_RANK_LIEUTENANT //this is mainly just so people dont waste TC trying to give leaders communicators

/obj/item/implant/uplink/gang/can_be_implanted_in(mob/living/target)
	. = ..()
	if(!.)
		return

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD) || IS_TRAITOR(target) || IS_NUKE_OP(target)) //mindshields work the same way as cultists
		return FALSE

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force = debug, skip_uplink_creation = TRUE, datum/team/gang/forced_gang)
	if(!target.mind) //implanting a mindless mob wont work and will runtime, so override force
		to_chat(user, span_warning("\The [src] rejects [target]."))
		return FALSE

	var/datum/antagonist/gang_member/gang_user = IS_GANGMEMBER(user)
	if(!force && (!gang_user || !gang_user.gang_team))
		to_chat(user, span_warning("You can't figure out how to use \the [src]."))
		return FALSE

	var/datum/antagonist/gang_member/new_member_datum = new antag_type()
	if(!new_member_datum.can_be_owned(target.mind))
		to_chat(user, span_warning("\The [src] refuses to implant [target]."))
		qdel(new_member_datum)
		return FALSE

	. = ..()
	if(!.)
		return

	var/datum/team/gang/given_gang = forced_gang || gang_user?.gang_team
	var/is_new_handler = !given_gang?.handlers[target.mind]
	if(!give_gear)
		new_member_datum.given_gear_type = null

	var/is_ranking = MEETS_GANG_RANK(new_member_datum, GANG_RANK_LIEUTENANT)
	if(!is_ranking)
		new_member_datum.handle_new_implant(src) //need to call this here to ensure the weakref to us gets set correctly

	target.mind.add_antag_datum(new_member_datum, given_gang)
	given_gang = new_member_datum.gang_team //ensure the value is up to date
	uplink_handler = new_member_datum.handler
	if(is_new_handler)
		new_member_datum.handler.telecrystals = starting_tc

	if(!is_ranking)
		add_uplink(target)
		given_gang.track_implant(src)
		if(has_communicator)
			new_member_datum.set_communicate_source()
	else
		new_member_datum.handle_new_implant(src) //this will qdel us so do it last

/obj/item/implant/uplink/gang/proc/add_communicator(datum/antagonist/gang_member/member_datum)
	if(has_communicator)
		return FALSE

	if(!imp_in)
		has_communicator = TRUE
		return TRUE

	member_datum ||= IS_GANGMEMBER(imp_in)
	if(!member_datum)
		CRASH("add_communicator() being called on a gang uplink implant whos owner does not have a gang datum")

	if(member_datum.communicate)
		return FALSE

	has_communicator = TRUE
	member_datum.set_communicate_source()
	return TRUE

/obj/item/implant/uplink/gang/boss
	starting_tc = 25 //bosses get extra TC over traitors
	antag_type = /datum/antagonist/gang_member/boss

/obj/item/implant/uplink/gang/lieutenant
	starting_tc = 10
	antag_type = /datum/antagonist/gang_member/lieutenant

//implanters
/obj/item/implanter/uplink/gang
	name = "implanter (gang uplink)"
	imp_type = /obj/item/implant/uplink/gang
	///What should we set the debug state of our implant to on init
	var/debug_implant = FALSE

/obj/item/implanter/uplink/gang/Initialize(mapload)
	. = ..()
	var/obj/item/implant/uplink/gang/implant = imp
	implant.debug = debug_implant

/obj/item/implanter/uplink/gang/lieutenant
	name = "implanter (gang lieutenant uplink)"
	imp_type = /obj/item/implant/uplink/gang/lieutenant

/obj/item/implanter/uplink/gang/boss
	name = "implanter (gang boss uplink)"
	imp_type = /obj/item/implant/uplink/gang/boss
	debug_implant = TRUE
