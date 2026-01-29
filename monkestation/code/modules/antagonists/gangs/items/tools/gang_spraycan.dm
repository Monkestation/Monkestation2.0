///Assoc list of gang controlled areas with values of the gang that controls them
GLOBAL_LIST_EMPTY(gang_controlled_areas)
//might be possible to combine this with double assoc stuff
///Assoc list of all tag decals keyed to the area they are in
//GLOBAL_LIST_EMPTY(tag_decals_by_area) //MIGHT NOT BE NEEDED

#define TIMES_CLEANED_TO_REMOVE 5
#define ALPHA_TO_REMOVE_WHEN_CLEANED 50
/obj/item/toy/crayon/spraycan/gang
	///Will we try to tag instead of our normal function if used by a gang member
	var/tagging_mode = TRUE
	///How many charges of resistant coating do we have
	var/resistant_coating_charges = 0
	///A ref to our action for toggling our tagging mode, we handle this ourselves as we dont want non gang members to see this
	var/datum/action/item_action/toggle_tagging/toggle_action

/obj/item/toy/crayon/spraycan/gang/Initialize(mapload)
	. = ..()
	toggle_action = new(src)

/obj/item/toy/crayon/spraycan/gang/Destroy(force)
	QDEL_NULL(toggle_action)
	return ..()

/obj/item/toy/crayon/spraycan/gang/pickup(mob/user)
	. = ..()
	if(IS_GANGMEMBER(user))
		toggle_action.Grant(user)

/obj/item/toy/crayon/spraycan/gang/dropped(mob/user, silent)
	. = ..()
	toggle_action.Remove(user)

/obj/item/toy/crayon/spraycan/gang/ui_action_click(mob/user, actiontype)
	if(!IS_GANGMEMBER(user) || (SEND_SIGNAL(src, COMSIG_ITEM_UI_ACTION_CLICK, user, actiontype) & COMPONENT_ACTION_HANDLED))
		return

	tagging_mode = !tagging_mode
	to_chat(user, span_notice("[src] will now [tagging_mode ? "tag areas" : "act as a normal spray can"]."))

//cant just use the element due to charges changing
/obj/item/toy/crayon/spraycan/gang/examine(mob/user)
	. = ..()
	if(isobserver(user) || IS_GANGMEMBER(user))
		. += span_syndradio("It looks like this one is created for use in gang tag painting.")
		if(initial(resistant_coating_charges))
			. += span_syndradio("It has [resistant_coating_charges] sprays worth of resistant coating left.")

/obj/item/toy/crayon/spraycan/gang/use_on(atom/target, mob/user, params)
	if(tagging_mode)
		var/datum/antagonist/gang_member/gang_datum = IS_GANGMEMBER(user)
		if(gang_datum)
			return snowflake_graffiti_creation(target, user, gang_datum)
	return ..()

