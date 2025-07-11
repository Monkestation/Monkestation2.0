/datum/bounty/item/bot/cleanbot_jr //JR. models to prevent them from mass selling station cleanbots
	name = "Scrubs Junior., PA"
	description = "Medical is looking worse than the kitchen cold room and janitors are nowhere to be found. We need a cleanbot for medical before the Chief Medical Officer has a breakdown."
	reward = CARGO_CRATE_VALUE * 2.5
	wanted_types = list(/mob/living/basic/bot/cleanbot/medbay/jr = TRUE)

/datum/bounty/item/bot/repairbot
	name = "Repairbot"
	description = "Out last Repairbot went haywire and removed all our floors. So we need another repairbot to replace the priors issues."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/mob/living/basic/bot/repairbot = TRUE)

/datum/bounty/item/bot/honkbot
	name = "Honkbot"
	description = "Mr. Gigglesworth birthday is around the corner and we didn't get a present. Ship us off a honkbot to giftwrap please."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/mob/living/basic/bot/secbot/honkbot = TRUE)

/datum/bounty/item/bot/firebot
	name = "Firebot"
	description = "An assistant waving around some license broke into atmospherics and its now all on fire. Send us a Firebot before the gas fire leaks further."
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/mob/living/basic/bot/firebot = TRUE)
