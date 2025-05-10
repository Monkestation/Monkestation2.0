
#define BLOODCULT_STAGE_NORMAL		1	//default
#define BLOODCULT_STAGE_READY		2	//eclipse timer has reached zero
#define BLOODCULT_STAGE_ECLIPSE		3		//3 - narsie summoning ritual undergoing
#define BLOODCULT_STAGE_MISSED		4	//eclipse window has ended
#define BLOODCULT_STAGE_DEFEATED	5	//5 - narsie summoning ritual failed
#define BLOODCULT_STAGE_NARSIE		6	//endgame

#define BLOODCOST_TARGET_BLEEDER	"bleeder"
#define BLOODCOST_AMOUNT_BLEEDER	"bleeder_amount"
#define BLOODCOST_TARGET_GRAB	"grabbed"
#define BLOODCOST_AMOUNT_GRAB	"grabbed_amount"
#define BLOODCOST_TARGET_HANDS	"hands"
#define BLOODCOST_AMOUNT_HANDS	"hands_amount"
#define BLOODCOST_TARGET_HELD	"held"
#define BLOODCOST_AMOUNT_HELD	"held_amount"
#define BLOODCOST_LID_HELD		"held_lid"
#define BLOODCOST_TARGET_SPLATTER	"splatter"
#define BLOODCOST_AMOUNT_SPLATTER	"splatter_amount"
#define BLOODCOST_TARGET_BLOODPACK	"bloodpack"
#define BLOODCOST_AMOUNT_BLOODPACK	"bloodpack_amount"
#define BLOODCOST_HOLES_BLOODPACK	"bloodpack_noholes"
#define BLOODCOST_TARGET_CONTAINER	"container"
#define BLOODCOST_AMOUNT_CONTAINER	"container_amount"
#define BLOODCOST_LID_CONTAINER	"container_lid"
#define BLOODCOST_TARGET_USER	"user"
#define BLOODCOST_AMOUNT_USER	"user_amount"
#define BLOODCOST_TOTAL		"total"
#define BLOODCOST_RESULT	"result"
#define BLOODCOST_FAILURE	"failure"
#define BLOODCOST_TRIBUTE	"tribute"
#define BLOODCOST_USER	"user"
#define RITUALABORT_ERASED	"erased"
#define RITUALABORT_STAND	"too far"
#define RITUALABORT_GONE	"moved away"
#define RITUALABORT_BLOCKED	"blocked"
#define RITUALABORT_BLOOD	"channel cancel"
#define RITUALABORT_TOOLS	"moved talisman"
#define RITUALABORT_REMOVED	"victim removed"
#define RITUALABORT_CONVERT	"convert success"
#define RITUALABORT_REFUSED	"convert refused"
#define RITUALABORT_NOCHOICE	"convert nochoice"
#define RITUALABORT_SACRIFICE	"convert failure"
#define RITUALABORT_FULL	"no room"
#define RITUALABORT_CONCEAL	"conceal"
#define RITUALABORT_NEAR	"near"
#define RITUALABORT_MISSING	"missing"
#define RITUALABORT_OVERCROWDED "overcrowded"

#define TATTOO_POOL		"Blood Pooling"
#define TATTOO_SILENT	"Silent Casting"
#define TATTOO_DAGGER	"Blood Dagger"
#define TATTOO_HOLY		"Unholy Protection"
#define TATTOO_FAST		"Rapid Tracing"
#define TATTOO_CHAT		"Dark Communication"
#define TATTOO_MANIFEST	"Pale Body"
#define TATTOO_MEMORIZE	"Arcane Dimension"
#define TATTOO_RUNESTORE "Runic Skin"
#define TATTOO_SHORTCUT	"Shortcut Sigil"

#define	TOME_CLOSED	1
#define	TOME_OPEN	2
#define RUNE_WRITE_CANNOT	0
#define RUNE_WRITE_COMPLETE	1
#define RUNE_WRITE_CONTINUE	2
#define	RUNE_CAN_ATTUNE	0
#define	RUNE_CAN_IMBUE	1
#define	RUNE_CANNOT		2
#define RUNE_STAND	1
#define	MAX_TALISMAN_PER_TOME	5
#define SACRIFICE_CHANGE_COOLDOWN	30 MINUTES
#define DEATH_SHADEOUT_TIMER	60 SECONDS
#define CONVERSION_REFUSE	-1
#define CONVERSION_NOCHOICE	0
#define CONVERSION_ACCEPT	1
#define CONVERSION_BANNED	2
#define CONVERSION_MINDLESS	3
#define CONVERSION_OVERCROWDED	4
#define CONVERTIBLE_ALWAYS	1
#define CONVERTIBLE_CHOICE	2
#define CONVERTIBLE_NEVER	3
#define CONVERTIBLE_NOMIND	4
#define CONVERTIBLE_ALREADY	5
#define CONVERTIBLE_IMPLANT	6
#define DECONVERSION_ACCEPT	1
#define DECONVERSION_REFUSE 2
#define CULTIST_ROLE_NONE		0
#define CULTIST_ROLE_ACOLYTE	1
#define CULTIST_ROLE_HERALD		2
#define CULTIST_ROLE_MENTOR		3

