
// Armament categories
#define ARMAMENT_CATEGORY_STANDARD "Standard Equipment"
#define ARMAMENT_CATEGORY_STANDARD_LIMIT 1

#define ARMAMENT_CATEGORY_MELEE "Melee Weapons"
#define ARMAMENT_CATEGORY_MELEE_LIMIT 1

#define ARMAMENT_CATEGORY_PRIMARY "Primary Weapons"
#define ARMAMENT_CATEGORY_PRIMARY_LIMIT 1

#define ARMAMENT_CATEGORY_SECONDARY "Secondary Weapons"
#define ARMAMENT_CATEGORY_SECONDARY_LIMIT 1

#define ARMAMENT_CATEGORY_ARMOR_HEAD "Headgear"
#define ARMAMENT_CATEGORY_ARMOR_HEAD_LIMIT 1

#define ARMAMENT_CATEGORY_MEDICAL "Medical Supplies"
#define ARMAMENT_CATEGORY_MEDICAL_LIMIT 5

#define ARMAMENT_CATEGORY_OTHER "Miscellaneous"
#define ARMAMENT_CATEGORY_OTHER_LIMIT 3

// Armament subcategories
#define ARMAMENT_SUBCATEGORY_NONE "Uncategorised"
#define ARMAMENT_SUBCATEGORY_AMMO "Ammunition"
#define ARMAMENT_SUBCATEGORY_MELEE_LETHAL "Lethal Weaponry"
#define ARMAMENT_SUBCATEGORY_MELEE_NONLETHAL "Non-Lethal Weaponry"
#define ARMAMENT_SUBCATEGORY_SUBMACHINEGUN "Submachine Guns"
#define ARMAMENT_SUBCATEGORY_ASSAULTRIFLE "Assault Rifles"
#define ARMAMENT_SUBCATEGORY_SPECIAL "Special Weapons"
#define ARMAMENT_SUBCATEGORY_PISTOL "Pistols"
#define ARMAMENT_SUBCATEGORY_HELMET "Helmets"
#define ARMAMENT_SUBCATEGORY_BERETS "Berets"
#define ARMAMENT_SUBCATEGORY_MEDKIT "Medkits"
#define ARMAMENT_SUBCATEGORY_INJECTOR "Injectors"
#define ARMAMENT_SUBCATEGORY_SHOTGUN "Shotguns"
#define ARMAMENT_SUBCATEGORY_LASER "Laser Weaponry"
#define ARMAMENT_SUBCATEGORY_ARMOR "Armor"
#define ARMAMENT_SUBCATEGORY_GUNPART "Gun Parts"
#define ARMAMENT_SUBCATEGORY_EMITTER "Phase Emitter"
#define ARMAMENT_SUBCATEGORY_CELL_UPGRADE "Cell Upgrade"
#define ARMAMENT_SUBCATEGORY_CHEMICAL "Chemicals"
#define ARMAMENT_SUBCATEGORY_CQC "Close Quarters"

/// To identify the limit of the category type in the associative list. Techical stuff.
#define CATEGORY_LIMIT "Category Limit"
#define CATEGORY_ENTRY "Category Entry"

// Bitflags for what company a cargo order datum should belong to
#define CARGO_COMPANY_NAKAMURA_MODSUITS (1<<0)
#define CARGO_COMPANY_BLACKSTEEL (1<<1)
#define CARGO_COMPANY_NRI_SURPLUS (1<<2)
#define CARGO_COMPANY_DEFOREST (1<<3)
#define CARGO_COMPANY_DONK (1<<4)
#define CARGO_COMPANY_KAHRAMAN (1<<5)
#define CARGO_COMPANY_FRONTIER_EQUIPMENT (1<<6)
#define CARGO_COMPANY_SOL_DEFENSE (1<<7)
#define CARGO_COMPANY_MICROSTAR (1<<8)
#define CARGO_COMPANY_VITEZSTVI_AMMO (1<<9)
#define CARGO_COMPANY_RAYNE (1<<10)
#define CARGO_COMPANY_KEMETEK (1<<11)

// Company names, because the armament category and company name need to be the exact same, so use defines like this
#define NAKAMURA_ENGINEERING_MODSUITS_NAME "Nakamura Engineering MOD Divison"
#define BLACKSTEEL_FOUNDATION_NAME "Jarnsmiour Blacksteel Foundation"
#define NRI_SURPLUS_COMPANY_NAME "Izlishek Company Military Supplier"
#define DEFOREST_MEDICAL_NAME "DeForest Medical Corporation"
#define DONK_CO_NAME "Donk Corporation"
#define KAHRAMAN_INDUSTRIES_NAME "Kahraman Heavy Industries"
#define FRONTIER_EQUIPMENT_NAME "Akhter Company Frontier Equipment"
#define SOL_DEFENSE_DEFENSE_NAME "Sol Defense Imports"
#define MICROSTAR_ENERGY_NAME "MicroStar Energy Weapon Coalition"
#define VITEZSTVI_AMMO_NAME "Vitezstvi Ammo & Weapon Accessories"
#define RAYNE_CORP_NAME "Rayne Corporation"
#define KEMETEK_NAME "Kemetek Aerospace"
