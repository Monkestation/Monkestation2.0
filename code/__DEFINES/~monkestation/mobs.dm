#define SPECIES_ARACHNIDS "arachnid"
#define SPECIES_DRACONIC_SKELETON "draconic_skeleton"
#define SPECIES_WEREWOLF "werewolf" //Monkestation Addition
#define SPECIES_ORNITHID "ornithid"

GLOBAL_REAL_VAR(list/voice_type2sound = list(
	"default" = list(
		"1" = sound('goon/sounds/speak_1.ogg'),
		"!" = sound('goon/sounds/speak_1_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_1_ask.ogg')
	),
	"default2" = list(
		"1" = sound('goon/sounds/speak_2.ogg'),
		"!" = sound('goon/sounds/speak_2_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_2_ask.ogg')
	),
	"default3" = list(
		"1" = sound('goon/sounds/speak_3.ogg'),
		"!" = sound('goon/sounds/speak_3_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_3_ask.ogg')
	),
	"default4" = list(
		"1" = sound('goon/sounds/speak_4.ogg'),
		"!" = sound('goon/sounds/speak_4_exclaim.ogg'),
		"?" = sound('goon/sounds/speak_4_ask.ogg')
	),
	"cbat1" = list(
		"1" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_1.ogg'),
		"!" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_exclaim.ogg'),
		"?" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_ask.ogg')
	),
	"cbat2" = list(
		"1" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_2.ogg'),
		"!" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_2exclaim.ogg'),
		"?" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_2ask.ogg')
	),
	"cbat3" = list(
		"1" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_3.ogg'),
		"!" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_3exclaim.ogg'),
		"?" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_3ask.ogg')
	),
	"cbat4" = list(
		"1" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_4.ogg'),
		"!" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_4exclaim.ogg'),
		"?" = sound('monkestation/sound/voice/voice_customization/cbat/cbat_4ask.ogg')
	),

	// Add more voice types here
))

///Managed global that is a reference to the real global
GLOBAL_LIST_INIT(voice_type2sound_ref, voice_type2sound)
