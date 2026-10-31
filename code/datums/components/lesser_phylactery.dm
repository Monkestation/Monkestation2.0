/**
 * ## Lesser hylactery component
 *
 * Used for lesser lichdom to turn (almost) any object into a phylactery but intended to be used for altar
 * A mob linked to a phylactery will gain small amounts of passive healing and nodeath trait but dust if its destroyed
 */
/datum/component/lesser_phylactery
	// Set in initialize.
	/// The mind of the lich who is linked to this phylactery.
	var/datum/mind/lich_mind
	/// The color of the phylactery itself. Applied on creation.
	var/phylactery_color = COLOR_VERY_DARK_LIME_GREEN

/datum/component/lesser_phylactery/Initialize(datum/mind/lich_mind, phylactery_color = COLOR_VERY_DARK_LIME_GREEN)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	if(isnull(lich_mind))
		stack_trace("A [type] was created with no target lich mind!")
		return COMPONENT_INCOMPATIBLE

	src.lich_mind = lich_mind

	var/mob/living/carbon/human/current_mob = lich_mind.current
	ADD_TRAIT(current_mob, TRAIT_NO_SOUL, "lichdom")
	ADD_TRAIT(current_mob, TRAIT_NODEATH, "lichdom")

	RegisterSignal(lich_mind, COMSIG_QDELETING, PROC_REF(on_lich_mind_lost))

	var/obj/obj_parent = parent
	obj_parent.name = "ensouled [obj_parent.name]"
	obj_parent.add_atom_colour(phylactery_color, ADMIN_COLOUR_PRIORITY)
	obj_parent.AddComponent(/datum/component/stationloving, FALSE, TRUE)

	RegisterSignal(obj_parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/lesser_phylactery/Destroy()
	var/obj/obj_parent = parent
	obj_parent.name = initial(obj_parent.name)
	obj_parent.remove_atom_colour(ADMIN_COLOUR_PRIORITY, phylactery_color)

	var/mob/living/carbon/human/current_mob = lich_mind.current
	current_mob.dust(TRUE, TRUE)

	REMOVE_TRAITS_IN(current_mob, "lichdom") // incase you somehow survive

	UnregisterSignal(obj_parent, COMSIG_ATOM_EXAMINE)
	return ..()

/**
 * Signal proc for [COMSIG_ATOM_EXAMINE].
 *
 * Gives some flavor for the phylactery on examine.
 */
/datum/component/lesser_phylactery/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_green("A holy aura surrounds this item. You can feel its link to someones life...")

/**
 * Signal proc for [COMSIG_QDELETING] registered on the lich's mind.
 *
 * Minds shouldn't be getting deleted but if for some ungodly reason
 * the lich'd mind is deleted our component should go with it, as
 * we don't have a reason to exist anymore.
 */
/datum/component/lesser_phylactery/proc/on_lich_mind_lost(datum/source)
	SIGNAL_HANDLER
	qdel(src)
