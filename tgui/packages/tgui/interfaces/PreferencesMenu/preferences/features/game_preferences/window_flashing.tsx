import { multiline } from 'common/string';
import { CheckboxInput, type FeatureToggle } from '../base';

export const windowflashing: FeatureToggle = {
  name: 'Enable window flashing',
  category: 'UI',
  description: multiline`
    When toggled, some important events will make your game icon flash on your
    task tray.
  `,
  component: CheckboxInput,
};
