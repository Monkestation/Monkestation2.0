/**
 * # Virtual Domains
 * This loads a base level, then users can select the preset upon it.
 * Create your own: Read the readme file in the '_maps/virtual_domains' folder.
 */
/datum/lazy_template/virtual_domain
	map_dir = "_maps/virtual_domains"
	map_name = "None"
	key = "Virtual Domain"
	place_on_top = TRUE

	/// Whether to tell observers this map is being used
	var/announce_to_ghosts = FALSE
	/// Cost of this map to load
	var/cost = BITRUNNER_COST_NONE
	/// The description of the map
	var/desc = "A map."
	/// The 'difficulty' of the map, which affects the ui and ability to scan info.
	var/difficulty = BITRUNNER_DIFFICULTY_NONE
	/// An assoc list of typepath/amount to spawn on completion. Not weighted - the value is the amount
	var/list/extra_loot
	/// The map file to load
	var/filename = "virtual_domain.dmm"
	/// Any outfit that you wish to force on avatars. Overrides preferences
	var/datum/outfit/forced_outfit
	/// If this domain blocks the use of items from disks, for whatever reason
	var/forbids_disk_items = FALSE
	/// If this domain blocks the use of spells from disks, for whatever reason
	var/forbids_disk_spells = FALSE
	/// Information given to connected clients via ability
	var/help_text
	// Name to show in the UI
	var/name = "Virtual Domain"
	/// Points to reward for completion. Used to purchase new domains and calculate ore rewards.
	var/reward_points = BITRUNNER_REWARD_MIN
	/// The start time of the map. Used to calculate time taken
	var/start_time
	/// This map is specifically for unit tests. Shouldn't display in game
	var/test_only = FALSE
	/// The safehouse to load into the map
	var/datum/map_template/safehouse/safehouse_path = /datum/map_template/safehouse/den
	/// What bitrunning network does this domain show up on? Used to split between tutorial and normal bitrunning.
	var/bitrunning_network = BITRUNNER_DOMAIN_DEFAULT

	/**
	 * Modularity
	 */

	/// Whether to display this as a modular map
	var/is_modular = FALSE
	/// Byond will look for modular mob segment landmarks then choose from here at random. You can make them unique also.
	var/list/datum/modular_mob_segment/mob_modules = list()
	/// Forces all mob modules to only load once
	var/modular_unique_mobs = FALSE

/// Sends a point to any loot signals on the map
/datum/lazy_template/virtual_domain/proc/add_points(points_to_add)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_GOAL_POINT, points_to_add)

/// Overridable proc to be called after the map is loaded.
/datum/lazy_template/virtual_domain/proc/setup_domain(list/created_atoms)
	return
