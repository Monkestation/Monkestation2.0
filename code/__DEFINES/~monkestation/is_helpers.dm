#define isgary(A) (istype(A, /mob/living/basic/chicken/gary))

#define isslugcat(A) (istype(A, /mob/living/basic/slugcat))

#define isdarkspawn(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define isthrall(A) (A?.mind?.has_antag_datum(/datum/antagonist/thrall))
#define ispsyche(A) (A?.mind?.has_antag_datum(/datum/antagonist/psyche)) //non thrall teammates
#define is_darkspawn_or_thrall(A) (A.mind && isdarkspawn(A) || isthrall(A))
#define is_team_darkspawn(A) ((A.mind && isdarkspawn(A) || isthrall(A)) || ispsyche(A) || (ROLE_DARKSPAWN in A.faction)) //also checks factions, so things can be immune to darkspawn spells without needing an antag datum
