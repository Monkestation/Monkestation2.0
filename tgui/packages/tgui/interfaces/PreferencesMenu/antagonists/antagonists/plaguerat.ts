import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const PlagueRat: Antagonist = {
  key: 'plaguerat',
  name: 'Plague Rat',
  description: [
    multiline`
    You are a rat that spreads the plague.
    Also wish micheal a happy birthday.
    `,
  ],
  category: Category.Ghost,
};

export default PlagueRat;
