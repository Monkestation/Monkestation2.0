import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const JuniorLoneOperative: Antagonist = {
  key: 'juniorloneoperative',
  name: 'Junior Lone Operative',
  description: [
    multiline`
      A solo nuclear operative cadet that has a guranteed chance of spawning after
      the nuclear authentication disk stays in one place for too long. Break past
      the 9% mission success and prove your worth to the Syndicate.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Ghost,
};

export default JuniorLoneOperative;
