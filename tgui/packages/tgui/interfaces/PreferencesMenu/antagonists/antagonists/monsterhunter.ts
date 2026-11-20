import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const MonsterHunter: Antagonist = {
  key: 'monsterhunter',
  name: 'Monster Hunter',
  description: [
    multiline`
      The Red Queen's pawn, sent to hunt the monsters hiding among the crew.
      You may think you are the hero, but you are not. Every kill and every
      rift you tear open drags Wonderland closer, until it swallows the
      station whole.
    `,
  ],
  category: Category.Midround,
};

export default MonsterHunter;
