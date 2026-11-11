/datum/vampire_clan/lasombra
	name = CLAN_LASOMBRA
	description = "This Clan seems to adore living in the Shadows, worshipping it's secrets. \n\
		They take their research and vanity seriously, they are always very proud of themselves after even minor achievements. \n\
		They seek out stations where nullspace runs thin, so they can reach in and steal its darkness. \n\
		Thanks to this, they have also evolved a dark liquid in their veins, which makes them able to manipulate shadows."
	join_icon_state = "lasombra"
	joinable_clan = TRUE
	default_humanity = 7

/datum/vampire_clan/lasombra/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/dominate(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/obtenebration(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/potence(vampiredatum)

// the regular vampire one gets stripped by blush of life, this one doesn't
/datum/vampire_clan/lasombra/apply_effects(mob/living/body)
	ADD_TRAIT(body, TRAIT_NO_MIRROR_REFLECTION, REF(src))

/datum/vampire_clan/lasombra/remove_effects(mob/living/body)
	REMOVE_TRAIT(body, TRAIT_NO_MIRROR_REFLECTION, REF(src))
