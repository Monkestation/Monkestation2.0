/// Associative list of available abilities by their unlock conditions.
/// Abilities that unlock based on a stat use the define of that stat as their key.
/// And ones that have a rank requirement use VAMPIRE_ABILITIES_RANK.
/// There's also VAMPIRE_ABILITIES_ALL if you need it for some reason.
/// The abilities in here are in typepath form.

/// list of all possible vampire abilities.
GLOBAL_LIST_INIT(vampire_all_abilities, init_available_vampire_abilities())
/// // Associative list of vampire abilities indexed by stat and then ability type, giving you the stat number that you need
GLOBAL_LIST(vampire_abilities_reqs)
/// Associative list of vampire abilities indexed by ability type containing the stat requirements
GLOBAL_LIST(vampire_abilities_stat)
/// Associative list of vampire abilities indexed by rank containing the abilities that unlock at that rank
GLOBAL_LIST(vampire_abilities_rank)

/// Initializes the list of available vampire abilities.
/proc/init_available_vampire_abilities()
	var/list/all = subtypesof(/datum/vampire_ability)
	GLOB.vampire_abilities_stat = list()
	GLOB.vampire_abilities_reqs = list()
	GLOB.vampire_abilities_rank = list()

	for(var/datum/vampire_ability/ability_type as anything in all)
		var/datum/vampire_ability/ability = new ability_type
		if(length(ability.stat_reqs))
			GLOB.vampire_abilities_reqs[ability_type] = ability.stat_reqs.Copy()

		if(ability.min_rank != 0)
			GLOB.vampire_abilities_rank["[ability.min_rank]"] += list(ability_type)

		for(var/stat_name in ability.stat_reqs)
			GLOB.vampire_abilities_stat[stat_name] += list(ability_type)

		qdel(ability)
	return all

