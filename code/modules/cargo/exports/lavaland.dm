//Tendril chest artifacts and ruin loot.
//Consumable or one-use items like the magic D20 and gluttony's blessing are omitted
/datum/export/lavaland
	k_elasticity = 0

/datum/export/lavaland/minor
	cost = CARGO_CRATE_VALUE * 30
	unit_name = "minor lava planet artifact"
	export_types = list(/obj/item/book_of_babel,
						/obj/item/wisp_lantern,
						/obj/item/katana/cursed,
						/obj/item/clothing/glasses/godeye,
						/obj/item/melee/ghost_sword,
						/obj/item/organ/internal/heart/cursed/wizard,
						/obj/item/clothing/suit/hooded/cloak/drake,
						/obj/item/ship_in_a_bottle,
						/obj/item/clothing/shoes/clown_shoes/banana_shoes,
						/obj/item/gun/magic/staff/honk,
						/obj/item/knife/envy,
						/obj/item/gun/ballistic/revolver/russian/soul,
						/obj/item/veilrender/vealrender,
						/obj/item/freeze_cube,
						/obj/item/soulstone/anybody/mining,
						/obj/item/clothing/gloves/gauntlets,
						/obj/item/jacobs_ladder,
						/obj/item/clothing/suit/hooded/cultrobes/hardened,
						)

/datum/export/lavaland/major //valuable chest/ruin loot, minor megafauna loot
	cost = CARGO_CRATE_VALUE * 50
	unit_name = "lava planet artifact"
	export_types = list(
		/obj/item/dragons_blood,
		/obj/item/guardian_creator/miner,
		/obj/item/drake_remains,
		/obj/item/lava_staff,
		/obj/item/melee/ghost_sword,
		/obj/item/prisoncube,
		/obj/item/rod_of_asclepius,
		/obj/item/immortality_talisman,
		/obj/item/clothing/neck/necklace/memento_mori,
		/obj/item/book/granter/action/spell/summonitem,
		/obj/item/book/granter/action/spell/sacredflame,
		/obj/item/organ/internal/cyberimp/arm/item_set/katana,
		/obj/item/clothing/suit/hooded/berserker,
	)

//Megafauna loot, except for ash drakes

/datum/export/lavaland/megafauna
	cost = CARGO_CRATE_VALUE * 125
	unit_name = "major lava planet artifact"
	export_types = list(/obj/item/hierophant_club,
						/obj/item/melee/cleaving_saw,
						/obj/item/organ/internal/vocal_cords/colossus,
						/obj/machinery/anomalous_crystal,
						/obj/item/mayhem,
						/obj/item/gun/magic/staff/spellblade,
						/obj/item/storm_staff,
						/obj/item/clothing/suit/hooded/hostile_environment,
						)

/datum/export/lavaland/megafauna/total_printout(datum/export_report/ex, notes = TRUE) //in the unlikely case a miner feels like selling megafauna loot
	. = ..()
	if(. && notes)
		. += " On behalf of the Nanotrasen RnD division: Thank you for your hard work."

/datum/export/lavaland/gibtonite
	cost = CARGO_CRATE_VALUE * 10
	unit_name = "gibtonite chunk"
	export_types = list(/obj/item/gibtonite)
	var/gibtonite_quality

/datum/export/lavaland/gibtonite/total_printout(datum/export_report/ex, notes = TRUE) //in the unlikely case a miner feels like selling megafauna loot
	. = ..()
	if(. && notes)
		switch(gibtonite_quality)
			if(GIBTONITE_QUALITY_HIGH)
				. += " (Grade A Shipment) On behalf of the Nanotrasen RnD division: Thank you for your hard work."
			if(GIBTONITE_QUALITY_MEDIUM)
				. += " (Grade B Shipment)"
			if(GIBTONITE_QUALITY_LOW)
				. += " (Grade C Shipment)"

/datum/export/lavaland/gibtonite/get_cost(obj/item/gibtonite/bombrock)
	gibtonite_quality = bombrock.quality
	switch(bombrock.quality)
		if(GIBTONITE_QUALITY_HIGH)
			return CARGO_CRATE_VALUE * 50
		if(GIBTONITE_QUALITY_MEDIUM)
			return CARGO_CRATE_VALUE * 30
		if(GIBTONITE_QUALITY_LOW)
			return CARGO_CRATE_VALUE * 15

