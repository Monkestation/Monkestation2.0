/**
 * Shitcode: the ability
 */
/datum/action/cooldown/spell/pointed/wraith/choose_disquise
	name = "Choose Haunt Appearance"
	desc = "Choose any humanoid to disquise as next time when you haunt. Click on yourself to undo the disquise."
	button_icon_state = "choose_haunt_appearance"

	wraith_only = TRUE

	/// Holds appearances of both the owner and the target
	var/obj/disquise_dummy

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/New(Target)
	. = ..()
	disquise_dummy = new(src)

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/Destroy(force)
	QDEL_NULL(disquise_dummy)
	return ..()

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/Grant(mob/grant_to)
	. = ..()
	if(!owner)
		return

	disquise_dummy.name = owner.name
	disquise_dummy.desc = owner.desc
	disquise_dummy.icon = owner.icon
	disquise_dummy.icon_state = owner.icon_state
	disquise_dummy.copy_overlays(owner)

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	if(owner.density)
		if(feedback)
			to_chat(owner, span_warning("You can't cast [src] whilst materialized!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/before_cast(atom/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		. |= SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/cast(mob/living/cast_on)
	. = ..()
	disquise_dummy.name = cast_on.name
	disquise_dummy.desc = cast_on.desc
	disquise_dummy.icon = cast_on.icon
	disquise_dummy.icon_state = cast_on.icon_state
	disquise_dummy.cut_overlays()
	disquise_dummy.copy_overlays(cast_on)

/datum/action/cooldown/spell/pointed/wraith/choose_disquise/proc/change_disquise()
	if(HAS_TRAIT(owner, TRAIT_DISGUISED))
		REMOVE_TRAIT(owner, TRAIT_DISGUISED, REF(src))
	else
		ADD_TRAIT(owner, TRAIT_DISGUISED, REF(src))

	var/stored_name = owner.name
	var/stored_desc = owner.desc
	var/stored_icon = owner.icon
	var/stored_icon_state = owner.icon_state
	var/stored_plane = owner.plane
	var/list/stored_overlays = owner.overlays.Copy()

	owner.name = disquise_dummy.name
	owner.desc = disquise_dummy.desc
	owner.icon = disquise_dummy.icon
	owner.icon_state = disquise_dummy.icon_state
	owner.plane = disquise_dummy.plane
	owner.cut_overlays()
	owner.copy_overlays(disquise_dummy)

	disquise_dummy.name = stored_name
	disquise_dummy.desc = stored_desc
	disquise_dummy.icon = stored_icon
	disquise_dummy.icon_state = stored_icon_state
	disquise_dummy.plane = stored_plane
	disquise_dummy.cut_overlays()
	disquise_dummy.overlays = stored_overlays
