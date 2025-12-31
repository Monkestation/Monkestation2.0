import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { CHANGELING_MECHANICAL_DESCRIPTION } from './changeling';

const GenomeAwakening: Antagonist = {
  key: 'genomeawakening',
  name: 'Changeling (Midround)',
  description: [
    multiline`
    A highly intelligent alien predator that is capable of altering their
      shape to flawlessly resemble a human.
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default GenomeAwakening;
