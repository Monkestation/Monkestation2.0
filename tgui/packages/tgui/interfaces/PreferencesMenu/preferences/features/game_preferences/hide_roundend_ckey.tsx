import { multiline } from 'common/string';
import { CheckboxInput, FeatureToggle } from '../base';

export const hide_roundend_ckey: FeatureToggle = {
  name: 'Hide ckey in roundend report',
  category: 'GAMEPLAY',
  description: multiline`
    When enabled, your ckey will be hidden in the roundend report.
  `,
  component: CheckboxInput,
};
