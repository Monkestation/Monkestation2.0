import { binaryInsertWith, sortBy } from 'common/collections';
import { useBackend } from '../../backend';
import {
  Button,
  Icon,
  LabeledList,
  Modal,
  Section,
  Stack,
  TrackOutsideClicks,
} from '../../components';
import type { Name, PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

type NameWithKey = {
  key: string;
  name: Name;
};

const binaryInsertName = binaryInsertWith<NameWithKey>(({ key }) => key);

const sortNameWithKeyEntries = sortBy<[string, NameWithKey[]]>(([key]) => key);

export const MultiNameInput = (props: {
  handleClose: () => void;
  handleRandomizeName: (nameType: string) => void;
  handleUpdateName: (nameType: string, value: string) => void;
  names: Record<string, string>;
}) => {
  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return null;
        }

        const namesIntoGroups: Record<string, NameWithKey[]> = {};

        for (const [key, name] of Object.entries(data.names.types)) {
          namesIntoGroups[name.group] = binaryInsertName(
            namesIntoGroups[name.group] || [],
            {
              key,
              name,
            },
          );
        }

        return (
          <Modal ml={20}>
            <TrackOutsideClicks onOutsideClick={props.handleClose}>
              <Section
                buttons={
                  <Button color="red" onClick={props.handleClose}>
                    Close
                  </Button>
                }
                title="Alternate names"
              >
                <LabeledList>
                  {sortNameWithKeyEntries(Object.entries(namesIntoGroups)).map(
                    ([_, names], index, collection) => (
                      <>
                        {names.map(({ key, name }) => {
                          return (
                            <LabeledList.Item
                              key={key}
                              label={name.explanation}
                            >
                              <Stack fill>
                                <Stack.Item grow>
                                  <Button.Input
                                    fluid
                                    onCommit={(value) =>
                                      props.handleUpdateName(key, value)
                                    }
                                    value={props.names[key]}
                                  />
                                </Stack.Item>

                                {!!name.can_randomize && (
                                  <Stack.Item>
                                    <Button
                                      icon="dice"
                                      tooltip="Randomize"
                                      tooltipPosition="right"
                                      onClick={() => {
                                        props.handleRandomizeName(key);
                                      }}
                                    />
                                  </Stack.Item>
                                )}
                              </Stack>
                            </LabeledList.Item>
                          );
                        })}

                        {index !== collection.length - 1 && (
                          <LabeledList.Divider />
                        )}
                      </>
                    ),
                  )}
                </LabeledList>
              </Section>
            </TrackOutsideClicks>
          </Modal>
        );
      }}
    />
  );
};

export const NameInput = (props: { openMultiNameInput: () => void }) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    name_to_use,
    character_preferences: { names },
  } = data;
  const name = names[name_to_use];

  return (
    <Stack width="100%">
      <Stack.Item grow>
        <Stack
          backgroundColor="var(--color-primary)"
          p={1}
          style={{ borderRadius: '4px' }}
        >
          <Stack.Item>
            <Icon
              style={{
                color: 'rgba(255, 255, 255, 0.5)',
                fontSize: '17px',
              }}
              name="edit"
            />
          </Stack.Item>

          <Stack.Item grow style={{ borderBottom: '2px dotted gray' }}>
            <Button.Input
              onCommit={(val) =>
                act('set_preference', {
                  preference: name_to_use,
                  value: val,
                })
              }
              style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}
              width="160px"
              value={name}
              color="transparent"
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item position="absolute" right="-26px" top="2px">
        {/* We only know other names when the server tells us */}
        <ServerPreferencesFetcher
          render={(data) =>
            data && (
              <Button
                tooltip="Alternate Names"
                tooltipPosition="right"
                py={1}
                icon="ellipsis-v"
                onClick={(event) => {
                  props.openMultiNameInput();

                  // We're a button inside a button.
                  // Did you know that's against the W3C standard? :)
                  event.cancelBubble = true;
                  event.stopPropagation();
                }}
              />
            )
          }
        />
      </Stack.Item>
    </Stack>
  );
};
