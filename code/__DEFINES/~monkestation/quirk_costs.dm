/*
	This desolate file is the start of an attempt to rebalance quirk costs to be more consistent.
	n.b. decreasing the cost of negative quirks could cause several players to have one or more of their positive quirks automatically removed.
*/

#define QUIRK_COST_FOREIGNER -4

#define QUIRK_COST_LISTENER -1
#define QUIRK_HARDCORE_LISTENER 1

#define QUIRK_COST_OUTSIDER -QUIRK_COST_BILINGUAL

#define QUIRK_COST_BILINGUAL 2
#define QUIRK_COST_LINGUIST QUIRK_COST_BILINGUAL //same function as bilingual
