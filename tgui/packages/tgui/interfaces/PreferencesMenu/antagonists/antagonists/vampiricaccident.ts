import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const VampiricAccident: Antagonist = {
  key: 'vampiricaccident',
  name: 'Vampiric Accident',
  description: [
    multiline`
      Your master sent you here as both a test and a chance for you to mature.
      You can feed off of the lifeforce of other sapients through their blood.
      Feeding from a sapient until they run dry will turn them into one of you.
      Just remember to keep the inquisitors off your tail.
    `,
  ],
  category: Category.Midround,
};

export default VampiricAccident;
