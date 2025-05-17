import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const Bloodling: Antagonist = {
  key: 'bloodling',
  name: 'Bloodling',
  description: [
    multiline`
      You are a horrific abomination of flesh.
      Scrape the station free of biomass and evolve to your ultimate form.
      Having infested Space Station 13, you will twist it to your whims.
    `,
  ],
  category: Category.Roundstart,
};

export default Bloodling;
