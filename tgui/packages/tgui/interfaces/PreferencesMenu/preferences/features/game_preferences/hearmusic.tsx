import { CheckboxInput, FeatureToggle } from '../base';

export const hearmusic: FeatureToggle = {
  name: 'Hear In-Game Music',
  category: 'SOUND',
  description:
    "Hear in-game music broadcasted by the curator's cassette player.",
  component: CheckboxInput,
};
