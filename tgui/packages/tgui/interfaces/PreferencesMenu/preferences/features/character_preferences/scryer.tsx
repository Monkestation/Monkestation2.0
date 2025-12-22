import { Feature, FeatureShortTextInput } from '../base';

export const default_scryer_label: Feature<string> = {
  name: 'Default Scryer Label',
  description:
    'Default label to use for whenever you spawn with a MODlink scryer - either from loadout or a station trait.',
  component: FeatureShortTextInput,
};
