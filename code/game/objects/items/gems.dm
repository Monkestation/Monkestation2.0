/obj/item/gem
	name = "\improper Generic Gem"
	desc = "Oooh! Shiny!"
	icon = 'icons/obj/yogstation/gems.dmi'
	icon_state = "blood-drunk"
	w_class = WEIGHT_CLASS_SMALL
	/// The sheet this should spawn if its welded
	var/obj/item/stack/sheet/sheet_type = /obj/item/stack/sheet/iron

/obj/item/gem/Initialize()
	. = ..()
	add_overlay("shine")
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/gem/welder_act(mob/living/user, obj/item/I)
	if(I.use_tool(src, user, 0, volume = 50))
		new sheet_type(get_turf(src))
		to_chat(user, span_notice("You carefully cut [src]."))
		qdel(src)
	return TRUE

/obj/item/gem/blood_miner
	name = "\improper Stabilized Baroxuldium"
	desc = "A soft, glowing crystal only found in the deepest veins of plasma. Famed for its exceptional durability and uncommon beauty: widely considered to be a jackpot by mining crews. It looks like it could be destructively analyzed to extract the condensed materials within."
	icon_state = "blood-drunk"
	sheet_type = /obj/item/stack/sheet/mineral/plasma{amount = 50}
	light_outer_range = 2
	light_power = 2
	light_color = "#62326a"

/obj/item/gem/hierophant
	name = "\improper Densified Dilithium"
	desc = "A strange mass of dilithium which pulses to a steady rhythm. Its strange surface exudes a unique radio signal detectable by GPS. It looks like it could be destructively analyzed to extract the condensed materials within."
	icon_state = "hierophant"
	sheet_type = /obj/item/stack/sheet/glass{amount = 500} // Yes, 500.
	light_system = 1
	light_outer_range = 2
	light_power = 1
	light_color = "#b714cc"

/obj/item/gem/hierophant/Initialize()
	. = ..()
	new /obj/item/gps/internal/purple(src)
	update_light()

/obj/item/gps/internal/purple
	gpstag = "Harmonic Signal"
	desc = "It's ringing."
	invisibility = 100

/obj/item/gem/dragon
	name = "\improper Draconic Amber"
	desc = "A brittle, strange mineral that forms when an ash drake's blood hardens after death. Cherished by gemcutters for its faint glow and unique, soft warmth. Poacher tales whisper of the dragon's strength being bestowed to one that wears a necklace of this amber, though such rumors are fictitious."
	icon_state = "ashdrake"
	sheet_type = /obj/item/stack/sheet/mineral/gold{amount = 50}
	light_outer_range = 2
	light_power = 2
	light_color = "#FFBF00"

/obj/item/gem/colossus
	name = "\improper Null Crystal"
	desc = "A shard of stellar, crystallized energy. These strange objects occasionally appear spontaneously in areas where the bluespace fabric is largely unstable. Its surface gives a light jolt to those who touch it. Despite its size, it's absurdly light."
	icon_state = "colossus"
	sheet_type = /obj/item/stack/sheet/bluespace_crystal{amount = 20}
	light_outer_range = 2
	light_power = 1
	light_color = "#4785a4"

/obj/item/gem/bubblegum
	name = "\improper Ichorium"
	desc = "A weird, sticky substance, known to coalesce in the presence of otherwordly phenomena. While shunned by most spiritual groups, this gemstone has unique ties to the occult which find it handsomely valued by mysterious patrons."
	icon_state = "bubblegum"
	sheet_type = /obj/item/stack/sheet/runed_metal{amount = 25}
	light_outer_range = 2
	light_power = 3
	light_color = "#800000"

/*
/obj/item/gem/clockwork
	name = "\improper Densified Brass"
	desc = "Rat'vars influence over this world has been longer than any species may ever comprehend, yet nar'sie finally banished rat'var into his realm. Locking him out of this world.The clockwork defender's powersource was this gem you extracted, its still vibrant with energy"
	icon_state = "clockwork"
	sheet_type = /obj/item/stack/sheet/bronze{amount = 150} // its basically worse iron, lets give them a good bit of it
	light_outer_range = 4
	light_power = 4
	light_color = "#FFBF00"

/obj/item/gem/wendigo
	name = "\improper Condensed Bananium"
	desc = "Wendigo's famously feed on humans, this one seems to have been a primarily clown diet resulting in bananium atmos condensing themselfes in their stomach. This gem is the result"
	icon_state = "wendigo"
	sheet_type = /obj/item/stack/sheet/mineral/bananium{amount = 10}
	light_outer_range = 3
	light_power = 1
	light_color = "#ffee00"

/obj/item/gem/frost_miner
	name = "\improper Demon Core"
	desc = "A gem extracted from the core of a demon, its primary use is to negate any magic the enemy may have. Seems to not work against miner nanotrasen weaponry"
	icon_state = "colossus"
	sheet_type = /obj/item/stack/sheet/bluespace_crystal{amount = 50}
	light_outer_range = 3
	light_power = 3
	light_color = "#380a41"

/obj/item/gem/demon/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, null, null, FALSE)
*/
