// This file contains all boxes used by the Engineering department and its purpose on the station. Also contains stuff we use when we wanna fix up stuff as well or helping us live when shit goes southwardly.

/obj/item/storage/box/metalfoam
	name = "box of metal foam grenades"
	desc = "To be used to rapidly seal hull breaches."
	illustration = "metalfoam"
	custom_price = PAYCHECK_COMMAND

/obj/item/storage/box/metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/metalfoam(src)

/obj/item/storage/box/smart_metalfoam
	name = "box of smart metal foam grenades"
	desc = "Used to rapidly seal hull breaches. This variety conforms to the walls of its area."
	icon_state = "engbox"
	illustration = "metalfoam"

/obj/item/storage/box/smart_metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/smart_metalfoam(src)

/obj/item/storage/box/nanofrost
	name = "box of nanofrost grenades"
	desc = "A box of A NanoFrost™ smoke grenades. Nanotrasen's response to frequent plasma related fires onboard their research stations."
	icon_state = "engbox"
	illustration = "nanofrost"

/obj/item/storage/box/nanofrost/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/smokebomb/nanofrost(src)

// as i have no idea where to put new box types, boxes of oxygen candles go here // i found a place to put this
/obj/item/storage/box/oxygen_candles
	name = "box of oxygen candles"
	desc = "A box full of emergency oxygen candles."
	icon_state = "internals"
	illustration = "oxycandle"

/obj/item/storage/box/oxygen_candles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/oxygen_candle(src)

/obj/item/storage/box/large_oxygen_candles
	name = "box of large oxygen candles"
	desc = "A box full of large oxygen candles."
	icon_state = "engbox"
	illustration = "oxycandle_large"

/obj/item/storage/box/large_oxygen_candles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/oxygen_candle/large(src)

/obj/item/storage/box/plastic
	name = "plastic box"
	desc = "It's a solid, plastic shell box."
	icon_state = "plasticbox"
	foldable_result = null
	illustration = "writing"
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT) //You lose most if recycled.

/obj/item/storage/box/emergencytank
	name = "emergency oxygen tank box"
	desc = "A box of emergency oxygen tanks."
	illustration = "emergencytank"

/obj/item/storage/box/emergencytank/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/tank/internals/emergency_oxygen(src) //in case anyone ever wants to do anything with spawning them, apart from crafting the box

/obj/item/storage/box/engitank
	name = "extended-capacity emergency oxygen tank box"
	desc = "A box of extended-capacity emergency oxygen tanks."
	illustration = "extendedtank"

/obj/item/storage/box/engitank/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/tank/internals/emergency_oxygen/engi(src) //in case anyone ever wants to do anything with spawning them, apart from crafting the box