#define DEVOTION_TIER_0		0
#define DEVOTION_TIER_1		1
#define DEVOTION_TIER_2		2
#define DEVOTION_TIER_3		3
#define DEVOTION_TIER_4		4

#define RITUAL_CULTIST_1	"first_ritual"
#define RITUAL_CULTIST_2	"second_ritual"

#define RITUAL_FACTION_1	"first_ritual"
#define RITUAL_FACTION_2	"second_ritual"
#define RITUAL_FACTION_3	"third_ritual"

#define HEX_MODE_ROAMING 0
#define HEX_MODE_GUARD	 1
#define HEX_MODE_ESCORT	 2

#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5

//Particles system defines
#define PS_STEAM			"Steam"
#define PS_SMOKE			"Smoke"
#define PS_TEAR_REALITY		"Tear Reality"
#define PS_CANDLE			"Candle"
#define PS_CANDLE2			"Candle2"
#define PS_CULT_GAUGE		"Cult Gauge"
#define PS_CULT_SMOKE		"Cult Smoke"
#define PS_CULT_SMOKE2		"Cult Smoke2"
#define PS_CULT_SMOKE_BOX	"Cult Smoke Box"
#define PS_CULT_HALO		"Cult Halo"
#define PS_SPACE_RUNES		"Space Runes"
#define PS_NARSIEHASRISEN1	"Nar-SieHasRisen1"
#define PS_NARSIEHASRISEN2	"Nar-SieHasRisen2"
#define PS_NARSIEHASRISEN3	"Nar-SieHasRisen3"
#define PS_ZAS_DUST			"ZAS Dust"
#define PS_DANDELIONS		"Dandelions"
#define PS_CROSS_DUST		"Cross Dust"
#define PS_CROSS_ORB		"Cross Orb"
#define PS_SACRED_FLAME		"Sacred Flame"
#define PS_SACRED_FLAME2	"Sacred Flame2"
#define PS_BIBLE_PAGE		"Bible Page"

//Particles variable defines
#define PVAR_SPAWNING	"spawning"
#define PVAR_POSITION	"position"
#define PVAR_VELOCITY	"velocity"
#define PVAR_ICON_STATE	"icon_state"
#define PVAR_COLOR		"color"
#define PVAR_SCALE		"scale"
#define PVAR_PLANE		"plane"
#define PVAR_LAYER		"layer"
#define PVAR_PIXEL_X	"pixel_x"
#define PVAR_PIXEL_Y	"pixel_y"
#define PVAR_LIFESPAN	"lifespan"
#define PVAR_FADE		"fade"


GLOBAL_LIST_INIT(particle_string_to_type, list(
	PS_STEAM = /particles/steam,
	PS_SMOKE = /particles/smoke,
	PS_TEAR_REALITY = /particles/tear_reality,
	PS_CANDLE = /particles/candle,
	PS_CANDLE2 = /particles/candle_alt,
	PS_CULT_GAUGE = /particles/cult_gauge,
	PS_CULT_SMOKE = /particles/cult_smoke,
	PS_CULT_SMOKE2 = /particles/cult_smoke/alt,
	PS_CULT_SMOKE_BOX = /particles/cult_smoke/box,
	PS_CULT_HALO = /particles/cult_halo,
	PS_SPACE_RUNES = /particles/space_runes,
	PS_NARSIEHASRISEN1 = /particles/narsie_has_risen,
	PS_NARSIEHASRISEN2 = /particles/narsie_has_risen/next,
	PS_NARSIEHASRISEN3 = /particles/narsie_has_risen/last,
	PS_ZAS_DUST = /particles/zas_dust,
	PS_DANDELIONS = /particles/dandelions,
	PS_CROSS_DUST = /particles/cross_dust,
	PS_CROSS_ORB = /particles/cross_orb,
	PS_SACRED_FLAME = /particles/sacred_flame,
	PS_SACRED_FLAME2 = /particles/sacred_flame/alt,
	PS_BIBLE_PAGE = /particles/bible_page,
	))

#define isholyweapon(I) (istype(I, /obj/item/book/bible)\
						|| istype(I, /obj/item/nullrod) \
						|| istype(I, /obj/projectile/boomerang))

#define REVERT_ON_CONTROLLER_DAMAGED 1
#define LOCK_EYE_TO_CONTROLLED 2
#define LOCK_MOVEMENT_OF_CONTROLLER 4
#define REQUIRES_CONTROL 8

#define TRAIT_SEER "seer_trait"

#define MODE_CULT "cult"
#define MODE_TOKEN_CULT ":x"

#define HOLOMAP_MARKER_TEARREALITY		"tearreality"
#define HOLOMAP_MARKER_BLOODSTONE		"bloodstone"
#define HOLOMAP_MARKER_CULT_ALTAR		"altar"
#define HOLOMAP_MARKER_CULT_FORGE		"forge"
#define HOLOMAP_MARKER_CULT_SPIRE		"spire"
#define HOLOMAP_MARKER_CULT_ENTRANCE	"path_entrance"
#define HOLOMAP_MARKER_CULT_EXIT		"path_exit"
#define HOLOMAP_MARKER_CULT_RUNE		"rune"

#define HOLOMAP_FILTER_CULT (1<<0)

#define HOLOMAP_EXTRA_CULTMAP "cultmap"
