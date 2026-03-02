import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import type { ReactNode } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import {
  CharacterMode,
  createSetPreference,
  type Job,
  JoblessRole,
  JobPriority,
  type PreferencesMenuData,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const sortJobs = (entries: [string, Job][], head?: string) =>
  sortBy<[string, Job]>(
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  )(entries);

const PRIORITY_BUTTON_SIZE = '18px';

const PriorityButton = (props: {
  name: string;
  color: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
}) => {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Stack.Item height={PRIORITY_BUTTON_SIZE}>
      <Button
        className={classes([
          className,
          props.modifier && `${className}--${props.modifier}`,
        ])}
        color={props.enabled ? props.color : 'white'}
        circular
        onClick={props.onClick}
        tooltip={props.name}
        tooltipPosition="bottom"
        height={PRIORITY_BUTTON_SIZE}
        width={PRIORITY_BUTTON_SIZE}
      />
    </Stack.Item>
  );
};

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCacheChar: Record<string, CreateSetPriority> = {};
const createSetPriorityCacheOver: Record<string, CreateSetPriority> = {};

const createCreateSetPriorityFromName = (
  jobName: string,
  pageType: JobsPageType,
): CreateSetPriority => {
  const createSetPriorityCache =
    pageType === JobsPageType.Character
      ? createSetPriorityCacheChar
      : createSetPriorityCacheOver;

  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  const createSetPriority = (priority: JobPriority | null) => {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    const setPriority = () => {
      const { act } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
        type: pageType,
      });
    };

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  };

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
};

const PriorityHeaders = (props: { isFilter: boolean }) => {
  const className = 'PreferencesMenu__Jobs__PriorityHeader';

  if (props.isFilter) {
    return (
      <Stack>
        <Stack.Item grow />

        <Stack.Item className={className}>Off</Stack.Item>

        <Stack.Item className={className}>On</Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack>
      <Stack.Item grow />

      <Stack.Item className={className}>Off</Stack.Item>

      <Stack.Item className={className}>Low</Stack.Item>

      <Stack.Item className={className}>Med</Stack.Item>

      <Stack.Item className={className}>High</Stack.Item>
    </Stack>
  );
};

const PriorityButtons = (props: {
  createSetPriority: CreateSetPriority;
  isBoolean: boolean;
  priority: JobPriority;
}) => {
  const { createSetPriority, isBoolean, priority } = props;

  return (
    <Stack
      style={{
        alignItems: 'center',
        height: '100%',
        justifyContent: 'flex-end',
        paddingLeft: '0.3em',
      }}
    >
      {isBoolean ? (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="On"
            color="green"
            enabled={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Low"
            color="red"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Medium"
            color="yellow"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="High"
            color="green"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Stack>
  );
};

const JobRow = (props: {
  className?: string;
  job: Job;
  name: string;
  pageType: JobsPageType;
  alt_title_mode: boolean;
}) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { className, job, name, pageType, alt_title_mode } = props;

  const isFilter =
    pageType === JobsPageType.Character &&
    data.character_preferences.misc.character_role_select_mode ===
      CharacterMode.Filters;
  const isOverflow = data.overflow_role === name;
  const job_preferences =
    pageType === JobsPageType.Overall
      ? data.job_preferences_overall
      : data.selected_character_job_preferences;
  const priority = job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name, pageType);

  const { act } = useBackend<PreferencesMenuData>();

  const experienceNeeded = data?.job_required_experience?.[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  const alt_title_selected = data.job_alt_titles[name]
    ? data.job_alt_titles[name]
    : name;

  let rightSide: ReactNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> as {experience_type}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>Banned</b>
        </Stack.Item>
      </Stack>
    );
  } else {
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        isBoolean={isOverflow || isFilter}
        priority={priority}
      />
    );
  }

  return (
    <Box className={className}>
      <Stack>
        <Tooltip content={job.description} position="right">
          <Stack.Item
            align="center"
            className="job-name"
            width="70%"
            style={{
              paddingLeft: '0.3em',
            }}
          >
            {!job.alt_titles || !alt_title_mode ? (
              <Box color="white" backgroundColor="#1b1b1baa" p={0.5}>
                {name}
              </Box>
            ) : (
              <Dropdown
                width="100%"
                options={job.alt_titles}
                selected={alt_title_selected}
                onSelected={(value) =>
                  act('set_job_title', { job: name, new_title: value })
                }
              />
            )}
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options">
          {rightSide}
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const Department: React.FC<{
  department: string;
  children?: React.ReactNode;
  pageType: JobsPageType;
  alt_title_mode: boolean;
}> = (props) => {
  const {
    children,
    department: departmentName,
    pageType,
    alt_title_mode,
  } = props;
  const className = `PreferencesMenu__Jobs__departments--${departmentName}`;

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return null;
        }

        const { departments, jobs } = data.jobs;
        const department = departments[departmentName];

        // This isn't necessarily a bug, it's like this
        // so that you can remove entire departments without
        // having to edit the UI.
        // This is used in events, for instance.
        if (!department) {
          return null;
        }

        const jobsForDepartment = sortJobs(
          Object.entries(jobs).filter(
            ([_, job]) => job.department === departmentName,
          ),
          department.head,
        );

        return (
          <Box className={className}>
            {/* <Stack vertical> */}
            {jobsForDepartment.map(([name, job]) => {
              return (
                <JobRow
                  className={classes([
                    className,
                    name === department.head && 'head',
                  ])}
                  key={name}
                  job={job}
                  name={name}
                  pageType={pageType}
                  alt_title_mode={alt_title_mode}
                />
              );
            })}
            {/* </Stack> */}
            {children}
          </Box>
        );
      }}
    />
  );
};

