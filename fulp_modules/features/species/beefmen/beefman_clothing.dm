/obj/item/clothing/under/bodysash
	name = "assistant sash"
	desc = "A simple assistant sash slung from shoulder to hip."
	icon = 'fulp_modules/icons/species/mob/clothing/beefclothing.dmi'
	worn_icon =  'fulp_modules/icons/species/mob/clothing/beefclothing_worn.dmi'
	icon_state = "assistant" // Inventory Icon
	lefthand_file = 'fulp_modules/icons/species/mob/clothing/beefclothing_hold_left.dmi'
	righthand_file = 'fulp_modules/icons/species/mob/clothing/beefclothing_hold_right.dmi'
	inhand_icon_state = "sash" // In-hand Icon
	can_adjust = FALSE
	body_parts_covered = CHEST

//Captain
/obj/item/clothing/under/bodysash/captain
	name = "captain's sash"
	desc = "A gold-embroidered sash with markings that denote its prestigious wearer as Captain."
	icon_state = "captain_beef"
	armor_type = /datum/armor/clothing_under/rank_captain
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

//Security
/obj/item/clothing/under/bodysash/security
	name = "security's sash"
	desc = "A \"tactical\" security sash for officers."
	icon_state = "security"
	armor_type = /datum/armor/clothing_under/rank_security
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/bodysash/security/hos
	name = "head of security's sash"
	desc = "A \"tactical\" security sash for those who value \"justice\" enough to become Head of Security."
	icon_state = "hos"
	armor_type = /datum/armor/clothing_under/security_head_of_security

/obj/item/clothing/under/bodysash/security/warden
	name = "warden's sash"
	desc = "A \"tactical\" security sash for wardens."
	icon_state = "warden"

/obj/item/clothing/under/bodysash/security/detective
	name = "detective's sash"
	desc = "A sash for someone who means business."
	icon_state = "detective"

/obj/item/clothing/under/bodysash/security/deputy
	name = "deputy's sash"
	desc = "An awe-inspiring \"tactical\" sash— because safety never takes a holiday."
	icon_state = "deputy"

//Medical
/obj/item/clothing/under/bodysash/medical
	name = "medical's sash"
	desc = "A doctor's sash. It provides minor protection against biohazards."
	icon_state = "medical"
	armor_type = /datum/armor/clothing_under/rank_medical

/obj/item/clothing/under/bodysash/medical/cmo
	name = "chief medical officer's sash"
	desc = "A sash worn by those \"altruistic\" enough to become Chief Medical Officer. It provides minor biological protection."
	icon_state = "cmo"

/obj/item/clothing/under/bodysash/medical/chemist
	name = "chemist's sash"
	desc = "A chemist's sash. It gives especial protection against biohazards."
	icon_state = "chemist"
	armor_type = /datum/armor/clothing_under/medical_chemist

/obj/item/clothing/under/bodysash/medical/virologist
	name = "virologist's sash"
	desc = "A virologist's sash. It gives especial protection against biohazards."
	icon_state = "virologist"

/obj/item/clothing/under/bodysash/medical/paramedic
	name = "paramedic's sash"
	desc = "A paramedic's sash. It provides minor protection against biohazards."
	icon_state = "paramedic"

//Engineering
/obj/item/clothing/under/bodysash/engineer
	name = "engineer's sash"
	desc = "An orange, high visibility sash worn by engineers."
	icon_state = "engineer"
	armor_type = /datum/armor/clothing_under/rank_engineering
	resistance_flags = NONE

/obj/item/clothing/under/bodysash/engineer/ce
	name = "chief engineer's sash"
	desc = "A high visibility sash given to engineers insane enough to achieve the rank of Chief Engineer."
	icon_state = "ce"
	armor_type = /datum/armor/clothing_under/engineering_chief_engineer

/obj/item/clothing/under/bodysash/engineer/atmos
	name = "atmospherics technician's sash"
	desc = "A sash worn by atmospheric technicians."
	icon_state = "atmos"

//Science
/obj/item/clothing/under/bodysash/rd
	name = "research director's sash"
	desc = "A sash worn by those with enough know-how to achieve the position of Research Director. It provides minor protection from biological contaminants."
	icon_state = "rd"
	armor_type = /datum/armor/clothing_under/rnd_research_director

/obj/item/clothing/under/bodysash/scientist
	name = "scientist's sash"
	desc = "A sash with markings that denote its wearer as a scientist. It provides minor protection against biohazards."
	icon_state = "scientist"
	armor_type = /datum/armor/clothing_under/science

