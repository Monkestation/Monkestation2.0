import {
  Button,
  Dropdown,
  Input,
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
  name: string;
  desc: string;
  use_rate: string;
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
  has_extra_settings: BooleanLike;
  extra_settings: ExtraSettingsData[];
};

type ExtraSettingsData = {
  name: string;
  setting: string;
};

const NaniteCodes = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    activation_code,
    deactivation_code,
    kill_code,
    can_trigger,
    trigger_code,
  } = data;
  return (
    <Section title="Codes" mr={1}>
      <LabeledList>
        <LabeledList.Item label="Activation">
          <NumberInput
            value={activation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            step={1}
            onChange={(value) =>
              act('set_code', {
                target_code: 'activation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Deactivation">
          <NumberInput
            value={deactivation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            step={1}
            onChange={(value) =>
              act('set_code', {
                target_code: 'deactivation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Kill">
          <NumberInput
            value={kill_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            step={1}
            onChange={(value) =>
              act('set_code', {
                target_code: 'kill',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        {!!can_trigger && (
          <LabeledList.Item label="Trigger">
            <NumberInput
              value={trigger_code}
              width="47px"
              minValue={0}
              maxValue={9999}
              step={1}
              onChange={(value) =>
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

const NaniteDelays = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    timer_restart,
    timer_shutdown,
    can_trigger,
    timer_trigger,
    timer_trigger_delay,
  } = data;
  return (
    <Section title="Delays" ml={1}>
      <LabeledList>
        <LabeledList.Item label="Restart Timer">
          <NumberInput
            value={timer_restart}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            step={1}
            onChange={(value) =>
              act('set_restart_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Shutdown Timer">
          <NumberInput
            value={timer_shutdown}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            step={1}
            onChange={(value) =>
              act('set_shutdown_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        {!!can_trigger && (
          <>
            <LabeledList.Item label="Trigger Repeat Timer">
              <NumberInput
                value={timer_trigger}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                step={1}
                onChange={(value) =>
                  act('set_trigger_timer', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Trigger Delay">
              <NumberInput
                value={timer_trigger_delay}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                step={1}
                onChange={(value) =>
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

const NaniteExtraEntry = (props) => {
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

const NaniteExtraNumber = (props) => {
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
      step={1}
      onChange={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

const NaniteExtraText = (props) => {
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

const NaniteExtraType = (props) => {
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

const NaniteExtraBoolean = (props) => {
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

const NaniteProgrammerContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_disk,
    has_program,
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activated,
    has_extra_settings,
    extra_settings = [],
  } = data;
  if (!has_disk) {
    return (
      <NoticeBox textAlign="center">Insert a nanite program disk</NoticeBox>
    );
  }
  if (!has_program) {
    return (
      <Section
        title="Blank Disk"
        buttons={
          <Button icon="eject" content="Eject" onClick={() => act('eject')} />
        }
      />
    );
  }
  return (
    <Section
      title={name}
      buttons={
        <Button icon="eject" content="Eject" onClick={() => act('eject')} />
      }
    >
      <Section title="Info">
        <Table>
          <Table.Cell>{desc}</Table.Cell>
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
      </Section>
      <Section
        title="Settings"
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
        <Table>
          <Table.Cell>
            <NaniteCodes />
          </Table.Cell>
          <Table.Cell>
            <NaniteDelays />
          </Table.Cell>
        </Table>
        {!!has_extra_settings && (
          <Section title="Special">
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
