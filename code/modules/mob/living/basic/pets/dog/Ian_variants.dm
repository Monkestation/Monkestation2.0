/// Stores Ian variants, as datums
/// Ian picks one at random when he spawns

/datum/ian_variant
	var/name = "Ian"
	var/desc = "He's the HoP's beloved corgi."
	var/icon = 'icons/mob/simple/pets.dmi'
	var/base_icon_state = "corgi"
	var/icon_living = "corgi"
	var/icon_dead = "corgi_dead"
	var/held_state = "corgi"
	/// The weight of the variant. This base variant should usually be the highest, see pick_weight in _lists.dm
	var/weight = 8
	/// If this variant cna be randomly picked
	var/random_pickable = TRUE

///Applies the variant to the ian mob, requires a ian mob be passed
/datum/ian_variant/proc/init_variant(mob/living/basic/pet/dog/corgi/ian/doggo)
	doggo.icon = icon
	doggo.icon_state = base_icon_state
	doggo.icon_living = icon_living
	doggo.icon_dead = icon_dead
	doggo.held_state = held_state
	doggo.desc = desc
	doggo.name = name
	doggo.real_name = name

/datum/ian_variant/old
	base_icon_state = "old_corgi"
	icon_living = "old_corgi"
	held_state = "old_corgi"
	icon_dead = "old_corgi_dead"
	random_pickable = FALSE

/datum/ian_variant/old/init_variant(mob/living/basic/pet/dog/corgi/ian/doggo)
	..()
	doggo.desc = "At a ripe old age of [doggo.record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
	doggo.ai_controller?.set_blackboard_key(BB_DOG_IS_SLOW, TRUE)
	doggo.is_slow = TRUE
	doggo.speed = 2

/datum/ian_variant/dinosaur_ian
	base_icon_state = "corgi_dinosaur"
	icon_living = "corgi_dinosaur"
	icon_dead	= "corgi_dead_dinosaur"
	desc = "Its Ian! The HOP's beloved corgi. Someone has dressed him in a dinosaur costume, how cute!"
	weight = 6

/datum/ian_variant/expiean
	base_icon_state = "corgi_expie"
	icon_living = "corgi_expie"
	icon_dead	= "corgi_dead_expie"
	desc = "A byproduct from a unknown NT testing station, this Ian has a slightly off looking coat..."
	weight = 2
