//Gun crafting parts til they can be moved elsewhere

// PARTS //
/obj/item/weaponcrafting
	abstract_type = /obj/item/weaponcrafting

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 6)
	resistance_flags = FLAMMABLE
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "riflestock"

/obj/item/weaponcrafting/giant_wrench
	name = "Big Slappy parts kit"
	desc = "Illegal parts to make a giant like wrench commonly known as a Big Slappy."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "weaponkit_gw"

///These gun kits are printed from the security protolathe to then be used in making new weapons

// GUN PART KIT //

/obj/item/weaponcrafting/gunkit
	name = "generic gun parts kit"
	desc = "It's an empty gun parts container! Why do you have this?"
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "kitsuitcase"

/obj/item/weaponcrafting/gunkit/beam_rifle
	name = "\improper Event Horizon anti-existential beam rifle part kit (DOOMSDAY DEVICE, DO NOT CONSTRUCT)"
	desc = "What fevered minds wrought this terrible construction kit? To create a frame to harness the strange energies that flow through the Spinward Sector towards such horrible acts of violence?"

/obj/item/weaponcrafting/gunkit/hellgun
	name = "hellfire laser gun degradation kit (warcrime lethal)"
	desc = "Take a perfectly functioning laser gun. Butcher the inside of the gun so it runs hot and mean. You now have a hellfire laser. You monster."
