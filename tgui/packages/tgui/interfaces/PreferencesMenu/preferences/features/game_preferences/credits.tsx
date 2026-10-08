import { multiline } from 'common/string';
import { CheckboxInput, type FeatureToggle } from '../base';

export const feature_key_credits: FeatureToggle = {
  name: 'Feature ckey in credits',
  category: 'GAMEPLAY',
  description: multiline`
    When enabled, will display your ckey as 'you' in the credits & roundend report.
  `,
  component: CheckboxInput,
};
