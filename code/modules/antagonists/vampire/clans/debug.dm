#ifdef VAMPIRE_TESTING
// debug clan with every discipline
/datum/vampire_clan/debug
	name = "Debug Clan"
	description = "wtf you shouldn't be seeing this outside of testing"
	default_humanity = 10
	princely_score_bonus = 99
	joinable_clan = TRUE

/datum/vampire_clan/debug/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.vampire_level_unspent = 35
	vampiredatum.owned_disciplines += new /datum/discipline/auspex/malkavian(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/celerity(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/dominate/ventrue(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/fortitude(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/potence/brujah(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/thaumaturgy(vampiredatum)
#endif
