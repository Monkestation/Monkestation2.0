import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Bingle: Antagonist = {
  key: 'bingle',
  name: 'Bingle',
  description: [
    multiline`
    You are a blue fella.
    Feed the pit, love the pit, protect the pit.
    `,
  ],
  category: Category.Ghost,
};

export default Bingle;
