/datum/vampire_ability
	var/name = "ERROR"
	var/desc = "TELL THE ADMEMES"

	/// Associative lazylist of stat requirements for the ability.
	var/list/stat_reqs = null

	/// Minimum rank required to get the ability.
	var/min_rank = 0

	/// Clan required to get the ability.
	var/clan_req = null

	/// The action currently granted to the vampire by this ability, if any.
	/// If not null during initialization, attempts to create an instance of it.
	/// DO NOT PUT ANYTHING OTHER THAN A TYPEPATH AS THE INITIAL VALUE.
	var/datum/action/granted_action = null

	/// Lazylist of granted traits.
	var/list/granted_traits = null

	/// The vampire who owns this ability.
	var/datum/antagonist/vampire/owner = null

	/// The current mob using this ability.
	var/mob/living/carbon/human/user = null

	/// Whether this ability is pseudo-removed when masquerade is enabled. (calls on_remove, on_mob_remove, etc.)
	var/works_in_masquerade = FALSE

	/// Whether this ability is currently blocked by masquerade.
	var/blocked = FALSE

/// Actually grants the action to the vampire. Use on_grant for subtypes if possible.
/datum/vampire_ability/proc/grant(datum/antagonist/vampire/new_owner)
	SHOULD_NOT_SLEEP(TRUE)

	owner = new_owner
	user = owner.owner.current

	if(!works_in_masquerade)
		RegisterSignal(owner, COMSIG_VAMPIRE_MASQUERADE, PROC_REF(on_masquerade))
		blocked = owner.masquerade_enabled

	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(clear_ref))
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(clear_ref))

	if(ispath(granted_action))
		granted_action = new granted_action(owner)
		granted_action.Grant(user)

	if(!blocked)
		enable()

/// Called when the ability is enabled. This is what actually calls on_grant and on_grant_mob. If absolutely required for some asinine logic, you may override this.
/datum/vampire_ability/proc/enable()
	if(granted_traits)
		user.add_traits(granted_traits, REF(src))

	INVOKE_ASYNC(src, PROC_REF(on_grant))
	INVOKE_ASYNC(src, PROC_REF(on_grant_mob))

/// Called when the ability is disabled. This is what actually calls on_remove and on_remove_mob. If absolutely required for some asinine logic, you may override this.
/datum/vampire_ability/proc/disable()
	if(granted_traits)
		user.remove_traits(granted_traits, REF(src))

	INVOKE_ASYNC(src, PROC_REF(on_remove))
	INVOKE_ASYNC(src, PROC_REF(on_remove_mob))

/// To be implemented by subtypes. Called in grant() after setting owner and user.
/datum/vampire_ability/proc/on_grant()

/// To be implemented by subtypes. Called in grant() and after body swaps.
/datum/vampire_ability/proc/on_grant_mob()

/// Actually removes the action from the vampire. Use on_remove for subtypes if possible.
/datum/vampire_ability/proc/remove()
	SHOULD_NOT_SLEEP(TRUE)

	UnregisterSignal(owner, list(COMSIG_VAMPIRE_MASQUERADE, COMSIG_QDELETING))
	UnregisterSignal(user, COMSIG_QDELETING)

	QDEL_NULL(granted_action)

	if(!blocked)
		disable()

	owner = null
	user = null

/// To be implemented by subtypes. Called in remove() before unsetting owner and user.
/datum/vampire_ability/proc/on_remove()

/// To be implemented by subtypes. Called in remove() and after body swaps.
/datum/vampire_ability/proc/on_remove_mob()

/// If you pass the owner or user to this, the ability self-removes.
/datum/vampire_ability/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner || ref == user)
		remove()

/// Handles pseudo removing/adding the action if it's supposed to be disabled while in masquerade.
/datum/vampire_ability/proc/on_masquerade(datum/source, enabled)
	SIGNAL_HANDLER
	if(!blocked && enabled)
		disable()
	else if(blocked && !enabled)
		enable()
	blocked = enabled

/datum/vampire_ability/Destroy(force)
	if(owner || user)
		remove()
	return ..()
