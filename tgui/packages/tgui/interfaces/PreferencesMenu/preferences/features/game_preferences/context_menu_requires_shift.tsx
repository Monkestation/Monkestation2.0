import { FeatureChoiced, FeatureDropdownInput } from '../base';

export const context_menu_requires_shift: FeatureChoiced = {
  name: 'Context Menu On Shift Click',
  category: 'GAMEPLAY',
  description: 'Require holding shift to open the context menu.',
  component: FeatureDropdownInput,
};
