import { multiline } from 'common/string';
import { FeatureDropdownInput } from '../../base';

export const speaking_voice: FeatureDropdownInput = {
  name: 'Speaking Voice',
  category: 'GAMEPLAY',
  description: multiline`
    Choose your character's speaking voice.
    This will affect the sound played when you speak.
  `,
  component: FeatureDropdownInput,
};
