import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Teratoma: Antagonist = {
  key: 'teratoma',
  name: 'Teratoma',
  description: [
    multiline`
      By all means, you should not exist. Your very existence is a sin against nature itself.
      You are loyal to nobody, except the forces of chaos itself.
    `,
    'Spread misery and chaos upon the station.',
  ],
  category: Category.Midround,
};

export default Teratoma;
