/datum/uplink_category/stealthy_tools
	name = "Stealth Gadgets"
	weight = 6

/datum/uplink_item/stealthy_tools
	category = /datum/uplink_category/stealthy_tools

/datum/uplink_item/stealthy_tools/ai_detector
	name = "Artificial Intelligence Detector"
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it, and can be \
			activated to display their exact viewing location. Knowing when \
			an artificial intelligence is watching you is useful for knowing when to maintain cover, and finding nearby \
			blind spots can help you identify escape routes."
	item = /obj/item/multitool/ai_detect
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	cost = 1

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't \
			move the projector from their hand. Disguised users move slowly, and projectiles pass over them."
	item = /obj/item/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/codespeak_manual
	name = "Codespeak Manual"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random concepts and drinks to anyone listening. \
			This manual teaches you this Codespeak. You can also hit someone else with the manual in order to teach them. This is the deluxe edition, which has unlimited uses."
	item = /obj/item/language_manual/codespeak_manual/unlimited
	cost = 3

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-recharging, short-ranged EMP device disguised as a working flashlight. \
			Useful for disrupting headsets, cameras, doors, lockers and borgs during stealth operations. \
			Attacking a target with this flashlight will direct an EM pulse at it and consumes a charge."
	item = /obj/item/flashlight/emp
	cost = 4
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Screwed up and have security on your tail? This handy syringe will give you a completely new identity \
			and appearance."
	item = /obj/item/reagent_containers/syringe/mulligan
	cost = 4
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/jammer
	name = "Radio Jammer"
	desc = "This device will disrupt any nearby outgoing radio communication when activated. Does not affect binary chat."
	item = /obj/item/jammer
	cost = 1

/datum/uplink_item/stealthy_tools/telecomm_blackout
	name = "Disable Telecomms"
	desc = "When purchased, a virus will be uploaded to the telecommunication processing servers to temporarily disable themselves."
	item = ABSTRACT_UPLINK_ITEM
	surplus = 0
	progression_minimum = 15 MINUTES
	limited_stock = 1
	cost = 4
	restricted = TRUE
	cant_discount = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/telecomm_blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/communications_blackout, "a syndicate virus")
	return source //For log icon

/datum/uplink_item/stealthy_tools/blackout
	name = "Trigger Stationwide Blackout"
	desc = "When purchased, a virus will be uploaded to the engineering processing servers to force a routine power grid check, forcing all APCs on the station to be temporarily disabled."
	item = ABSTRACT_UPLINK_ITEM
	surplus = 0
	progression_minimum = 20 MINUTES
	limited_stock = 1
	cost = 5
	restricted = TRUE
	cant_discount = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/grid_check, "a syndicate virus")
	return source //For log icon

/datum/uplink_item/stealthy_tools/super_kitty_ears
	name = "Super Syndie-Kitty Ears"
	desc = "Developed by several Interdyne Pharmaceutics scientists and Wizard Federation archmages during a record-breaking rager, \
			this set of feline ears combines the finest of bio-engineering and thamaturgy to allow the user to transform to and from a cat at will, \
			granting them all the benefits (and downsides) of being a true feline, such as ventcrawling. \
			However, this form will be clad in blood-red Syndicate armor, making its origin somewhat obvious."
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/organ/internal/ears/cat/super/syndie
	cost = 14
	surplus = 5
	limited_stock = 1

/datum/uplink_item/stealthy_tools/sleepy_pen
	name = "Sleepy Pen"
	desc = "A syringe disguised as a functional pen, filled with a potent mix of drugs, including a \
			strong anesthetic and a chemical that prevents the target from speaking. \
			The pen holds one dose of the mixture, and can be refilled with any chemicals. Note that before the target \
			falls asleep, they will be able to move and act."
	item = /obj/item/pen/sleepy
	cost = 4
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/origami_kit
	name = "Boxed Origami Kit"
	desc = "This box contains a guide on how to craft masterful works of origami, allowing you to transform normal pieces of paper into \
			perfectly aerodynamic (and potentially lethal) paper airplanes."
	item = /obj/item/storage/box/syndie_kit/origami_bundle
	progression_minimum = 10 MINUTES
	cost = 2
	surplus = 50 //monkestation edit: from 0 to 50
	purchasable_from = ~UPLINK_NUKE_OPS //clown ops intentionally left in, because that seems like some s-tier shenanigans.

/datum/uplink_item/stealthy_tools/traitor_chem_bottle
	name = "Poison Kit"
	desc = "An assortment of deadly chemicals packed into a compact box. Comes with a syringe for more precise application."
	item = /obj/item/storage/box/syndie_kit/chemical
	cost = 6
	surplus = 50

/datum/uplink_item/stealthy_tools/suppressor
	name = "Suppressor"
	desc = "This suppressor will silence the shots of the weapon it is attached to for increased stealth and superior ambushing capability. It is compatible with many small ballistic guns including the Makarov, Stechkin APS and C-20r, but not revolvers or energy guns."
	item = /obj/item/suppressor
	cost = 1
	surplus = 10
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
