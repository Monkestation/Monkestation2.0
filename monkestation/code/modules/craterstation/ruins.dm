// COMMS STATION RUIN

/area/ruin/icemoon_comms_station
	name = "Abandoned Communications Outpost"

/obj/item/paper/pamphlet/delta_II
	name = "old pamphlet"
	desc = "A pamphlet that clearly doesn't belong here."
	default_raw_text = "</h2>Welcome to outpost Delta-II!</h2> <br>Here we're conducting important scientific research on the anomalous properties of this icy moon.<br>When you joined our staff, you joined our family. We're glad to have you here! You'll live, sleep, work, and spend your days with your team for six months, at which point you'll be cycled to another post.<br> <b>Have a great stay, and glory to Nanotrasen!</b>"

/obj/machinery/computer/terminal/craterstation/comms_station
	name = "old terminal"
	desc = "An old, frozen up control terminal logging readings from some far-off research station."
	icon_keyboard = "teleport_key"
	icon_screen = "teleport"
	tguitheme = "nanotrasen"
	content = list("<center><b>magnet_log34.tmp</b></center> <BR> <b> TIMESTAMP 18498405840 </b> 5wB <BR> <b> TIMESTAMP 18498406440 </b> 8wB <BR> <b> TIMESTAMP 18498407040 </b> 16wB <BR> <BR> <b>TIMESTAMP 18498407186</b> ALERT: CONTACT LOST - LAST RECORDED MAGNETIC FLUX IS 63wB")
	upperinfo = "ntOS 3.11 - logscan.exe"

/obj/structure/fluff/old_relay
	name = "old communications relay"
	desc = "An old, depowered communications array."
	density = 1
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "relay_off"

// CLOWN ASTEROID RUIN

/area/ruin/icemoon_clown_asteroid
	name = "Buried Asteroid"
