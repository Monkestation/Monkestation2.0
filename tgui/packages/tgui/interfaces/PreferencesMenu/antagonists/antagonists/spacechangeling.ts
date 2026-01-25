import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const SpaceChangeling: Antagonist = {
  key: 'spacechangeling',
  name: 'Space Changeling',
  description: [
    multiline`
    A space changeling does not recieve a crew identity,
    instead arriving via a meteor. Infiltrate the station!
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Ghost,
};

export default SpaceChangeling;
