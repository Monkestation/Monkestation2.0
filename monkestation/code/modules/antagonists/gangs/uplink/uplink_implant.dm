//the uplink implanted used by gangs
/obj/item/implant/uplink/gang
	uplink_flag = UPLINK_GANGS
	starting_tc = 1 //a free TC, as a treat
	///What type of antag datum do we give the person we implant
	var/datum/antagonist/gang_member/antag_type = /datum/antagonist/gang_member
	///If TRUE then this implant can only be used for promotion and not conversion
	var/promotion_only = FALSE
	///If set to TRUE then we force our implanting
	var/debug = FALSE
	///Ref to our gang communicator action, if we have one
	var/datum/action/innate/gang_communicate/communicate

/obj/item/implant/uplink/gang/Initialize(mapload, uplink_handler, datum/team/gang/tracking_gang)
	. = ..()
	tracking_gang?.track_implant(src)
	if(initial(antag_type.rank) >= GANG_RANK_LIEUTENANT) //leaders always get a communicator
		add_communicator()

/obj/item/implant/uplink/gang/Destroy()
	if(!QDELETED(communicate))
		QDEL_NULL(communicate)
	return ..()

/obj/item/implant/uplink/gang/can_be_implanted_in(mob/living/target)
	. = ..()
	if(!.)
		return

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD) || IS_TRAITOR(target) || IS_NUKE_OP(target)) //mindshields work the same way as cultists
		return FALSE

/obj/item/implant/uplink/gang/implant(mob/living/carbon/target, mob/user, silent, force = debug)
	if(!target.mind) //implanting a mindless mob wont work and will runtime, so override force
		to_chat(user, span_warning("\The [src] rejects [target]."))
		return FALSE

	var/datum/antagonist/gang_member/gang_user = IS_GANGMEMBER(user)
	if(!force && (!gang_user || !gang_user.gang_team))
		to_chat(user, span_warning("You can't figure out how to use \the [src]."))
		return FALSE

	var/datum/antagonist/gang_member/gang_target = IS_GANGMEMBER(target)
	if((!gang_target && promotion_only) || (gang_target && !promotion_checks(gang_target, gang_user)))
		to_chat(user, span_warning("\The [src] refuses to implant [target]."))
		return FALSE

	if(gang_target) //if the previous check passes then we are valid to promote
		gang_target.change_rank(antag_type)
		var/obj/item/implant/uplink/gang/target_implant = locate(/obj/item/implant/uplink/gang) in target.implants
		target_implant?.add_communicator()
		moveToNullspace()
		qdel(src)
		return TRUE

	var/datum/uplink_handler/gang/handler = gang_user?.gang_team.handlers[target.mind]
	var/qdel_handler_on_fail = FALSE //we only want to qdel the handler if its new
	if(!handler)
		handler = new
		qdel_handler_on_fail = TRUE
		handler.owner = target.mind
		handler.telecrystals = starting_tc //if we override handler then starting_tc does not get used
		handler.owning_gang = gang_user?.gang_team
		handler.uplink_flag = UPLINK_GANGS
	uplink_handler = handler

	. = ..()
	if(!.)
		if(qdel_handler_on_fail)
			qdel(handler)
		return

	var/datum/antagonist/gang_member/new_member_datum = new antag_type
	new_member_datum.handler = handler
	target.mind.add_antag_datum(new_member_datum, gang_user?.gang_team)
	new_member_datum.RegisterSignal(src, COMSIG_PRE_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_pre_implant_removal))
	new_member_datum.RegisterSignal(src, COMSIG_IMPLANT_REMOVED, TYPE_PROC_REF(/datum/antagonist/gang_member, handle_implant_removal))
	communicate?.Grant(target)
	if(new_member_datum.gang_team)
		new_member_datum.gang_team.handlers[target.mind] = handler
		new_member_datum.gang_team.track_implant(src)

/obj/item/implant/uplink/gang/removed(mob/living/source, silent, special, forced)
	. = ..()
	if(!.)
		return

	communicate?.Remove(source)

