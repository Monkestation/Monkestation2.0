import { useBackend } from '../backend';
import { Input, Stack, Section, Box } from '../components';
import { NtosWindow } from '../layouts';

// byond defines for the program state
const CLIENT_ONLINE = 2;
const CLIENT_AWAY = 1;
const CLIENT_OFFLINE = 0;

export const NTerminal = (props, context) => {
  const { act, data } = useBackend(context);
  const { clients = [], messages = [], shit = '>' } = data;

  return (
    <NtosWindow width={1000} height={675}>
      <NtosWindow.Content>
        <Stack vertical fill>
          <Section scrollable fill>
            {messages.map((message) => (
              <Box key={message}>
                {'>'}
                {message}
              </Box>
            ))}
          </Section>
          <Stack.Item>
            <Input
              Icon="bullhorn"
              height="22px"
              fluid
              placeholder={'>'}
              selfClear
              mt={1}
              onEnter={(e, value) =>
                act('PRG_send', {
                  message: value,
                })
              }
            />
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
