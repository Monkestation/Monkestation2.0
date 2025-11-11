///from mind/transfer_to. Sent after the mind has been transferred: (mob/previous_body)
#define COMSIG_MIND_TRANSFERRED "mind_transferred"

/// Called on the mind when an antagonist is being gained, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_GAINED "antagonist_gained"

/// Called on the mind when an antagonist is being removed, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_REMOVED "antagonist_removed"

/// Called on the mob when losing an antagonist datum (datum/antagonist/antagonist)
#define COMSIG_MOB_ANTAGONIST_REMOVED "mob_antagonist_removed"

/// Sent to the mind when an oozeling has their core ejected: (obj/item/organ/internal/brain/slime)
#define COMSIG_OOZELING_CORE_EJECTED "oozeling_core_ejected"

/// Sent to the mind when an oozeling is revived: (mob/living/carbon/human, obj/item/organ/internal/brain/slime)
#define COMSIG_OOZELING_REVIVED "oozeling_revived"
