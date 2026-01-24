import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Table } from '../components';
import { EditableText } from './common/EditableText';
import { Window } from '../layouts';

export const ArmoryAuthorizationComputer = (props) => {
  const { act, data } = useBackend();
  const {
    is_authorized,
    authorizations_remaining,
    selected_reason,
    extra_details,
    armory_open,
    current_authorizations = [],
    valid_reasons = [],
  } = data;
  return (
    <Window width={400} height={510}>
      <Window.Content>
        <Section fill scrollable>
          <Box textAlign="center" fontSize="14px" mb={1}>
            <Box inline bold>
              CURRENT STATUS:
            </Box>
            <Box inline color={armory_open ? 'good' : 'bad'} ml={1}>
              {armory_open ? 'OPEN' : 'CLOSED'}
            </Box>
          </Box>
          <Section title="Armory Authorization" level={2}>
            <Box textAlign="center" mb={1}>
              The Armory requires authorization from ONE of the following: Head
              of Security, Warden, or Captain. Alternatively, 3 Security
              Officers can provide authorization.
            </Box>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="exclamation-triangle"
                    color="good"
                    content="AUTHORIZE"
                    disabled={is_authorized || authorizations_remaining === 0}
                    onClick={() => act('authorize')}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Button
                    fluid
                    icon="minus"
                    color="bad"
                    content="REPEAL"
                    onClick={() => act('repeal')}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
            <Section
              title="Authorizations"
              level={3}
              buttons={
                <Box inline bold>
                  {'Remaining: ' +
                    (is_authorized ? '0' : authorizations_remaining)}
                </Box>
              }
            >
              {current_authorizations.length > 0 ? (
                current_authorizations.map((authorization) => (
                  <Box
                    key={authorization.name}
                    bold
                    fontSize="16px"
                    className="candystripe"
                  >
                    {authorization.name} ({authorization.job})
                  </Box>
                ))
              ) : (
                <Box bold textAlign="center" fontSize="16px" color="average">
                  No Active Authorizations
                </Box>
              )}
            </Section>
            <Section title="Reason" level={4}>
              <Stack vertical>
                {valid_reasons.map((legal_reason) => {
                  const isSelected = legal_reason.title === selected_reason;
                  return (
                    // eslint-disable-next-line react/jsx-key
                    <Stack.Item>
                      <Button
                        color={isSelected ? 'good' : 'average'}
                        disabled={!is_authorized || armory_open}
                        onClick={() =>
                          act('reason_select', { reason: legal_reason.title })
                        }
                        tooltip={legal_reason.tooltip}
                      >
                        {legal_reason.title}
                      </Button>
                    </Stack.Item>
                  );
                })}
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="EXTRA DETAILS">
                      <EditableText
                        field="note"
                        target_ref={null}
                        text={extra_details}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    color="good"
                    onClick={() => act('open_armory')}
                    disabled={!is_authorized}
                    content="OPEN"
                  />
                </Table.Cell>
                <Table.Cell>
                  <Button
                    fluid
                    color="bad"
                    onClick={() => act('close_armory')}
                    disabled={!is_authorized}
                    content="CLOSE"
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
