import { map } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Grid,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Flex,
  Tabs,
  Stack,
  Dropdown,
  Input,
} from '../components';
import { Window } from '../layouts';

export const NaniteCodes = (props) => {
  const { act, data } = useBackend();
  return (
    <Section title="Codes" level={3} mr={1}>
      <LabeledList>
        <LabeledList.Item label="Activation">
          <NumberInput
            value={data.activation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            onChange={(e, value) =>
              act('set_code', {
                target_code: 'activation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Deactivation">
          <NumberInput
            value={data.deactivation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            onChange={(e, value) =>
              act('set_code', {
                target_code: 'deactivation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Kill">
          <NumberInput
            value={data.kill_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            onChange={(e, value) =>
              act('set_code', {
                target_code: 'kill',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        {!!data.can_trigger && (
          <LabeledList.Item label="Trigger">
            <NumberInput
              value={data.trigger_code}
              width="47px"
              minValue={0}
              maxValue={9999}
              onChange={(e, value) =>
                act('set_code', {
                  target_code: 'trigger',
                  code: value,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const NaniteDelays = (props) => {
  const { act, data } = useBackend();

  return (
    <Section title="Delays" level={3} ml={1}>
      <LabeledList>
        <LabeledList.Item label="Restart Timer">
          <NumberInput
            value={data.timer_restart}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            onChange={(e, value) =>
              act('set_restart_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Shutdown Timer">
          <NumberInput
            value={data.timer_shutdown}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            onChange={(e, value) =>
              act('set_shutdown_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        {!!data.can_trigger && (
          <>
            <LabeledList.Item label="Trigger Repeat Timer">
              <NumberInput
                value={data.timer_trigger}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                onChange={(e, value) =>
                  act('set_trigger_timer', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Trigger Delay">
              <NumberInput
                value={data.timer_trigger_delay}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                onChange={(e, value) =>
                  act('set_timer_trigger_delay', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};

export const NaniteExtraEntry = (props) => {
  const { extra_setting } = props;
  const { name, type } = extra_setting;
  const typeComponentMap = {
    number: <NaniteExtraNumber extra_setting={extra_setting} />,
    text: <NaniteExtraText extra_setting={extra_setting} />,
    type: <NaniteExtraType extra_setting={extra_setting} />,
    boolean: <NaniteExtraBoolean extra_setting={extra_setting} />,
  };
  return (
    <LabeledList.Item label={name}>{typeComponentMap[type]}</LabeledList.Item>
  );
};

export const NaniteExtraNumber = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
  const { name, value, min, max, unit } = extra_setting;
  return (
    <NumberInput
      value={value}
      width="64px"
      minValue={min}
      maxValue={max}
      unit={unit}
      onChange={(e, val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

export const NaniteExtraText = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
  const { name, value } = extra_setting;
  return (
    <Input
      value={value}
      width="200px"
      onInput={(e, val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

export const NaniteExtraType = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
  const { name, value, types } = extra_setting;
  return (
    <Dropdown
      over
      selected={value}
      width="150px"
      options={types}
      onSelected={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

export const NaniteExtraBoolean = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
  const { name, value, true_text, false_text } = extra_setting;
  return (
    <Button.Checkbox
      content={value ? true_text : false_text}
      checked={value}
      onClick={() =>
        act('set_extra_setting', {
          target_setting: name,
        })
      }
    />
  );
};

export const NaniteProgrammer = (props) => {
  return (
    <Window width={420} height={550}>
      <Window.Content scrollable>
        <NaniteProgrammerContent />
      </Window.Content>
    </Window>
  );
};

export const NaniteProgrammerContent = (props) => {
  const { act, data } = useBackend();
  const {
    has_program,
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activated,
    has_extra_settings,
    extra_settings = {},
  } = data;
  if (!has_program) {
    return <NoticeBox textAlign="center">Download a nanite program</NoticeBox>;
  }
  return (
    <Section title={name} height="700px" fill scrollable>
      <Section title="Info" level={2}>
        <Grid>
          <Grid.Column>{desc}</Grid.Column>
          <Grid.Column size={0.7}>
            <LabeledList>
              <LabeledList.Item label="Use Rate">{use_rate}</LabeledList.Item>
              {!!can_trigger && (
                <>
                  <LabeledList.Item label="Trigger Cost">
                    {trigger_cost}
                  </LabeledList.Item>
                  <LabeledList.Item label="Trigger Cooldown">
                    {trigger_cooldown}
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
          </Grid.Column>
        </Grid>
      </Section>
      <Section
        title="Settings"
        level={2}
        buttons={
          <Button
            icon={activated ? 'power-off' : 'times'}
            content={activated ? 'Active' : 'Inactive'}
            selected={activated}
            color="bad"
            bold
            onClick={() => act('toggle_active')}
          />
        }
      >
        <Grid>
          <Grid.Column>
            <NaniteCodes />
          </Grid.Column>
          <Grid.Column>
            <NaniteDelays />
          </Grid.Column>
        </Grid>
        {!!has_extra_settings && (
          <Section title="Special" level={3}>
            <LabeledList>
              {extra_settings.map((setting) => (
                <NaniteExtraEntry key={setting.name} extra_setting={setting} />
              ))}
            </LabeledList>
          </Section>
        )}
      </Section>
    </Section>
  );
};

export const NaniteDiskBox = (props) => {
  const { data } = useBackend();
  const { has_program } = data;
  if (!has_program) {
    return <NoticeBox>No program downloaded.</NoticeBox>;
  }
  return <NaniteProgrammerContent />;
};

export const NaniteInfoBox = (props) => {
  const { program } = props;
  const {
    name,
    desc,
    activated,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activation_code,
    deactivation_code,
    kill_code,
    trigger_code,
    timer_restart,
    timer_shutdown,
    timer_trigger,
    timer_trigger_delay,
  } = program;
  const extra_settings = program.extra_settings || [];
  return (
    <Section
      title={name}
      level={2}
      buttons={
        <Box inline bold color={activated ? 'good' : 'bad'}>
          {activated ? 'Activated' : 'Deactivated'}
        </Box>
      }
    >
      <Grid>
        <Grid.Column mr={1}>{desc}</Grid.Column>
        <Grid.Column size={0.5}>
          <LabeledList>
            <LabeledList.Item label="Use Rate">{use_rate}</LabeledList.Item>
            {!!can_trigger && (
              <>
                <LabeledList.Item label="Trigger Cost">
                  {trigger_cost}
                </LabeledList.Item>
                <LabeledList.Item label="Trigger Cooldown">
                  {trigger_cooldown}
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title="Codes" level={3} mr={1}>
            <LabeledList>
              <LabeledList.Item label="Activation">
                {activation_code}
              </LabeledList.Item>
              <LabeledList.Item label="Deactivation">
                {deactivation_code}
              </LabeledList.Item>
              <LabeledList.Item label="Kill">{kill_code}</LabeledList.Item>
              {!!can_trigger && (
                <LabeledList.Item label="Trigger">
                  {trigger_code}
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="Delays" level={3} mr={1}>
            <LabeledList>
              <LabeledList.Item label="Restart">
                {timer_restart} s
              </LabeledList.Item>
              <LabeledList.Item label="Shutdown">
                {timer_shutdown} s
              </LabeledList.Item>
              {!!can_trigger && (
                <>
                  <LabeledList.Item label="Trigger">
                    {timer_trigger} s
                  </LabeledList.Item>
                  <LabeledList.Item label="Trigger Delay">
                    {timer_trigger_delay} s
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Section title="Extra Settings" level={3}>
        <LabeledList>
          {extra_settings.map((setting) => {
            const naniteTypesDisplayMap = {
              number: (
                <>
                  {setting.value}
                  {setting.unit}
                </>
              ),
              text: setting.value,
              type: setting.value,
              boolean: setting.value ? setting.true_text : setting.false_text,
            };
            return (
              <LabeledList.Item key={setting.name} label={setting.name}>
                {naniteTypesDisplayMap[setting.type]}
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
    </Section>
  );
};

export const NaniteCloudBackupList = (props) => {
  const { act, data } = useBackend();
  const cloud_backups = data.cloud_backups || [];
  return cloud_backups.map((backup) => (
    <Button
      fluid
      key={backup.cloud_id}
      content={'Backup #' + backup.cloud_id}
      textAlign="center"
      onClick={() =>
        act('set_view', {
          view: backup.cloud_id,
        })
      }
    />
  ));
};

export const NaniteCloudBackupDetails = (props) => {
  const { act, data } = useBackend();
  const { current_view, can_rule, has_program, cloud_backup } = data;
  if (!cloud_backup) {
    return <NoticeBox>ERROR: Backup not found</NoticeBox>;
  }
  const cloud_programs = data.cloud_programs || [];
  return (
    <Section
      title={'Backup #' + current_view}
      level={2}
      buttons={
        !!has_program && (
          <Button
            icon="upload"
            content="Upload Program from Programmer"
            color="good"
            onClick={() => act('upload_program')}
          />
        )
      }
    >
      {cloud_programs.map((program) => {
        const rules = program.rules || [];
        return (
          <Collapsible
            key={program.name}
            title={program.name}
            buttons={
              <Button
                icon="minus-circle"
                color="bad"
                onClick={() =>
                  act('remove_program', {
                    program_id: program.id,
                  })
                }
              />
            }
          >
            <Section>
              <NaniteInfoBox program={program} />
              {(!!can_rule || !!program.has_rules) && (
                <Section
                  mt={-2}
                  title="Rules"
                  level={2}
                  buttons={
                    <>
                      {!!can_rule && (
                        <Button
                          icon="plus"
                          content="Add Rule from Programmer"
                          color="good"
                          onClick={() =>
                            act('add_rule', {
                              program_id: program.id,
                            })
                          }
                        />
                      )}
                      <Button
                        icon={
                          program.all_rules_required ? 'check-double' : 'check'
                        }
                        content={
                          program.all_rules_required ? 'Meet all' : 'Meet any'
                        }
                        onClick={() =>
                          act('toggle_rule_logic', {
                            program_id: program.id,
                          })
                        }
                      />
                    </>
                  }
                >
                  {program.has_rules ? (
                    rules.map((rule) => (
                      <Box key={rule.display}>
                        <Button
                          icon="minus-circle"
                          color="bad"
                          onClick={() =>
                            act('remove_rule', {
                              program_id: program.id,
                              rule_id: rule.id,
                            })
                          }
                        />
                        {` ${rule.display}`}
                      </Box>
                    ))
                  ) : (
                    <Box color="bad">No Active Rules</Box>
                  )}
                </Section>
              )}
            </Section>
          </Collapsible>
        );
      })}
    </Section>
  );
};

export const NaniteProgramHub = (props) => {
  const { act, data } = useBackend();
  const { detail_view, has_program, programs = {} } = data;
  const [selectedCategory, setSelectedCategory] = useSharedState('category');
  const programsInCategory = (programs && programs[selectedCategory]) || [];
  return (
    <Section
      height="700px"
      fill
      scrollable
      title="Programs"
      buttons={
        <>
          <Button
            icon={detail_view ? 'info' : 'list'}
            content={detail_view ? 'Detailed' : 'Compact'}
            onClick={() => act('toggle_details')}
          />
          <Button
            icon="sync"
            content="Sync Research"
            onClick={() => act('refresh')}
          />
        </>
      }
    >
      {programs !== null ? (
        <Flex>
          <Flex.Item minWidth="110px">
            <Tabs vertical>
              {map((cat_contents, category) => {
                const progs = cat_contents || [];
                // Backend was sending stupid data that would have been
                // annoying to fix
                const tabLabel = category.substring(0, category.length - 8);
                return (
                  <Tabs.Tab
                    key={category}
                    selected={category === selectedCategory}
                    onClick={() => setSelectedCategory(category)}
                  >
                    {tabLabel}
                  </Tabs.Tab>
                );
              })(programs)}
            </Tabs>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            {detail_view ? (
              programsInCategory.map((program) => (
                <Section
                  key={program.id}
                  title={program.name}
                  level={2}
                  buttons={
                    <Button
                      icon="download"
                      content="Download"
                      onClick={() =>
                        act('download', {
                          program_id: program.id,
                        })
                      }
                    />
                  }
                >
                  {program.desc}
                </Section>
              ))
            ) : (
              <LabeledList>
                {programsInCategory.map((program) => (
                  <LabeledList.Item
                    key={program.id}
                    label={program.name}
                    buttons={
                      <Button
                        icon="download"
                        content="Download"
                        onClick={() =>
                          act('download', {
                            program_id: program.id,
                          })
                        }
                      />
                    }
                  />
                ))}
              </LabeledList>
            )}
          </Flex.Item>
        </Flex>
      ) : (
        <NoticeBox>No nanite programs are currently researched.</NoticeBox>
      )}
    </Section>
  );
};

export const NaniteCloudControl = (props) => {
  const { act, data } = useBackend();
  const { current_view, new_backup_id } = data;
  return (
    <Window width={1295} height={700}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item width="500px">
            <NaniteProgramHub />
          </Stack.Item>
          <Stack.Item width="420px">
            <NaniteDiskBox />
          </Stack.Item>
          <Stack.Item width="375px">
            <Section
              scrollable
              height="700px"
              fill
              title="Cloud Storage"
              buttons={
                current_view ? (
                  <Button
                    icon="arrow-left"
                    content="Return"
                    onClick={() =>
                      act('set_view', {
                        view: 0,
                      })
                    }
                  />
                ) : (
                  <>
                    {'New Backup: '}
                    <NumberInput
                      value={new_backup_id}
                      minValue={1}
                      maxValue={100}
                      stepPixelSize={4}
                      width="39px"
                      onChange={(e, value) =>
                        act('update_new_backup_value', {
                          value: value,
                        })
                      }
                    />
                    <Button icon="plus" onClick={() => act('create_backup')} />
                  </>
                )
              }
            >
              {!data.current_view ? (
                <NaniteCloudBackupList />
              ) : (
                <NaniteCloudBackupDetails />
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
