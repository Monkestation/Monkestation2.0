import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const VampiricAccident: Antagonist = {
  key: 'vampiricaccident',
  name: 'Bloodsucker (Midround)',
  description: [
    multiline`
      After your death, you awaken to see yourself as an undead monster.
      Use your Vampiric abilities as best you can.
      Scrape by Space Station 13, or take over it, vassalizing your way.
    `,
  ],
  category: Category.Midround,
};

export default VampiricAccident;
