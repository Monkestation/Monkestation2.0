/// Voice packs which can be selected by players, split into groups
GLOBAL_LIST_EMPTY(voice_pack_groups_visible)
/// All voice packs, split into groups
GLOBAL_LIST_EMPTY(voice_pack_groups_all)
/// Voice packs which can be picked randomly
GLOBAL_LIST_EMPTY(random_voice_packs)
/// All voice packs
GLOBAL_LIST_INIT(voice_pack_list, gen_voice_packs())
/// Admin toggle
GLOBAL_VAR_INIT(voices_enabled, TRUE)
