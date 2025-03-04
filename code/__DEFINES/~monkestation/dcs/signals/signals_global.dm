/// Sent whenever a new goldeneye key is spawned: (obj/item/goldeneye_key)
#define COMSIG_GLOB_GOLDENEYE_KEY_CREATED "!goldeneye_key_created"
/// Sent whenever a camera network broadcast is started/stopped/updated: (camera_net, is_show_active, announcement)
#define COMSIG_GLOB_NETWORK_BROADCAST_UPDATED "!network_broadcast_updated"
/// Sent whenever a mob becomes capable of hearing DJ music: (mob/listener)
#define COMSIG_GLOB_ADD_MUSIC_LISTENER "!add_music_listener"
/// Sent whenever a mob becomes no longer capable of hearing DJ music: (mob/listener)
#define COMSIG_GLOB_REMOVE_MUSIC_LISTENER "!remove_music_listener"
