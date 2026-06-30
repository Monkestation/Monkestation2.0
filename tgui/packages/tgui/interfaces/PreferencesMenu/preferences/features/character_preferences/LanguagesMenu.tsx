// THIS IS A NOVA SECTOR UI FILE
import { useBackend } from 'tgui/backend';
import { BlockQuote, Box, Button, Section, Stack } from 'tgui-core/components';

import type { Language, PreferencesMenuData } from '../../../data';

export function KnownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const noPoints =
    !props.language.speaking &&
    data.current_language_points === data.total_language_points;
  return (
    <Stack.Item>
      <Section
        title={
          <>
            <Box
              // Manually putting the icon here instead of using the buttons prop cause it looks better
              mr="2px"
              mb="-4px"
              inline
              className={`languages16x16 ${props.language.icon}`}
            />
            <Box inline>{props.language.name}</Box>
          </>
        }
      >
        <BlockQuote>{props.language.description}</BlockQuote>
        <Button
          color="bad"
          icon="brain"
          tooltip="Forgetting how to understand the language will also prevent you from speaking it."
          onClick={() =>
            act('forget_understand_language', {
              language_name: props.language.name,
            })
          }
        >
          Forget
        </Button>
        <Button
          color={!noPoints ? 'good' : 'grey'}
          icon={props.language.speaking ? 'comment' : 'comment-slash'}
          tooltip={
            props.language.speaking
              ? 'Forget how to speak the language, but you keep your understanding of it.'
              : 'Learn to speak the language.'
          }
          onClick={() =>
            act(
              props.language.speaking
                ? 'forget_speak_language'
                : 'speak_language',
              { language_name: props.language.name },
            )
          }
        >
          Can {props.language.speaking ? 'speak' : 'only understand'}
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function UnknownLanguage(props: { language: Language }) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const noPoints = data.current_language_points === data.total_language_points;
  const noSpeaking =
    data.current_language_points === data.total_language_points ||
    data.current_language_points === data.total_language_points - 1;
  return (
    <Stack.Item>
      <Section
        title={
          <>
            <Box
              // Manually putting the icon here instead of using the buttons prop cause it looks better
              mr="2px"
              mb="-3px"
              inline
              className={`languages16x16 ${props.language.icon}`}
            />
            <Box inline>{props.language.name}</Box>
          </>
        }
      >
        <BlockQuote>{props.language.description}</BlockQuote>
        <Button
          color={!noSpeaking ? 'good' : 'grey'}
          icon="comment"
          tooltip="Learn to speak and understand the language."
          onClick={() =>
            act('speak_language', { language_name: props.language.name })
          }
        >
          Speak
        </Button>
        <Button
          color={!!noPoints && 'grey'}
          icon="brain"
          tooltip="Learn to understand the language but not speak it."
          onClick={() =>
            act('understand_language', { language_name: props.language.name })
          }
        >
          Understand
        </Button>
      </Section>
    </Stack.Item>
  );
}

export function LanguagesPage() {
  const { data } = useBackend<PreferencesMenuData>();
  return (
    <>
      <Section textAlign="center">
        Here, you can learn languages using a point system. There are four
        quirks that affect your point amount.
        <br />
        <b>Linguist</b> and <b>Monolingual</b> give and remove two points
        respectively, <b>Polyglot</b> gives eight and <b>Listener</b> removes
        one.
        <br />
        Languages may be either <b>spoken and understood</b> or{' '}
        <b>just understood.</b>
        <br />
        Only understanding a language is worth <b>1 point,</b> a spoken language
        is worth <b>2 points.</b>
        <br />
        You must have at least one known language. <br />
      </Section>
      <Stack>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.unselected_languages.length} available languages
              </Box>
            }
          >
            <Stack vertical>
              {data.unselected_languages.map((val) => (
                <UnknownLanguage key={val.icon} language={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item minWidth="50%">
          <Section
            title={
              <Box fontSize="150%">
                {data.current_language_points}/{data.total_language_points}{' '}
                language points
              </Box>
            }
          >
            <Stack vertical>
              {data.selected_languages.map((val) => (
                <KnownLanguage key={val.icon} language={val} />
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
}
