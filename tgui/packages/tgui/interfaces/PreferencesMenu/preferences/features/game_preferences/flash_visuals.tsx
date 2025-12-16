import { multiline } from 'common/string';
import { Feature, FeatureDropdownInput } from '../base';

export const flash_visuals: Feature<string> = {
  name: 'Screen Flash Visuals',
  category: 'GAMEPLAY',
  description: multiline`
    Changes how being flashed affects your screen.
    "Light" mode has your screen flash white.
    "Dark" mode has your screen flash black.
    "Blur" mode has your screen heavily blur.
  `,
  component: FeatureDropdownInput,
};
