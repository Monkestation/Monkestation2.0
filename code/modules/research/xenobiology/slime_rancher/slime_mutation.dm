/// What a slime must eat or drain to mutate into another type.
/datum/slime_mutation
	/// The slime type we pass on if we succeed
	var/datum/slime_type/mutates_into
	/// Items still needed to feed the slime in order to mutate.
	/// Items are removed as the slime eats them.
	var/list/needed_items
	/// The mobs still needed to be latch fed in order to mutate - stored as [mob type] = health drained (reduced as the slime eats said mobs)
	var/alist/latch_needed
	/// If TRUE, then you can't get this color from a random mutator syringe
	var/syringe_blocked = FALSE
	/// The slime working through this mutation.
	var/mob/living/basic/slime/our_slime
	/// The full item list from before the slime ate any of it - scanners need it to show what's already done
	var/list/total_items
	/// Same deal for the drain requirements: [mob type] = health that had to be drained
	var/alist/latch_totals

/datum/slime_mutation/New(mob/living/basic/slime/our_slime)
	src.our_slime = our_slime
	total_items = needed_items?.Copy()
	latch_totals = latch_needed?.Copy()
	RegisterSignal(our_slime, COMSIG_SLIME_CHECK_WANTED_ITEM, PROC_REF(on_check_wanted_item))
	RegisterSignal(our_slime, COMSIG_SLIME_ATE_ITEM, PROC_REF(on_ate_item))

/datum/slime_mutation/Destroy()
	UnregisterSignal(our_slime, list(COMSIG_SLIME_CHECK_WANTED_ITEM, COMSIG_SLIME_ATE_ITEM))
	our_slime = null
	return ..()

/// TRUE once the slime has eaten and drained everything this needs.
/datum/slime_mutation/proc/is_satisfied()
	return !length(needed_items) && !length(latch_needed)

/// Whether the slime has already eaten or drained anything toward this.
/datum/slime_mutation/proc/has_progress()
	if(length(needed_items) < length(total_items) || length(latch_needed) < length(latch_totals))
		return TRUE
	for(var/mob_type, drain_left in latch_needed)
		if(drain_left < latch_totals[mob_type])
			return TRUE
	return FALSE

/datum/slime_mutation/proc/on_check_wanted_item(mob/living/basic/slime/source, obj/item/meal)
	SIGNAL_HANDLER
	for(var/needed_type in needed_items)
		if(istype(meal, needed_type))
			return COMPONENT_SLIME_WANTS_ITEM

/datum/slime_mutation/proc/on_ate_item(mob/living/basic/slime/source, meal_type)
	SIGNAL_HANDLER
	for(var/needed_type in needed_items)
		if(ispath(meal_type, needed_type))
			needed_items -= needed_type
			return

/// Called straight from the slime's own drain handler, so quotas update before it checks for an outcome.
/datum/slime_mutation/proc/on_latch_drained(mob/living/meal, drained)
	drained = ceil(drained * 1.5)
	for(var/mob_type, drain_left in latch_needed)
		if(!istype(meal, mob_type))
			continue
		drain_left -= drained
		if(drain_left > 0)
			latch_needed[mob_type] = drain_left
			continue
		latch_needed -= mob_type

/datum/slime_mutation/metal
	mutates_into = /datum/slime_type/metal
	needed_items = list(/obj/item/stack/sheet/iron)

/datum/slime_mutation/orange
	mutates_into = /datum/slime_type/orange
	needed_items = list(/obj/item/stack/sheet/mineral/plasma)

/datum/slime_mutation/purple
	mutates_into = /datum/slime_type/purple
	needed_items = list(/obj/item/stack/medical/gauze)

/datum/slime_mutation/blue
	mutates_into = /datum/slime_type/blue
	latch_needed = alist(/mob/living/basic/cockroach/iceroach = 50)

/datum/slime_mutation/cerulean
	mutates_into = /datum/slime_type/cerulean
	latch_needed = alist(/mob/living/basic/cockroach/gemroach = 40)

/datum/slime_mutation/darkblue
	mutates_into = /datum/slime_type/darkblue
	latch_needed = alist(/mob/living/basic/xenofauna/diyaab = 75)

/datum/slime_mutation/red
	mutates_into = /datum/slime_type/red
	latch_needed = alist(/mob/living/basic/xenofauna/lavadog = 50)

/datum/slime_mutation/oil
	mutates_into = /datum/slime_type/oil
	latch_needed = alist(/mob/living/basic/xenofauna/dron = 65)

/datum/slime_mutation/yellow
	mutates_into = /datum/slime_type/yellow
	needed_items = list(/obj/item/stock_parts/power_store/cell)

/datum/slime_mutation/green
	mutates_into = /datum/slime_type/green
	latch_needed = alist(/mob/living/basic/xenofauna/greeblefly = 65)

/datum/slime_mutation/sepia
	mutates_into = /datum/slime_type/sepia
	latch_needed = alist(/mob/living/basic/xenofauna/possum = 65)

/datum/slime_mutation/black
	mutates_into = /datum/slime_type/black
	latch_needed = alist(/mob/living/basic/xenofauna/thoom = 50)

/datum/slime_mutation/silver
	mutates_into = /datum/slime_type/silver
	latch_needed = alist(/mob/living/basic/xenofauna/meatbeast = 80)

/datum/slime_mutation/gold
	mutates_into = /datum/slime_type/gold
	needed_items = list(/obj/item/stack/sheet/mineral/gold)

/datum/slime_mutation/adamantine
	mutates_into = /datum/slime_type/adamantine
	needed_items = list(/obj/item/stack/sheet/mineral/diamond)

/datum/slime_mutation/darkpurple
	mutates_into = /datum/slime_type/darkpurple
	needed_items = list(/obj/item/slime_extract/purple)

/datum/slime_mutation/pink
	mutates_into = /datum/slime_type/pink
	latch_needed = alist(/mob/living/basic/xenofauna/thinbug = 80)

/datum/slime_mutation/pyrite
	mutates_into = /datum/slime_type/pyrite
	needed_items = list(/obj/item/toy/crayon/rainbow)

/datum/slime_mutation/bluespace
	mutates_into = /datum/slime_type/bluespace
	needed_items = list(/obj/item/stack/ore/bluespace_crystal)

/datum/slime_mutation/bluespace/on_check_wanted_item(mob/living/basic/slime/source, obj/item/meal)
	if(istype(meal, /obj/item/stack/sheet/bluespace_crystal) && (/obj/item/stack/ore/bluespace_crystal in needed_items))
		return COMPONENT_SLIME_WANTS_ITEM
	return ..()

/datum/slime_mutation/bluespace/on_ate_item(mob/living/basic/slime/source, meal_type)
	if(ispath(meal_type, /obj/item/stack/sheet/bluespace_crystal))
		meal_type = /obj/item/stack/ore/bluespace_crystal
	return ..()

/datum/slime_mutation/lightpink
	mutates_into = /datum/slime_type/lightpink
	latch_needed = alist(/mob/living/basic/xenofauna/voxslug = 80)

/datum/slime_mutation/rainbow
	mutates_into = /datum/slime_type/rainbow
	needed_items = list(
		/obj/item/slime_extract/orange,
		/obj/item/slime_extract/purple,
		/obj/item/slime_extract/blue,
		/obj/item/slime_extract/metal,
		/obj/item/slime_extract/yellow,
		/obj/item/slime_extract/darkblue,
		/obj/item/slime_extract/darkpurple,
		/obj/item/slime_extract/silver,
	)
	syringe_blocked = TRUE
