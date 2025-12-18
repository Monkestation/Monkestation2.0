import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const ChangelingMidround: Antagonist = {
  key: 'changelingmidround',
  name: 'Changeling (Midround) / \nSpace Changeling',
  description: [
    multiline`
    As crew, you were infected by a trace amount of organic matter, awakening
    newfound abilities. / A space changeling does not recieve a crew identity,
    instead arriving via a meteor. Infiltrate the station!
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default ChangelingMidround;
