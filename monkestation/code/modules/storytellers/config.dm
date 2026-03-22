///Gamemode related configs below
// Point Gain Multipliers
/datum/config_entry/number/mundane_point_gain_multiplier
	default = 1
	min_val = 0

/datum/config_entry/number/moderate_point_gain_multiplier
	default = 1
	min_val = 0

/datum/config_entry/number/major_point_gain_multiplier
	default = 1
	min_val = 0

/datum/config_entry/number/roleset_point_gain_multiplier
	default = 1
	min_val = 0

/datum/config_entry/number/roleset_roundstart_point_multiplier
	default = 1
	min_val = 0

// Minimum population
/datum/config_entry/number/mundane_min_pop
	default = MUNDANE_MIN_POP
	integer = TRUE
	min_val = 0

/datum/config_entry/number/moderate_min_pop
	default = MODERATE_MIN_POP
	integer = TRUE
	min_val = 0

/datum/config_entry/number/major_min_pop
	default = MAJOR_MIN_POP
	integer = TRUE
	min_val = 0

/datum/config_entry/number/roleset_min_pop
	default = ROLESET_MIN_POP
	integer = TRUE
	min_val = 0

// Point Thresholds
/datum/config_entry/number/mundane_point_threshold
	default = MUNDANE_POINT_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/number/moderate_point_threshold
	default = MODERATE_POINT_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/number/major_point_threshold
	default = MAJOR_POINT_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/number/roleset_point_threshold
	default = ROLESET_POINT_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/flag/allow_storyteller_pop_scaling // Allows storyteller to scale down the event frequency by population

// Pop scalling thresholds
/datum/config_entry/number/mundane_pop_scale_threshold
	default = MUNDANE_POP_SCALE_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/number/moderate_pop_scale_threshold
	default = MODERATE_POP_SCALE_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/number/major_pop_scale_threshold
	default = MAJOR_POP_SCALE_THRESHOLD
	integer = TRUE
	min_val = 0

/datum/config_entry/number/roleset_pop_scale_threshold
	default = ROLESET_POP_SCALE_THRESHOLD
	integer = TRUE
	min_val = 0

// Pop scalling penalties
/datum/config_entry/number/mundane_pop_scale_penalty
	default = MUNDANE_POP_SCALE_PENALTY
	integer = TRUE
	min_val = 0

/datum/config_entry/number/moderate_pop_scale_penalty
	default = MODERATE_POP_SCALE_PENALTY
	integer = TRUE
	min_val = 0

/datum/config_entry/number/major_pop_scale_penalty
	default = MAJOR_POP_SCALE_PENALTY
	integer = TRUE
	min_val = 0

/datum/config_entry/number/roleset_pop_scale_penalty
	default = ROLESET_POP_SCALE_PENALTY
	integer = TRUE
	min_val = 0
