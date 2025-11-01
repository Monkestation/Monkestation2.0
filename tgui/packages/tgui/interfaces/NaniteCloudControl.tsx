import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Table,
} from '../components';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  has_disk: BooleanLike;
  has_program: BooleanLike;
  disk_data: ProgramData[];
  new_backup_id: number;
  current_view: number;
  cloud_backup: BooleanLike;
  can_rule: BooleanLike;
  cloud_programs: ProgramData[];
  cloud_backups: CloudBackupData[];
};

type ProgramData = {
  name: string;
  desc: string;
  id: number;
  use_rate: number;
  can_trigger: BooleanLike;
  trigger_cost: number;
  trigger_cooldown: number;
  activated: BooleanLike;
  activation_code: number;
  deactivation_code: number;
  kill_code: number;
  trigger_code: number;
  timer_restart: number;
  timer_shutdown: number;
  timer_trigger: number;
  timer_trigger_delay: number;
  has_rules: BooleanLike;
  all_rules_required: BooleanLike;
  rules: RuleData[];
  extra_settings: ExtraSettingsData[];
  has_extra_settings: BooleanLike;
};

type ExtraSettingsData = {
  name: string;
  type: string;
  value: string;
  unit: string;
  true_text: string;
  false_text: string;
};

type RuleData = {
  display: string;
  program_id: number;
  id: number;
};

type CloudBackupData = {
  cloud_id: number;
};

const NaniteDiskBox = (props) => {
  const { data } = useBackend<Data>();
  const { has_disk, has_program, disk_data } = data;
  if (!has_disk) {
    return <NoticeBox>No disk inserted</NoticeBox>;
  }
  if (!has_program) {
    return <NoticeBox>Inserted disk has no program</NoticeBox>;
  }
  return <NaniteInfoBox program={disk_data} />;
};

const NaniteInfoBox = (props) => {
  const { act } = useBackend<Data>();
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
    extra_settings = [],
    rules = [],
  } = program;
  return (
    <Section
      title={name}
      buttons={
        <Box inline bold color={activated ? 'good' : 'bad'}>
          {activated ? 'Activated' : 'Deactivated'}
        </Box>
      }
    >
      <Table>
        <Table.Cell mr={1}>{desc}</Table.Cell>
        <Table.Cell>
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
        </Table.Cell>
      </Table>
      <Table>
        <Table.Cell>
          <Section title="Codes" mr={1}>
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
        </Table.Cell>
        <Table.Cell>
          <Section title="Delays" mr={1}>
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
        </Table.Cell>
      </Table>
      <Section title="Extra Settings">
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

const NaniteCloudBackupDetails = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_view, has_program, can_rule, cloud_backup, cloud_programs } =
    data;
  if (!cloud_backup) {
    return <NoticeBox>ERROR: Backup not found</NoticeBox>;
  }
  return (
    <Section
      title={'Backup #' + current_view}
      buttons={
        !!has_program && (
          <Button
            icon="upload"
            content="Upload Program from Disk"
            color="good"
            onClick={() => act('upload_program')}
          />
        )
      }
    >
      {cloud_programs.map((program) => {
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
              <Section
                mt={-2}
                title="Rules"
                buttons={
                  <>
                    {!!can_rule && (
                      <Button
                        icon="plus"
                        content="Add Rule from Disk"
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
                  program.rules.map((rule) => (
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
                      {rule.display}
                    </Box>
                  ))
                ) : (
                  <Box color="bad">No Active Rules</Box>
                )}
              </Section>
            </Section>
          </Collapsible>
        );
      })}
    </Section>
  );
};

export const NaniteCloudControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_disk, current_view, new_backup_id, cloud_backups } = data;
  return (
    <Window width={375} height={700}>
      <Window.Content scrollable>
        <Section
          title="Program Disk"
          buttons={
            <Button
              icon="eject"
              content="Eject"
              disabled={!has_disk}
              onClick={() => act('eject')}
            />
          }
        >
          <NaniteDiskBox />
        </Section>
        <Section
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
                  step={1}
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
          {!current_view ? (
            cloud_backups.map((backup) => (
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
            ))
          ) : (
            <NaniteCloudBackupDetails />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
