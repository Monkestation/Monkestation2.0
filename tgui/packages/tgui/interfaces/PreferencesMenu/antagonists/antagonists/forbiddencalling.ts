import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { HERETIC_MECHANICAL_DESCRIPTION } from './heretic';

const ForbiddenCalling: Antagonist = {
  key: 'forbiddencalling',
  name: 'Heretic (Midround)',
  description: [
    multiline`
      Forgotten, devoured, gutted. Humanity has forgotten the eldritch forces
      of decay, but The Mansus' veil has weakened. We will make them taste fear
      again...
    `,
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default ForbiddenCalling;
