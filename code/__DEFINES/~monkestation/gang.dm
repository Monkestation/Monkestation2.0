#define GANG_RANK_MEMBER 0
#define GANG_RANK_LIEUTENANT 1
#define GANG_RANK_BOSS 2

#define MAX_LIEUTENANTS 2

#define SEND_MESSAGE_TO_ALL_GANGS(sent_message, span, append) \
	var/list/gang_list = list(); \
	for(var/gang in GLOB.all_gangs_by_tag) { \
		gang_list += GLOB.all_gangs_by_tag[gang]; \
	} \
	send_gang_message(null, gang_list, sent_message, span, append);