// *Please* find a better way to do this, this is RIDICULOUS.
// All I want is for a gap to pretend to be an empty space.
// But in order for everything to align, I also need to add the 0.2em padding.
// But also, we can't be aligned with names that break into multiple lines!
const Gap = (props: { amount: number }) => {
  // 0.2em comes from the padding-bottom in the department listing
  return <Box height={`calc(${props.amount}px + 0.2em)`} />;
};

const JoblessRoleDropdown = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;

  const options = [
    {
      displayText: `Join as ${data.overflow_role} if unavailable`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Join as a random job if unavailable`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Return to lobby if unavailable`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const selection = options?.find(
    (option) => option.value === selected,
  )?.displayText;

  return (
    <Box position="absolute" right={1} width="25%">
      <Dropdown
        width="100%"
        selected={selection}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
      />
    </Box>
  );
};

const JoblessRoleDropdown2 = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.character_role_select_mode;

  const options = [
    {
      displayText: `Mode: Simple (One Character)`, // -- Choose one character and set occupations in occupations settings
      value: CharacterMode.Simple,
    },
    {
      displayText: `Mode: Character Filters (Many Characters)`, // -- Choose at least one character, set occupations in occupation settings and set occupation filters in character settings
      value: CharacterMode.Filters,
    },
    {
      displayText: `Mode: Per Character Priorities (One Character)`, // -- Choose one character and set occupations in character settings  (old version)
      value: CharacterMode.PerCharacterPriorities,
    },
  ];

  const selection = options?.find(
    (option) => option.value === selected,
  )?.displayText;

  return (
    <Box width="30%">
      <Dropdown
        width="100%"
        selected={selection}
        onSelected={createSetPreference(act, 'character_role_select_mode')}
        options={options}
      />
      <Collapsible title="How does this work?">
        <Box
          width="250%"
          p={1}
          style={{
            border: '2px dashed grey',
          }}
        >
          Pick which roles you want the most. Some roles require extra playtime.
          For recommended starter roles check here (TODO link to wiki).
          <h3>Mode: Simple</h3>
          1. Set role priorities in Occupations <br />
          2. Pick one enabled character
          <h3>Mode: Character Filters</h3>
          Allows you to select multiple characters at once. When you join the
          game the server will pick a character which has your designated job
          enabled. If the server cannot find one it will pick your default
          character. <br />
          <br />
          1. Set role priorities in Occupations <br />
          2. Set role filters in Character Occupations <br />
          3. Pick 0 or more enabled characters <br />
          4. Pick one default character
          <h3>Mode: Per Character Priorities</h3>
          1. Set role priorities in Character Occupations <br />
          2. Pick one enabled character
        </Box>
      </Collapsible>
    </Box>
  );
};

