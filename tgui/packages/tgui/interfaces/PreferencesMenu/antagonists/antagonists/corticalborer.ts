import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const CorticalBorer: Antagonist = {
  key: 'corticalborer',
  name: 'Cortical Borer',
  description: [
    multiline`
    You are a slug that crawls into peoples ears and
    then manipulates them in various ways
    to make sure your species survives and thrives.
    `,
  ],
  category: Category.Ghost,
};

export default CorticalBorer;
