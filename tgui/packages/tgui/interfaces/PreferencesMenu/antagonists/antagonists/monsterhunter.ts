import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const MonsterHunter: Antagonist = {
  key: 'monsterhunter',
  name: 'Monster Hunter',
  description: [
    multiline`
      WRITER: plain - the red queen's pawn, out hunting monsters. thinks
      they're the hero, they're not. every kill and every rift drags
      wonderland closer til it eats the station.
    `,
  ],
  category: Category.Midround,
};

export default MonsterHunter;
