/datum/battle_royale_data
	///When does this dataset take effect
	var/active_time = 0
	///What does this set the weight of common loot drops to
	var/common_weight = 0
	///What does this set the weight of utility loot drops to
	var/utility_weight = 0
	///What does this set the weight of rare loot drops to
	var/rare_weight = 0
	///What does this set the weight of super rare loot drops to
	var/super_rare_weight = 0
	///What does this set the weight of misc loot drops to
	var/misc_weight = 0
	///What does this set the prob of spawning something from the extra loot table to
	var/extra_loot_prob = 0
	///What does this set the prob of doing a rare drop to
	var/rare_drop_prob = 0
	///What does this set the prob of doing a super drop to
	var/super_drop_prob = 0
	///How many loot pods do we spawn per second, can be less then 1
	var/pods_per_second = 0

//Used for admin custom royale data sets
/datum/battle_royale_data/custom/New(input_active_time)
	. = ..()
/*	active_time = input_active_time
	GLOB.custom_battle_royale_data["[active_time]"] = src*/

/datum/battle_royale_data/custom/Destroy(force, ...)
	GLOB.custom_battle_royale_data -= "[active_time]"
	return ..()

//premade set which lasts at most 25 minutes
/datum/battle_royale_data/normal
	utility_weight = 3
	misc_weight = 2
	extra_loot_prob = 10
	pods_per_second = 0.3
	rare_drop_prob = 4

//used for the initial pods dropped at the start of the royale
/datum/battle_royale_data/normal/start
	active_time = 1
	common_weight = 12
	utility_weight = 14
	rare_weight = 4

/datum/battle_royale_data/normal/one_second
	active_time = 1 SECONDS
	common_weight = 12
	utility_weight = 12

/datum/battle_royale_data/normal/three_minutes
	active_time = 3 MINUTES
	common_weight = 12
	utility_weight = 8

/datum/battle_royale_data/normal/six_minutes
	active_time = 6 MINUTES
	common_weight = 12
	utility_weight = 6
	rare_weight = 3
	super_drop_prob = 0.5

/datum/battle_royale_data/normal/nine_minutes
	active_time = 9 MINUTES
	common_weight = 10
	utility_weight = 4
	rare_weight = 3
	super_drop_prob = 1

/datum/battle_royale_data/normal/eleven_minutes
	active_time = 11 MINUTES
	common_weight = 5
	rare_weight = 8
	super_rare_weight = 2
	extra_loot_prob = 15
	rare_drop_prob = 6
	super_drop_prob = 4

//premade set which lasts at most 10 minutes
/datum/battle_royale_data/fast
	common_weight = 3
	utility_weight = 3
	rare_weight = 3
	misc_weight = 2
	extra_loot_prob = 15
	rare_drop_prob = 6
	super_drop_prob = 1
	pods_per_second = 0.4

/datum/battle_royale_data/fast/start
	active_time = 1
	common_weight = 10
	utility_weight = 15

/datum/battle_royale_data/fast/one_second
	active_time = 1 SECONDS
	common_weight = 10
	utility_weight = 10

/datum/battle_royale_data/fast/one_minute
	active_time = 1 MINUTES
	common_weight = 10
	utility_weight = 5

/datum/battle_royale_data/fast/two_minutes_thrity_seconds
	active_time = 2.5 MINUTES
	common_weight = 5
	rare_weight = 4
	super_drop_prob = 1.5

/datum/battle_royale_data/fast/five_minutes
	active_time = 5 MINUTES
	rare_weight = 5
	super_drop_prob = 2.5

/datum/battle_royale_data/fast/seven_minutes_thirty_seconds
	active_time = 7.5 MINUTES
	rare_weight = 6
	super_rare_weight = 1
	super_drop_prob = 3.5
	pods_per_second = 0.3
