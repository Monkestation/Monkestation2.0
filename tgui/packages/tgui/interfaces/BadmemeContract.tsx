import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { BlockQuote, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type Info = {
  our_offer: string;
  our_stakes: string;
  left_sign: string;
  right_sign: string;
};

export const BadmemeContract = (props) => {
  const { data, act } = useBackend<Info>();
  const { left_sign, right_sign, our_offer, our_stakes } = data;
  return (
    <Window width={420} height={380}>
      <Window.Content>
        <Section fill>
          <Stack vertical fill>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow fontSize="16px">
                      Strange Contract:
                    </Stack.Item>
                    <Stack.Item>
                      <BlockQuote>
                        {multiline`
                            Something strange offers you something.
                            In return, it also asks something from you.
                            The contract merely ensures both parties
                            fulfill their ends.`}
                      </BlockQuote>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  An Offer you Can Refuse...
                  <Stack.Item />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item fontSize="16px">We offer you...</Stack.Item>
                <Stack.Item>
                  <BlockQuote>{multiline(our_offer)}</BlockQuote>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item fontSize="16px">In return...</Stack.Item>
                <Stack.Item>
                  <BlockQuote>{multiline(our_stakes)}</BlockQuote>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack fill textAlign="center">
                <Stack.Item fontSize="14px" grow>
                  {left_sign}
                </Stack.Item>
                <Stack.Item fontSize="16px">&</Stack.Item>
                <Stack.Item fontSize={right_sign !== 'none' && '14px'} grow>
                  {(right_sign === 'none' && (
                    <Button icon="pen" onClick={() => act('sign', {})}>
                      Sign Here
                    </Button>
                  )) ||
                    right_sign}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
