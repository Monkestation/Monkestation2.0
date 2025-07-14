import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const CommandoOperative: Antagonist = {
  key: 'commandooperative',
  name: 'Commando Operative',
  description: [
    multiline`
      Congratulations, agent. You have been chosen to join the Syndicate
      Commando Operative team. Your mission, whether or not you choose
      to accept it, is to shut down Nanotrasen's second most advanced research facility!
    `,

    multiline`
      Arm the provided nuke with your disk or the station's disk
      and protect it at all costs from the crew until it blows up!
    `,
  ],
  category: Category.Roundstart,
};

export default CommandoOperative;
