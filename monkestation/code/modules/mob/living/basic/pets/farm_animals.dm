/mob/living/basic/chick
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "chick"
	head_icon = 'monkestation/icons/mob/pets_held.dmi'
	held_lh = 'monkestation/icons/mob/pets_held_lh.dmi'
	held_rh = 'monkestation/icons/mob/pets_held_rh.dmi'

/mob/living/basic/chicken
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'
	held_lh = 'monkestation/icons/mob/pets_held_lh.dmi'
	held_rh = 'monkestation/icons/mob/pets_held_rh.dmi'

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	//held_state = "[starting_prefix]_[icon_suffix]"
	head_icon = 'monkestation/icons/mob/pets_held_large.dmi'

// Unsprited crabs will not be worn, new sprites are welcome!

/mob/living/basic/chicken/clown
	worn_slot_flags = null

/mob/living/basic/chicken/cockatrice
	worn_slot_flags = null

/mob/living/basic/chicken/cotton_candy
	worn_slot_flags = null

/mob/living/basic/chicken/dream
	worn_slot_flags = null

/mob/living/basic/chicken/dreamsicle
	worn_slot_flags = null

/mob/living/basic/chicken/gary
	worn_slot_flags = null

/mob/living/basic/chicken/glass
	worn_slot_flags = null

/mob/living/basic/chicken/golden
	worn_slot_flags = null

/mob/living/basic/chicken/ixworth
	worn_slot_flags = null

/mob/living/basic/chicken/mime
	worn_slot_flags = null

/mob/living/basic/chicken/onagadori
	worn_slot_flags = null

/mob/living/basic/chicken/phoenix
	worn_slot_flags = null

/mob/living/basic/chicken/pigeon
	worn_slot_flags = null

/mob/living/basic/chicken/raptor
	worn_slot_flags = null

/mob/living/basic/chicken/rev_raptor
	worn_slot_flags = null

/mob/living/basic/chicken/robot
	worn_slot_flags = null

/mob/living/basic/chicken/silkie
	worn_slot_flags = null

/mob/living/basic/chicken/silkie_black
	worn_slot_flags = null

/mob/living/basic/chicken/silkie_white
	worn_slot_flags = null

/mob/living/basic/chicken/snowy
	worn_slot_flags = null

/mob/living/basic/chicken/spicy
	worn_slot_flags = null

/mob/living/basic/chicken/stone
	worn_slot_flags = null

/mob/living/basic/chicken/sword
	worn_slot_flags = null

/mob/living/basic/chicken/teshari
	worn_slot_flags = null

/mob/living/basic/chicken/turkey //Seems unused in game as the mob itself lacks sprites
	worn_slot_flags = null

/mob/living/basic/chicken/wiznerd
	worn_slot_flags = null