/obj/item/implant/uplink/gang/proc/add_communicator()
	if(communicate)
		return FALSE

	communicate = new
	if(imp_in)
		communicate.Grant(imp_in)

///put any unique checks you want for rank promotion here
/obj/item/implant/uplink/gang/proc/promotion_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(target.gang_team != user.gang_team || !MEETS_GANG_RANK(user, GANG_RANK_LIEUTENANT) || !initial(antag_type.rank) > target.rank)
		return FALSE
	return TRUE

/obj/item/implant/uplink/gang/boss
	starting_tc = 25 //bosses get extra TC over traitors
	antag_type = /datum/antagonist/gang_member/boss

/obj/item/implant/uplink/gang/boss/promotion_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(!..() || !MEETS_GANG_RANK(target, GANG_RANK_LIEUTENANT))
		return FALSE

	var/list/boss_list = target.gang_team.member_datums_by_rank["[GANG_RANK_BOSS]"]
	if(boss_list?.len) //using .len lets us use ?.
		var/datum/antagonist/gang_member/boss/boss_datum = boss_list[1]
		if(boss_datum.owner?.current?.stat != DEAD)
			return FALSE
//		boss_datum.change_rank(target.type) //already accessed so just handle this here as we pass by this point
	return TRUE

/obj/item/implant/uplink/gang/lieutenant
	starting_tc = 5
	antag_type = /datum/antagonist/gang_member/lieutenant

/obj/item/implant/uplink/gang/lieutenant/promotion_checks(datum/antagonist/gang_member/target, datum/antagonist/gang_member/user)
	if(!..())
		return FALSE

	var/list/lieutenant_list = target.gang_team.member_datums_by_rank["[GANG_RANK_LIEUTENANT]"]
	if(lieutenant_list && length(lieutenant_list) > MAX_LIEUTENANTS)
		var/list/dead_lieutenants = list()
		for(var/datum/antagonist/gang_member/lieutenant_datum in lieutenant_list)
			if(lieutenant_datum.owner?.current?.stat == DEAD)
				dead_lieutenants += lieutenant_datum

		if(length(dead_lieutenants))
			var/datum/antagonist/gang_member/lieutenant/picked_lieutenant = pick(dead_lieutenants)
			picked_lieutenant.change_rank(target.type)
		else
			return FALSE
	return TRUE

/obj/item/implanter/uplink/gang
	name = "implanter (gang uplink)"
	imp_type = /obj/item/implant/uplink/gang
	///What should we set the debug state of our implant to on init
	var/debug_implant = FALSE
	///What should we set the state of our implant's promotion_only to on init
	var/fabricated = FALSE

/obj/item/implanter/uplink/gang/Initialize(mapload, uplink_handler)
	. = ..()
	var/obj/item/implant/uplink/gang/implant = imp
	implant.debug = debug_implant
	implant.promotion_only = fabricated
	if(fabricated)
		AddElement(/datum/element/extra_examine/gang, span_syndradio("This one seems to unable to induct new members and can only be used to promote exsisting gang members."))

/obj/item/implanter/uplink/gang/debug
	item_flags = ABSTRACT //this is to prevent a few things from trying to spawn this, slightly janky but this is for debug anyway so it should be fine
	debug_implant = TRUE

/obj/item/implanter/uplink/gang/debug/boss
	imp_type = /obj/item/implant/uplink/gang/boss

/obj/item/implanter/uplink/gang/lieutenant
	name = "implanter (gang lieutenant uplink)"
	imp_type = /obj/item/implant/uplink/gang/lieutenant

/obj/item/implanter/uplink/gang/lieutenant/fabricated
	fabricated = TRUE

/obj/item/implanter/uplink/gang/boss
	name = "implanter (gang boss uplink)"
	imp_type = /obj/item/implant/uplink/gang/boss

/obj/item/implanter/uplink/gang/boss/fabricated
	fabricated = TRUE
