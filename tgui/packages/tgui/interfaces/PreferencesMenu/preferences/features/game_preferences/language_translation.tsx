import { Feature, FeatureDropdownInput } from '../base';

export const language_translation: Feature<string> = {
  name: 'Language Translation',
  category: 'GAMEPLAY',
  description: 'Enable automatic Russian-English translation in chat',
  component: FeatureDropdownInput,
};

export const getLanguageTranslationChoices = (get) => {
  return {
    off: 'Disabled',
    russian_to_english: 'Russian to English',
    english_to_russian: 'English to Russian',
    both: 'Both directions',
  };
};
