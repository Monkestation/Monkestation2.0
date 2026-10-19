/datum/uplink_category/spy_unique
	name = "Spy Unique"

// This is solely for uplink items that the spy can randomly obtain via bounties.
/datum/uplink_item/spy_unique
	category = /datum/uplink_category/spy_unique
	cant_discount = TRUE
	surplus = FALSE
	purchasable_from = UPLINK_SPY
	// Cost doesn't really matter since it's free, but it determines which loot pool it falls into.
	// By default, these fall into easy-medium spy bounty loot pool
	cost = SPY_LOWER_COST_THRESHOLD

/datum/uplink_item/spy_unique/syndie_bowman
	name = "Syndicate Bowman"
	desc = "A bowman headset for members of the Syndicate. Not very conspicuous."
	item = /obj/item/radio/headset/syndicate/alt
	cost = 1

/datum/uplink_item/spy_unique/combat_gloves
	name = "Combat Gloves"
	desc = "A pair of combat gloves. They're insulated!"
	item = /obj/item/clothing/gloves/combat
	cost = 1

/datum/uplink_item/spy_unique/krav_maga
	name = "Combat Gloves Plus"
	desc = "A pair of combat gloves plus. They're insulated AND you can do martial arts with it!"
	item = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	cost = 6

/datum/uplink_item/spy_unique/tackle_gloves
	name = "Guerrilla Gloves"
	desc = "A pair of Guerrilla gloves. They're insulated AND you can tackle people with it!"
	item = /obj/item/clothing/gloves/tackler/combat/insulated

/datum/uplink_item/spy_unique/switchblade
	name = "Switchblade"
	desc = "A switchblade. Switches between not sharp and sharp."
	item = /obj/item/switchblade

/datum/uplink_item/spy_unique/rifle_prime
	name = "Bolt-Action Rifle"
	desc = "A bolt-action rifle, with a scope. Won't jam, either."
	item = /obj/item/gun/ballistic/rifle/boltaction/prime
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/ansem_pistol
	name = "Ansem Pistol"
	desc = "A pistol that's really good at making people sleep."
	item = /obj/item/gun/ballistic/automatic/pistol/clandestine
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/rocket_launcher
	name = "Rocket Launcher"
	desc = "A rocket launcher. Launches rockets"
	item = /obj/item/gun/ballistic/rocketlauncher
	cost = 16

/datum/uplink_item/spy_unique/penbang
	name = "Penbang"
	desc = "A flashbang disguised as a normal pen - click and throw! Has no other warning upon being activated. \
		Fuse duration depends on how far the cap is twisted."
	item = /obj/item/pen/penbang
	cost = 1

/datum/uplink_item/spy_unique/cameraflash
	name = "Camera Flash"
	desc = "A camera with a high-powered flash. Can be used as a normal flash when in close proximity to a target."
	item = /obj/item/camera/flash
	cost = 1

/datum/uplink_item/spy_unique/monster_cube_box
	name = "Random Monster Cubes"
	desc = "A box containing a bunch of random monster cubes. Add water and see what you get!"
	item = /obj/item/storage/box/monkeycubes/random
	cost = SPY_LOWER_COST_THRESHOLD // There's some really bad stuff in here but also some really mild stuff

/datum/uplink_item/spy_unique/spider_bite
	name = "Spider Bite Technique"
	desc = "A scroll teaching you the basics of the Spider Bite martial art."
	item = /obj/item/book/granter/martial/spider_bite
	cost = SPY_UPPER_COST_THRESHOLD // While SCarp is firmly in the upper threshold, Spider Bite can be in either middle or upper.
