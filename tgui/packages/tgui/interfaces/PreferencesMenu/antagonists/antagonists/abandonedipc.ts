import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const AbandonedIPC: Antagonist = {
  key: 'abandonedipc',
  name: 'Abandoned IPC',
  description: [
    multiline`
    You are a abandoned IPC, a construct from another shift.
    You have been left behind in maintence, and, in your slumber, obtained mutiple ion laws.
    Follow them to the best of your ability.
    `,
  ],
  category: Category.Ghost,
};

export default AbandonedIPC;
