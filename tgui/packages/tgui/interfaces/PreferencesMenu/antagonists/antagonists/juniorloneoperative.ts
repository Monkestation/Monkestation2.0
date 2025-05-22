import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const JuniorLoneOperative: Antagonist = {
  key: 'juniorloneoperative',
  name: 'Junior Lone Operative',
  description: [
    multiline`
      A solo nuclear operative cadet that has a higher chance of spawning the longer
      the nuclear authentication disk stays in one place. Break past the 9% mission
      success and prove your worth to the Syndicate.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default JuniorLoneOperative;
