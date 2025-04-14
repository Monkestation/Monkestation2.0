/datum/action/cooldown/spell/track_monster
	name = "Hunter Vision"
	desc = "Detect monsters within vicinity"
	button_icon_state = "blind"
	cooldown_time = 5 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/track_monster/cast(mob/living/carbon/cast_on)
	. = ..()
	var/datum/component/echolocation/monsterhunter/vision = cast_on.AddComponent(/datum/component/echolocation/monsterhunter, echo_group = "hunter")
	QDEL_IN(vision, 3 SECONDS)

/datum/component/echolocation/monsterhunter

/datum/component/echolocation/monsterhunter/echolocate() //code stolen from echolocation to make it ignore non-monster mobs
	if(!COOLDOWN_FINISHED(src, cooldown_last))
		return
	COOLDOWN_START(src, cooldown_last, cooldown_time)
	var/mob/living/echolocator = parent
	var/datum/antagonist/monsterhunter/hunter = echolocator.mind.has_antag_datum(/datum/antagonist/monsterhunter)
	var/real_echo_range = echo_range
	if(HAS_TRAIT(echolocator, TRAIT_ECHOLOCATION_EXTRA_RANGE))
		real_echo_range += 2
	var/list/filtered = list()
	var/list/seen = dview(real_echo_range, get_turf(echolocator.client?.eye || echolocator), invis_flags = echolocator.see_invisible)
	for(var/atom/seen_atom as anything in seen)
		if(!seen_atom.alpha)
			continue
		if(allowed_paths[seen_atom.type])
			filtered += seen_atom
	if(!length(filtered))
		return
	var/current_time = "[world.time]"
	images[current_time] = list()
	receivers[current_time] = list()
	var/list/objectives_list = hunter.objectives
	for(var/mob/living/viewer in filtered)
		if(blocking_trait && HAS_TRAIT(viewer, blocking_trait))
			continue
		if(HAS_TRAIT_FROM(viewer, TRAIT_ECHOLOCATION_RECEIVER, echo_group))
			receivers[current_time] += viewer
		var/remove_from_vision = TRUE
		for(var/datum/objective/hunter/goal in objectives_list) //take them out if they are not our prey
			if(goal.target == viewer.mind)
				goal.uncover_target()
				remove_from_vision = FALSE
				break
		if(remove_from_vision)
			filtered -= viewer
	for(var/atom/filtered_atom as anything in filtered)
		show_image(saved_appearances["[filtered_atom.icon]-[filtered_atom.icon_state]"] || generate_appearance(filtered_atom), filtered_atom, current_time)
	addtimer(CALLBACK(src, PROC_REF(fade_images), current_time), image_expiry_time)

/datum/component/echolocation/monsterhunter/generate_appearance(atom/input)
	var/mutable_appearance/copied_appearance = new /mutable_appearance()
	copied_appearance.appearance = input
	if(istype(input, /mob/living))
		copied_appearance.cut_overlays()
		copied_appearance.icon = 'monkestation/icons/mob/rabbit.dmi'
		copied_appearance.icon_state = "white_rabbit"
	copied_appearance.color = black_white_matrix
	copied_appearance.filters += outline_filter(size = 1, color = COLOR_WHITE)
	if(!images_are_static)
		copied_appearance.pixel_x = 0
		copied_appearance.pixel_y = 0
		copied_appearance.transform = matrix()
	if(!iscarbon(input))
		saved_appearances["[input.icon]-[input.icon_state]"] = copied_appearance
	return copied_appearance