const CharacterSelect = (props: { type: JobsPageType }) => {
  const { type } = props;
  const { act, data } = useBackend<PreferencesMenuData>();
  const mode = data.character_preferences.misc.character_role_select_mode;
  const profiles = data.character_profiles;

  const multi_select = mode === CharacterMode.Filters;

  if (type !== JobsPageType.Overall) {
    return;
  }

  return (
    <Stack justify="center" wrap>
      {profiles.map((profile, slot) => (
        <Character
          key={slot}
          slot={slot}
          profile={profile}
          multi_select={multi_select}
        />
      ))}
    </Stack>
  );
};

const Character = (props: {
  slot: number;
  profile: string | null;
  multi_select: boolean;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { slot, profile, multi_select } = props;
  const enabled_chars = data.enabled_characters;

  const selected = multi_select
    ? enabled_chars.includes(slot + 1)
    : data.active_slot === slot + 1;

  if (profile === null) {
    return null;
  }

  return (
    <Stack.Item my={0.25}>
      <Button
        selected={selected}
        onClick={() => {
          if (multi_select) {
            act('set_character_enabled', {
              slot: slot + 1,
              enabled: !selected,
            });
          } else {
            act('change_slot', {
              slot: slot + 1,
            });
          }
        }}
        fluid
      >
        {multi_select ? (
          <Icon
            name={selected ? 'check-square-o' : 'square-o'}
            style={{ float: 'left', padding: '4px 4px 4px 2px' }}
          />
        ) : (
          ''
        )}
        {profile ?? 'BAH'}
        {data.default_character === slot + 1 && multi_select
          ? ' (default)'
          : ''}
      </Button>
    </Stack.Item>
  );
};

export enum JobsPageType {
  Overall = 1,
  Character = 2,
}

export const JobsPage = (props: { type: JobsPageType }) => {
  const { type } = props;
  const { act, data } = useBackend<PreferencesMenuData>();

  const mode = data.character_preferences.misc.character_role_select_mode;

  const works =
    (type === JobsPageType.Overall &&
      mode !== CharacterMode.PerCharacterPriorities) ||
    (type === JobsPageType.Character && mode !== CharacterMode.Simple);

  const isFilter =
    type === JobsPageType.Character && mode === CharacterMode.Filters;

  const alt_title_mode =
    (type === JobsPageType.Overall && mode === CharacterMode.Simple) ||
    (type === JobsPageType.Character && mode !== CharacterMode.Simple);

  const contents2 = (
    <Stack.Item>
      <Stack className="PreferencesMenu__Jobs">
        <Stack.Item>
          <Gap amount={36} />
          <PriorityHeaders isFilter={isFilter} />

          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Engineering"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Science"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Silicon"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Assistant"
          />

          <Gap amount={10} />
          {/* <Button>Deselect All</Button> */}
          <Button
            onClick={() => {
              act('set_default_character');
            }}
          >
            Set Default Character
          </Button>
        </Stack.Item>

        <Stack.Item>
          <Gap amount={10} />
          <PriorityHeaders isFilter={isFilter} />

          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Captain"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Service"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Cargo"
          />
        </Stack.Item>

        <Stack.Item>
          <Gap amount={36} />
          <PriorityHeaders isFilter={isFilter} />

          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Security"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Medical"
          />
          <Department
            pageType={type}
            alt_title_mode={alt_title_mode}
            department="Central Command"
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );

  const contents = (
    <Stack vertical>
      <JoblessRoleDropdown />
      <JoblessRoleDropdown2 />
      <CharacterSelect type={type} />
      {works ? contents2 : ''}
    </Stack>
  );

  if (type === JobsPageType.Overall) {
    return (
      <Section title="Occupations" maxHeight="100%" overflowY="scroll">
        {contents}
      </Section>
    );
  }
  return <Section>{contents}</Section>;
};
