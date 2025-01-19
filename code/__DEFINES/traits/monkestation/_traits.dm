/// Ignores trait sources that also add the pair trait. So if 'trait' and 'pair' are only added by the same source then this returns false.
#define HAS_TRAIT_NOT_PAIRED_WITH(target, trait, pair) (HAS_TRAIT_NOT_FROM(target, trait, GET_TRAIT_SOURCES(target, pair)))
