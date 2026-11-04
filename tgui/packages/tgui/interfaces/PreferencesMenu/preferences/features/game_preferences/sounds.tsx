import { multiline } from 'common/string';
import {
  CheckboxInput,
  type FeatureChoiced,
  FeatureDropdownInput,
  type FeatureToggle,
} from '../base';

export const sound_combatmode: FeatureToggle = {
  name: 'Enable combat mode sound',
  category: 'SOUND',
  description: 'When enabled, hear sounds when toggling combat mode.',
  component: CheckboxInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Achievement unlock sound',
  category: 'SOUND',
  description: multiline`
    The sound that's played when unlocking an achievement.
    If disabled, no sound will be played.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts: FeatureChoiced = {
  name: 'Enable TTS',
  category: 'SOUND',
  description: `
    When enabled, be able to hear text-to-speech sounds in game.
    When set to "Blips", text to speech will be replaced with blip sounds based on the voice.
    When disabled, you hear voice pack barks like when there is no text to speech.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_radio: FeatureChoiced = {
  name: 'Enable TTS Over Radio',
  category: 'SOUND',
  description: `
    When enabled, be able to hear text-to-speech sounds in game over radio channels.
    When set to "Departmental Radio Only", text to speech over the radio will only play for departmental radio channels. Anything that isn't Common.
    When disabled, text to speech will not play over radio sources.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_hear_self_radio: FeatureToggle = {
  name: 'Enable TTS Hear Self Over Radio',
  category: 'SOUND',
  description:
    'When enabled, hear yourself over the radio when Text to Speech and TTS Over Radio is enabled.',
  component: CheckboxInput,
};

export const hearmusic: FeatureToggle = {
  name: 'Hear Radio Music',
  category: 'SOUND',
  description:
    'When enabled, hear music played in-game by the cassette player.',
  component: CheckboxInput,
};
