///Lists related to quirk selection

///Types of glasses that can be selected at character selection with the Nearsighted quirk
GLOBAL_LIST_INIT(nearsighted_glasses, list(
	"Regular" = /obj/item/clothing/glasses/regular,
	"Circle" = /obj/item/clothing/glasses/regular/circle,
	"Hipster" = /obj/item/clothing/glasses/regular/hipster,
	"Thin" = /obj/item/clothing/glasses/regular/thin,
))

///Options for the prosthetic limb quirk to choose from
GLOBAL_LIST_INIT(limb_choice, list(
// monkestation edit start
/* original
	"Left Arm" = /obj/item/bodypart/arm/left/robot/surplus,
	"Right Arm" = /obj/item/bodypart/arm/right/robot/surplus,
	"Left Leg" = /obj/item/bodypart/leg/left/robot/surplus,
	"Right Leg" = /obj/item/bodypart/leg/right/robot/surplus,
*/
	"Left Arm" = BODY_ZONE_L_ARM,
	"Right Arm" = BODY_ZONE_R_ARM,
	"Left Leg" = BODY_ZONE_L_LEG,
	"Right Leg" = BODY_ZONE_R_LEG,
// monkestation edit end
))
