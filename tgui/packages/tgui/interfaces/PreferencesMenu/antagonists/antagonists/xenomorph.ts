import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const Xenomorph: Antagonist = {
  key: 'xenomorph',
  name: 'Xenomorph',
  description: [
    multiline`
      Become the extraterrestrial xenomorph. Start as a larva, and progress
      your way up the caste, including even the Queen!
    `,
  ],
  category: Category.Ghost,
};

export default Xenomorph;
