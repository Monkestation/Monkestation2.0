/**
 * Randomizes everything about a human, including DNA and name
 */
/proc/randomize_human(mob/living/carbon/human/human, randomize_mutations = FALSE)
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE, PLURAL, NEUTER) : PLURAL
	human.physique = human.gender
	human.real_name = human.dna?.species.random_name(human.gender) || random_unique_name(human.gender)
	human.name = human.get_visible_name()
	human.set_hairstyle(random_hairstyle(human.gender), update = FALSE)
	human.set_facial_hairstyle(random_facial_hairstyle(human.gender), update = FALSE)
	human.set_haircolor("#[random_color()]", update = FALSE)
	human.set_facial_haircolor(human.hair_color, update = FALSE)
	human.eye_color_left = random_eye_color()
	human.eye_color_right = human.eye_color_left
	human.skin_tone = random_skin_tone()
	human.dna.species.randomize_active_underwear_only(human)
	// Needs to be called towards the end to update all the UIs just set above
	human.dna.initialize_dna(newblood_type = random_human_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)
	// Snowflake stuff (ethereals)
	human.dna.species.spec_updatehealth(human)
	human.updateappearance(mutcolor_update = TRUE)
