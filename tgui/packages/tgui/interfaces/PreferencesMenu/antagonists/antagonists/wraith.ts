import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Wraith: Antagonist = {
  key: 'wraith',
  name: 'Wraith',
  description: [
    multiline`
      Become the mysterious wraith.
      Sow chaos in the hearts of all the station crew
      as you terrorize them with your wide variety of abilities.
      Get killed by the chef's salt shaker.
    `,
  ],
  category: Category.Midround,
};

export default Wraith;
