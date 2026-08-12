/obj/structure/closet/crate/necropolis/surplus
	name = "busted necropolis chest"
	desc = "The lock seems to have been busted open somehow and there is a big orange sticker that reads <b> Quality Not Guranteed <b/>"
	icon_state = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	can_install_electronics = FALSE
	var/loot = 0 // Cough, admins you can change this before the crate is opened

/obj/structure/closet/crate/necropolis/surplus/Initialize(mapload)
	. = ..()
	loot = rand(1,100)

/obj/structure/closet/crate/necropolis/surplus/PopulateContents()
	switch(loot)
		if(1 to 40) // regular tendril loot
			new /obj/effect/spawner/random/mining_loot(src)
		if(41 to 43) //Junk drops start here ----
			for(var/index in 1 to 4)
				new /obj/item/toy/figure/syndie(src)
			new /obj/item/disk/nuclear/fake/obvious(src)
			new /obj/item/toy/nuke(src)
			new /obj/item/toy/balloon/syndicate(src)
			new /obj/item/storage/box/syndimaid(src)
		if(44 to 46)
			new /obj/item/cardboard_cutout/xeno_maid(src)
			new	/obj/item/clothing/neck/maid(src)
			new	/obj/item/clothing/head/costume/maidheadband(src)
			new	/obj/item/clothing/gloves/maid(src)
			new /obj/item/clothing/under/costume/maid(src)
			new /obj/structure/sign/poster/official/no_erp(src)
			new /obj/item/slimepotion/lovepotion(src)
		if(47 to 49)
			for(var/index in 1 to 3)
				new /mob/living/basic/spider/maintenance(src)
			new /obj/structure/spider/cocoon(src)
			new /obj/item/dnainjector/webbing(src)
			new /obj/item/toy/plush/spider(src)
			new /obj/structure/spider/stickyweb(src)
		if(50 to 52)
			for(var/obj/item/book/granter/crafting_recipe/maint_gun/gun_book as anything in subtypesof(/obj/item/book/granter/crafting_recipe/maint_gun))
				new gun_book(src)
			new /obj/item/book/granter/crafting_recipe/trash_cannon(src)
			new /obj/effect/decal/cleanable/garbage(src)
			new /obj/item/storage/pill_bottle/maintenance_pill/full(src)
			new /obj/item/trash/syndi_cakes(src)
			new /obj/item/paper/crumpled(src)
			new /obj/item/trash/popcorn(src)
			new /obj/item/trash/can/food/peaches/maint(src)
			new /obj/item/storage/cans(src)
		if(53 to 55)
			new /obj/item/toy/crayon/spraycan/lubecan(src)
			new /obj/item/inspector/clown(src)
			new /obj/item/pillow/clown(src)
			new /obj/item/megaphone/clown(src)
			new /obj/item/grown/bananapeel(src)
		if(56 to 58)
			new /obj/item/clothing/head/costume/kitty(src)
			new /obj/item/clothing/under/costume/schoolgirl(src)
			new /obj/item/clothing/neck/petcollar(src)
			new /mob/living/simple_animal/pet/cat(src)
			new /obj/item/toy/cattoy(src)
			new /obj/item/slimepotion/slime/sentience(src)
		if(59 to 61)
			new /mob/living/basic/pet/dog/corgi/puppy(src)
			new /mob/living/basic/pet/dog/corgi/exoticcorgi(src)
			new /mob/living/basic/pet/dog/corgi/lisa(src)
			new /obj/structure/sign/poster/quirk/service_logo(src)
			new /obj/item/toy/balloon/corgi(src)
			new /obj/item/clothing/suit/costume/ianshirt(src)
			new /obj/item/clothing/suit/hooded/ian_costume(src)
			new /obj/item/dnainjector/olfaction(src)
		if(62 to 64)
			for(var/index in 1 to 5)
				new /obj/item/food/grown/banana(src)
			new /obj/item/seeds/banana(src)
			new /obj/item/toy/plush/moth/ookplush(src)
			new /mob/living/carbon/human/species/monkey/dukeman(src)
			new /obj/item/dnainjector/h2m(src)
		if(65 to 67)
			for(var/index in 1 to 4)
				new /obj/item/pickaxe/rusted(src)
				new /obj/item/dnainjector/dwarf(src)
			new /obj/structure/closet/crate/miningcar(src)
		if(68 to 70)
			new /obj/item/gun/ballistic/rifle/boltaction(src)
			new /obj/item/clothing/head/costume/ushanka(src)
			new /obj/item/reagent_containers/cup/glass/bottle/vodka/badminka(src) //Courtesy of Maine on their request
			new /obj/item/clothing/under/costume/soviet(src)
			new /obj/effect/decal/hammerandsickle(src) //fuck you - imprints communism onto your floor
		if(71 to 73)
			new /obj/item/instrument/piano_synth/headphones/spacepods(src)
			new /obj/item/clothing/shoes/swagshoes(src)
			new /obj/item/clothing/under/costume/swagoutfit(src)
			new /obj/item/clothing/neck/necklace/dope(src)
		if(74 to 76)
			for(var/index in 1 to 10)
				new /obj/item/stack/ore/slag(src)
		if(77 to 79)
			new /obj/item/storage/belt/military/snack(src)
			new /obj/item/knife/combat(src)
			new /obj/item/clothing/gloves/color/black(src)
			new /obj/item/clothing/under/rank/centcom/military/eng(src)
			new /obj/item/clothing/suit/armor/vest/old(src)
		if(80 to 82) //fuck you get a key - nanotrasen
			new /obj/structure/closet/crate/necropolis/tendril(src)
		if(83 to 92) // The rare drops start here ---- the bonus loot for risking 20k points
			var/list/crusher_trophies = list(
				/obj/item/crusher_trophy/bear_paw,
				/obj/item/crusher_trophy/wolf_ear,
				/obj/item/crusher_trophy/vortex_talisman,
				/obj/item/crusher_trophy/miner_eye,
				/obj/item/crusher_trophy/tail_spike,
				/obj/item/crusher_trophy/blaster_tubes,
				/obj/item/crusher_trophy/legionnaire_spine,
				/obj/item/clothing/accessory/pandora_hope,
				/obj/item/crusher_trophy/broodmother_tongue,
				/obj/item/clothing/neck/cloak/herald_cloak,
			)
			var/obj/item/crusher_trophy/random_trophy = pick(crusher_trophies)
			new random_trophy(src)
		if(93) //kaboom :>
			new /obj/item/toy/plush/ratplush(src)
			new /obj/item/toy/plush/narplush(src)
		if(94)
			new /obj/machinery/nuclearbomb/bee(src)
		if(95)
			new /obj/item/melee/cleaving_saw(src)
		if(96)
			new /mob/living/simple_animal/hostile/asteroid/elite/broodmother_child(src)
		if(97)
			new /obj/item/gibtonite(src)
		if(98)
			var/list/coins_to_drop = list(
				/obj/item/coin/silver,
				/obj/item/coin/gold,
				/obj/item/coin/plasma,
				/obj/item/coin/diamond,
				/obj/item/coin/adamantine,
				/obj/item/coin/bananium,
			)
			for(var/obj/item/coin/coin as anything in coins_to_drop)
				for(var/index in 1 to 3)
					new coin(src)
		if(99) //100,000 CREDITS
			for(var/index in 1 to 10)
				new /obj/item/stack/spacecash/c10000(src)
		if(100) //Jackpot
			new /obj/item/storage/backpack/holding(src)

/obj/item/cardboard_cutout/xeno_maid
	starting_cutout = "Xenomorph Maid"
