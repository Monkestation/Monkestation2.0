/datum/action/cooldown/mob_cooldown/transform_weapon
	name = "Transform Weapon"
	button_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "cleaving_saw"
	desc = "Transform weapon into a different state."
	cooldown_time = 5 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	/// The max possible cooldown, cooldown is random between the default cooldown time and this
	var/max_cooldown_time = 10 SECONDS

/datum/action/cooldown/mob_cooldown/transform_weapon/Activate(atom/target_atom)
	disable_cooldown_actions()
	do_transform()
	StartCooldown(rand(cooldown_time, max_cooldown_time), 0)
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/transform_weapon/proc/do_transform()
	if(!istype(owner, /mob/living/basic/boss/blood_drunk_miner))
		return
	var/mob/living/basic/boss/blood_drunk_miner/blood_drunk_miner = owner
	blood_drunk_miner.transform_saw()
