import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const Nightmare: Antagonist = {
  key: 'nightmare',
  name: 'Nightmare',
  description: [
    multiline`
      Use your light eater to break sources of light to survive and thrive.
      Jaunt through the darkness and seek your prey with night vision.
    `,
  ],
  category: Category.Ghost,
};

export default Nightmare;