///We do a bunch of different stuff for our gang graffiti creation but still want normal function for the spraycan so im just cramming all our stuff into this proc instead of use_on()
/obj/item/toy/crayon/spraycan/gang/proc/snowflake_graffiti_creation(atom/target, mob/user, datum/antagonist/gang_member/antag_datum)
	if(!target || !isturf(target))
		return FALSE

	if(!isValidSurface(target))
		target.balloon_alert(user, "can't use there!")
		return FALSE

	balloon_alert(user, "you start drawing a tag for your gang on \the [target]...")
	audible_message(span_notice("You hear spraying."))
	playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5, channel = CHANNEL_SOUND_EFFECTS)
	if(!do_after(user, 5 SECONDS, target))
		return FALSE

	var/area/target_area = get_area(target)
	if(!target_area)
		stack_trace("Gang spraycan([src]) calling snowflake_graffiti_creation() on a target without an area.")
		return FALSE

	if(target_area.outdoors || !(target_area.type in GLOB.the_station_areas))
		balloon_alert(user, "this area is not valid to take control of.")
		return FALSE

	var/datum/team/gang/controlling_gang = GLOB.gang_controlled_areas[target_area]
	if(controlling_gang == antag_datum.gang_team)
		balloon_alert(user, "we already control this area.")
		return FALSE

	var/obj/effect/decal/cleanable/crayon/gang/controlling_tag = locate(/obj/effect/decal/cleanable/crayon/gang) in target //target will always be a turf by this point
	if(controlling_gang && !controlling_tag)
		balloon_alert(user, "an enemy gang has a tag elsewhere in this area blocking claiming it! Find it and spray over it.")
		return FALSE
	else if(!resistant_coating_charges && controlling_tag?.resistant)
		balloon_alert(user, "it looks like \the [controlling_tag] has a resistant coating and can only be removed by your own resistant paint!") //dont think too hard about it
		return FALSE

	var/datum/team/gang/gang_team = antag_datum.gang_team
	if(!gang_team.take_area(target_area))
		balloon_alert(user, "something is making it impossible to take this area.")
		return FALSE

	if(controlling_tag) //give rep and TC
		controlling_tag.overridden = TRUE
		qdel(controlling_tag)
		gang_team.rep += 1
		gang_team.unallocated_tc += 0.2 //MAKE THESE BE A DEFINE

	var/obj/effect/decal/cleanable/crayon/gang/created_tag = new(target, paint_color, antag_datum.gang_team?.gang_tag, "[antag_datum.gang_team?.gang_tag] tag", \
																null, null, antag_datum.gang_team, target_area, TRUE)
	if(resistant_coating_charges)
		resistant_coating_charges--
		created_tag.resistant = TRUE

	created_tag.add_hiddenprint(user)
	balloon_alert(user, "you finish drawing \the [created_tag].")

	audible_message(span_hear("You hear spraying."))
	playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5, channel = CHANNEL_SOUND_EFFECTS)

/obj/item/toy/crayon/spraycan/gang/proc/creation_checks(atom/target, mob/user, datum/antagonist/gang_member/antag_datum)

/obj/item/toy/crayon/spraycan/gang/resistant
	resistant_coating_charges = 5

/datum/action/item_action/toggle_tagging
	name = "Toggle Tagging"

/obj/effect/decal/cleanable/crayon/gang
	mergeable_decal = FALSE
	clean_type = CLEAN_TYPE_HARD_DECAL
	do_icon_rotate = FALSE
	///do we have a resistant coating
	var/resistant = FALSE
	///how close to being cleaned off are we
	var/cleaning_progress = 0
	///are we being overidden by a new gang spray, used to save on some clean up code already being handled by take_area()
	var/overridden = FALSE
	///ref to the gang that owns us
	var/datum/team/gang/gang_owner

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, main, type, e_name, graf_rot, alt_icon, datum/team/gang/passed_gang, area/passed_area, already_taken)
	. = ..()
	if(passed_gang)
		gang_owner = passed_gang
		if(already_taken)
			return

		var/area/our_area = passed_area || get_area(src)
		if(our_area)
			passed_gang.take_area(our_area) //need to move this to be a check

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	if(overridden)
		return ..()

	var/area/our_area = get_area(src)
	if(gang_owner)
		gang_owner.lose_area(our_area, passed_owner = gang_owner)
	else //dont know how this happened but lets still clear the area just to be safe
		GLOB.gang_controlled_areas -= our_area
	return ..()

/obj/effect/decal/cleanable/crayon/gang/wash(clean_types)
	if(resistant)
		visible_message("\The [src] looks resistant to cleaning.") //might need anti spam
		return FALSE

	var/cleaned = FALSE
	if(clean_types & clean_type)
		cleaning_progress++
		alpha -= ALPHA_TO_REMOVE_WHEN_CLEANED
		cleaned = TRUE

	if(cleaning_progress >= TIMES_CLEANED_TO_REMOVE)
		return ..()
	return cleaned

#undef TIMES_CLEANED_TO_REMOVE
#undef ALPHA_TO_REMOVE_WHEN_CLEANED
