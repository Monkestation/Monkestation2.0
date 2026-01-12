/// Called in /obj/structure/moneybot/add_money(). (to_add)
#define COMSIG_MONEYBOT_ADD_MONEY "moneybot_add_money"

/// Called in /obj/structure/dispenserbot/add_item(). (obj/item/to_add)
#define COMSIG_DISPENSERBOT_ADD_ITEM "moneybot_add_item"

/// Called in /obj/structure/dispenserbot/remove_item(). (obj/item/to_remove)
#define COMSIG_DISPENSERBOT_REMOVE_ITEM "moneybot_remove_item"

/// Called in /mob/living/carbon/human/assess_threat().
#define COMSIG_WEAPONS_CHECK "weapons_check"
	///Person has access to have a weapon.
	#define COMPONENT_WEAPON_HAS_PERMIT (1<<0)