/obj/item/clothing/under/bodysash/roboticist
	name = "roboticist's sash"
	desc = "A slimming black sash with reinforced seams— great for industrial work."
	icon_state = "roboticist"
	resistance_flags = NONE
	armor_type = /datum/armor/clothing_under/science

/obj/item/clothing/under/bodysash/geneticist
	name = "geneticist's sash"
	desc = "A geneticist's sash. It gives especial protection against biohazards."
	icon_state = "geneticist"
	armor_type = /datum/armor/clothing_under/science

//Supply/Civilian
/obj/item/clothing/under/bodysash/hop
	name = "head of personnel's sash"
	desc = "A sash worn by someone \"meticulous\" enough to be a Head of Personnel."
	icon_state = "hop"

/obj/item/clothing/under/bodysash/qm
	name = "quartermaster's sash"
	desc = "A sash worn by the Quartermaster. It's designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"

/obj/item/clothing/under/bodysash/cargo
	name = "cargo technician's sash"
	desc = "A sash worn by cargo technicians. A small advertisement sticker on the side reads: \"Saaaaashes! They're comfy and easy to wear!\""
	icon_state = "cargo"

/obj/item/clothing/under/bodysash/miner
	name = "shaft miner's sash"
	desc = "A robust sash worn by shaft miners. It's always dirty."
	icon_state = "miner"
	armor_type = /datum/armor/clothing_under/cargo_miner
	resistance_flags = NONE

/obj/item/clothing/under/bodysash/clown
	name = "clown's sash"
	desc = "A sash commonly worn by clo— <i>HONK!</i>"
	icon_state = "clown"

/obj/item/clothing/under/bodysash/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg' = 1), 50, falloff_exponent = 20)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/under/bodysash/mime
	name = "mime's sash"
	desc = "A colorless sash microengineered with sound dampaning thread patterns."
	icon_state = "mime"

/obj/item/clothing/under/bodysash/prisoner
	name = "prisoner's sash"
	desc = "A standardised Nanotrasen prisoner-wear sash. Its sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/bodysash/cook
	name = "cook's sash"
	desc = "A sash which is given only to the most <b>hardcore</b> cooks in space."
	icon_state = "cook"

/obj/item/clothing/under/bodysash/bartender
	name = "bartender's sash"
	desc = "A humble bartender's sash slung from shoulder to hip."
	icon_state = "bartender"

/obj/item/clothing/under/bodysash/chaplain
	name = "chaplain's sash"
	desc = "A simple religious sash slung from shoulder to hip."
	icon_state = "chaplain"

/obj/item/clothing/under/bodysash/curator
	name = "curator's sash"
	desc = "An unstylish librarian's sash slung from shoulder to hip."
	icon_state = "curator"

/obj/item/clothing/under/bodysash/lawyer
	name = "lawyer's sash"
	desc = "A formal lawyer's sash slung from shoulder to hip."
	icon_state = "lawyer"

/obj/item/clothing/under/bodysash/botanist
	name = "botanist's sash"
	desc = "A sash designed to protect against minor horticultural hazards."
	icon_state = "botanist"
	armor_type = /datum/armor/clothing_under/civilian_hydroponics

/obj/item/clothing/under/bodysash/janitor
	name = "janitor's sash"
	desc = "A janitor's sash slung from shoulder to hip. It provides minor biohazard protection."
	icon_state = "janitor"
	armor_type = /datum/armor/clothing_under/civilian_janitor

/obj/item/clothing/under/bodysash/psychologist
	name = "psychologist's sash"
	desc = "A comfortable psychologist's sash slung from shoulder to hip."
	icon_state = "psychologist"

//CentCom
/obj/item/clothing/under/bodysash/centcom
	name = "centcom's sash"
	desc = "A sash worn by CentCom's highest-tier Commanders."
	icon_state = "centcom"

/obj/item/clothing/under/bodysash/official
	name = "official's sash"
	desc = "A casual yet refined green sash used by CentCom Officials. It has a fragrance of aloe."
	icon_state = "official"

/obj/item/clothing/under/bodysash/intern
	name = "intern's sash"
	desc = "A sash worn by those \"interning\" for CentCom."
	icon_state = "intern"

/obj/item/clothing/under/bodysash/civilian
	name = "civilian's sash"
	desc = "A common civilian sash slung from shoulder to hip."
	icon_state = "civilian"

///Misc
/obj/item/clothing/under/bodysash/russia
	name = "Russian sash"
	desc = "A Russian-style sash slung from shoulder to hip."
	icon_state = "russia"
