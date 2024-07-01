///Assoc list of gang controlled area types with values of the gang that controls them
GLOBAL_LIST_EMPTY(gang_controlled_areas)
//might be possible to combine this with double assoc stuff
///Assoc list of all tag decals keyed to the area they are in
//GLOBAL_LIST_EMPTY(tag_decals_by_area) //MIGHT NOT BE NEEDED

#define TIMES_CLEANED_TO_REMOVE 5
#define ALPHA_TO_REMOVE_WHEN_CLEANED 50
/obj/item/toy/crayon
	///list of additonal drawables that are drawable by this spraycan
	var/list/additional_drawables = list()
	///list of additional_drawables by static_additional_drawables
	var/list/formatted_additional_drawables = list()

/obj/item/toy/crayon/spraycan/gang
	///How many charges of resistant coating do we have
	var/resistant_coating_charges = 0

/obj/item/toy/crayon/spraycan/gang/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))

/obj/item/toy/crayon/spraycan/gang/Destroy(force)
	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	return ..()

//cant just use the element due to charges changing
/obj/item/toy/crayon/spraycan/gang/examine(mob/user)
	. = ..()
	if(isobserver(user) || IS_GANGMEMBER(user))
		. += span_syndradio("It looks like this one is created for use in gang tag painting.")
		if(initial(resistant_coating_charges))
			. += span_syndradio("It has [resistant_coating_charges] sprays worth of resistant coating left.")

/obj/item/toy/crayon/spraycan/gang/use_on(atom/target, mob/user, params)
	if(drawtype in additional_drawables)
		var/datum/antagonist/gang_member/gang_datum = IS_GANGMEMBER(user)
		if(gang_datum)
			return snowflake_graffiti_creation(target, user, gang_datum)
		else
			to_chat(user, "You dont know how to draw this!")
			return FALSE
	else
		return ..()

///We do a bunch of different stuff for our gang graffiti creation but still want normal function for the spraycan so im just cramming all our stuff into this proc instead of use_on()
/obj/item/toy/crayon/spraycan/gang/proc/snowflake_graffiti_creation(atom/target, mob/user, datum/antagonist/gang_member/antag_datum)
	if(!target || !isturf(target))
		return FALSE

	if(!isValidSurface(target))
		target.balloon_alert(user, "Can't use there!")
		return FALSE

	balloon_alert(user, "You start drawing a tag for your gang on \the [target]...")
	audible_message(span_notice("You hear spraying."))
	playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5, channel = CHANNEL_SOUND_EFFECTS)
	if(!do_after(user, 5 SECONDS, target))
		return FALSE

	var/area/target_area = get_area(target)
	if(!target_area)
		stack_trace("Gang spraycan([src]) calling snowflake_graffiti_creation() on a target without an area.")
		return FALSE

	if(target_area.outdoors || !(target_area.type in GLOB.the_station_areas))
		balloon_alert(user, "This area is not valid to take control of.")
		return FALSE

	var/datum/team/gang/controlling_gang = GLOB.gang_controlled_areas[target_area.type]
	if(controlling_gang == antag_datum.gang_team)
		balloon_alert(user, "We already control this area.")
		return FALSE

	var/obj/effect/decal/cleanable/crayon/gang/controlling_tag = locate(/obj/effect/decal/cleanable/crayon/gang) in target //target will always be a turf by this point
	if(controlling_gang && !controlling_tag)
		balloon_alert(user, "An enemy gang has a tag elsewhere in this area blocking claiming it! Find it and spray over it.")
		return FALSE
	else if(!resistant_coating_charges && controlling_tag?.resistant)
		balloon_alert(user, "It looks like \the [controlling_tag] has a resistant coating and can only be removed by your own resistant paint!") //dont think too hard about it
		return FALSE

	if(controlling_tag)
		qdel(controlling_tag)

	var/obj/effect/decal/cleanable/crayon/gang/created_tag = new(target, paint_color, antag_datum.gang_team?.gang_tag, "[antag_datum.gang_team?.gang_tag] tag", \
																null, null, antag_datum.gang_team)
	if(resistant_coating_charges)
		resistant_coating_charges--
		created_tag.resistant = TRUE

	created_tag.add_hiddenprint(user)
	balloon_alert(user, "You finish drawing \the [created_tag].")

	audible_message(span_hear("You hear spraying."))
	playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5, channel = CHANNEL_SOUND_EFFECTS)

/obj/item/toy/crayon/spraycan/gang/proc/creation_checks(atom/target, mob/user, datum/antagonist/gang_member/antag_datum)

/obj/item/toy/crayon/spraycan/gang/proc/on_pickup(datum/source, mob/taker)
	SIGNAL_HANDLER

	var/datum/antagonist/gang_member/gang_datum = IS_GANGMEMBER(taker)
	if(gang_datum?.gang_team)
		if(!(gang_datum.gang_team.gang_tag in additional_drawables))
			additional_drawables = list(gang_datum.gang_team.gang_tag)
			formatted_additional_drawables = list(list("name" = "Gang", "items" = list(list("item" = gang_datum.gang_team.gang_tag))))
			drawtype = gang_datum.gang_team.gang_tag
		return

	if(drawtype in additional_drawables)
		drawtype = "Random Anything"
	additional_drawables = list()

/obj/item/toy/crayon/spraycan/gang/resistant
	resistant_coating_charges = 5

/obj/effect/decal/cleanable/crayon/gang
	mergeable_decal = FALSE
	clean_type = CLEAN_TYPE_HARD_DECAL
	do_icon_rotate = FALSE
	///do we have a resistant coating
	var/resistant = FALSE
	///how close to being cleaned off are we
	var/cleaning_progress = 0
	///ref to the gang that owns us
	var/datum/team/gang/gang_owner //might not be needed

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, main, type, e_name, graf_rot, alt_icon, datum/team/gang/passed_gang)
	. = ..()
	if(passed_gang)
		var/area/our_area = get_area(src)
		if(our_area)
			GLOB.gang_controlled_areas[our_area.type] = passed_gang

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/our_area = get_area(src)
	GLOB.gang_controlled_areas -= our_area?.type
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
