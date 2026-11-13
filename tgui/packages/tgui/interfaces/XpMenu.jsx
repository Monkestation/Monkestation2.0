import { useBackend } from '../backend';
import { ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

export const XpMenu = (props) => {
  const { data } = useBackend();
  const { job_levels, job_xp, job_xp_for_level } = data;
  const xpBoxes = Object.keys(job_xp_for_level).map((job) => (
    <Stack.Item key={job}>
      <Section title={job}>
        <ProgressBar
          value={job_xp[job] || 0}
          minValue={0}
          maxValue={job_xp_for_level[job]}
        >
          Level {job_levels[job] || 0} {job} ({Math.floor(job_xp[job] || 0)}/
          {Math.ceil(job_xp_for_level[job])} XP)
        </ProgressBar>
      </Section>
    </Stack.Item>
  ));

  return (
    <Window width={480} height={520}>
      <Window.Content scrollable>
        <Stack vertical grow>
          {xpBoxes}
        </Stack>
      </Window.Content>
    </Window>
  );
};
