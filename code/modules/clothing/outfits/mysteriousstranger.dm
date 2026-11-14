/datum/outfit/myststranger
	name = "A Mysterious Stranger"

	id = /obj/item/card/id/advanced/debug
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit_store = /obj/item/tank/internals/oxygen/yellow
	back = /obj/item/mod/control/pre_equipped/myststranger
	box = /obj/item/storage/box/material
	backpack_contents = list(
		/obj/item/melee/energy/axe/lone_wanderer = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/medkit/lone_wanderer_medkit = 1,
		/obj/item/gun/ballistic/revolver/lone_wanderer = 1,
		/obj/item/gps/advanced/lone_wanderer = 1,
		/obj/item/holochip/tenthousand = 1,
		/obj/item/construction/rcd/combat/admin = 1,
		/obj/item/pipe_dispenser = 1
	)
	belt = /obj/item/defibrillator/compact/combat/loaded/nanotrasen
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/debug
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots/advance
	mask = /obj/item/clothing/mask/chameleon

	r_pocket = /obj/item/reagent_containers/medipen/lone_wanderer/single
	l_pocket = /obj/item/reagent_containers/medipen/lone_wanderer/single_painkiller

	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/myststranger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = "Mysterious Stranger"
	W.assignment = "???"
	W.update_label()
	W.update_icon()
	var/obj/item/implant/vanish/impl = new /obj/item/implant/vanish(H)//poof
	impl.implant(H, null, silent = TRUE)
	///Mysterious Stranger has been everywhere, they are everywhere; they might as well be god.
	///Im gonna put this note here, please dont fucking use this to interfere with antags unless they ask for it.
	///Now you may ask, why a massive list of traits and not just godmode?
	///Simple: Its funny, I'd like to think the mysterious stranger can die, just... good luck.
	H.add_traits(list(TRAIT_ALL_SURGERIES,TRAIT_ASHSTORM_IMMUNE,TRAIT_BATON_RESISTANCE, \
	TRAIT_SHOCKIMMUNE,TRAIT_IMPACTIMMUNE,TRAIT_LAVA_IMMUNE,TRAIT_XENO_IMMUNE,TRAIT_MADNESS_IMMUNE,TRAIT_WEATHER_IMMUNE,TRAIT_RADSTORM_IMMUNE, \
	TRAIT_TENTACLE_IMMUNE,TRAIT_OVERWATCH_IMMUNE,TRAIT_PUSHIMMUNE,TRAIT_RUSTIMMUNE,TRAIT_RADIMMUNE,TRAIT_TOXIMMUNE,TRAIT_BOMBIMMUNE,TRAIT_NUKEIMMUNE, \
	TRAIT_SNOWSTORM_IMMUNE,TRAIT_TIME_STOP_IMMUNE,TRAIT_STUNIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_TESLA_SHOCKIMMUNE,TRAIT_KNOW_ENGI_WIRES,TRAIT_KNOW_ROBO_WIRES,\
	TRAIT_BRAIN_TRAUMA_IMMUNITY,TRAIT_VIRUSIMMUNE,TRAIT_NO_MINDSWAP,TRAIT_NEVER_WOUNDED,TRAIT_TOWER_OF_BABEL,TRAIT_IGNORESLOWDOWN,\
	TRAIT_FEARLESS,TRAIT_NO_SLIP_ALL,TRAIT_FAST_CLIMBER,TRAIT_FAST_CUFFING,TRAIT_FASTMED,TRAIT_PERFECT_SURGEON,TRAIT_PERFECT_ATTACKER,\
	TRAIT_TASER_RESISTANCE,TRAIT_RESISTCOLD,TRAIT_RESISTHEAT,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NODISMEMBER,\
	TRAIT_NOHUNGER,TRAIT_NO_ZOMBIFY,TRAIT_EMBED_RESISTANCE,TRAIT_NOBREATH,TRAIT_GRABRESISTANCE,TRAIT_STRONG_STOMACH,TRAIT_ANTIMAGIC_NO_SELFBLOCK,\
	TRAIT_MAGICALLY_GIFTED,TRAIT_NOSOFTCRIT,TRAIT_NOHARDCRIT,TRAIT_MINDSHIELD,TRAIT_UNCONVERTABLE,TRAIT_PRESSURE_FLING_RESISTANT,\
	TRAIT_PLANT_SAFE,TRAIT_QUICKER_CARRY,TRAIT_QUICK_BUILD,TRAIT_NOFLASH,TRAIT_DETECT_STORM,TRAIT_DOUBLE_TAP,TRAIT_CANT_STAMCRIT,\
	TRAIT_ROD_SUPLEX))

	H.apply_status_effect(/datum/status_effect/ancient_caretaker,-1,TRUE)
