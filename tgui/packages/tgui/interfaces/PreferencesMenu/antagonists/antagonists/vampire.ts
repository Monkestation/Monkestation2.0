import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Vampire: Antagonist = {
  key: 'vampire',
  name: 'Vampire',
  description: [
    multiline`
      After your death, you awaken to see yourself as an undead monster.
      Scrape by Space Station 13, or take it over, ruling from the shadows!
    `,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Vampire;
