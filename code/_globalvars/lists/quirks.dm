///Lists related to quirk selection

///Types of glasses that can be selected at character selection with the Nearsighted quirk
GLOBAL_LIST_INIT(nearsighted_glasses, list(
	"Regular" = /obj/item/clothing/glasses/regular,
	"Circle" = /obj/item/clothing/glasses/regular/circle,
	"Hipster" = /obj/item/clothing/glasses/regular/hipster,
	"Thin" = /obj/item/clothing/glasses/regular/thin,
	"Jamjar" = /obj/item/clothing/glasses/regular/jamjar,
	"Binoclard" = /obj/item/clothing/glasses/regular/kim,
))

///Cigarette brands that can be selected at character selection with the Smoker quirk
GLOBAL_LIST_INIT(smoker_cigarette_brands, list(
	"Space Cigarettes" = /obj/item/storage/fancy/cigarettes,
	"Midori Tabako" = /obj/item/storage/fancy/cigarettes/cigpack_midori,
	"Uplift Smooth" = /obj/item/storage/fancy/cigarettes/cigpack_uplift,
	"Robust" = /obj/item/storage/fancy/cigarettes/cigpack_robust,
	"Robust Gold" = /obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	"Carp Classic" = /obj/item/storage/fancy/cigarettes/cigpack_carp,
))

///Alcoholic drinks that can be selected at character selection with the Alcoholic quirk
GLOBAL_LIST_INIT(alcoholic_drinks, list(
	"Uncle Git's Whiskey" = /obj/item/reagent_containers/cup/glass/bottle/whiskey,
	"Tunguska Vodka" = /obj/item/reagent_containers/cup/glass/bottle/vodka,
	"Magm-Ale" = /obj/item/reagent_containers/cup/glass/bottle/ale,
	"Space Beer" = /obj/item/reagent_containers/cup/glass/bottle/beer,
	"Jian Hard Cider" = /obj/item/reagent_containers/cup/glass/bottle/hcider,
	"Doublebeard's Wine" = /obj/item/reagent_containers/cup/glass/bottle/wine,
	"Ryo's Sake" = /obj/item/reagent_containers/cup/glass/bottle/sake,
))

///Options for the prothetic limb quirk to choose from
GLOBAL_LIST_INIT(limb_choice, list(
	"Left Arm" = BODY_ZONE_L_ARM,
	"Right Arm" = BODY_ZONE_R_ARM,
	"Left Leg" = BODY_ZONE_L_LEG,
	"Right Leg" = BODY_ZONE_R_LEG,
))
