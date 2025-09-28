import { useBackend } from 'tgui/backend';
import { Section, Flex, ProgressBar, LabeledControls } from 'tgui/components';
import { RoundGauge } from 'tgui/components/RoundGauge';

export const RBMKOverview = () => {
  const { data } = useBackend<any>();

  const temperature = Number(data?.temperature ?? 0);
  const instability = Number(data?.instability ?? 0);
  const radiation = Number(data?.radiation ?? 0);
  const flux = Number(data?.flux ?? 0);

  const integrity = Number(data?.integrity ?? 0);
  const max_integrity = Math.max(1, Number(data?.max_integrity ?? 100));
  const pct = Math.max(
    0,
    Math.min(100, Math.round((integrity / max_integrity) * 100)),
  );

  return (
    <Flex direction="column" gap={1}>
      <Section title="Reactor Parameters">
        <LabeledControls justify="space-around" wrap>
          <LabeledControls.Item label="Temperature">
            <RoundGauge
              size={2}
              value={temperature}
              minValue={0}
              maxValue={3000}
              format={(v) => `${v} K`}
              ranges={{
                good: [0, 1200],
                yellow: [1200, 2000],
                bad: [2000, 3000],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Instability">
            <RoundGauge
              size={2}
              value={instability}
              minValue={0}
              maxValue={100}
              format={(v) => `${v}%`}
              ranges={{
                good: [0, 40],
                yellow: [40, 70],
                bad: [70, 100],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Radiation">
            <RoundGauge
              size={2}
              value={radiation}
              minValue={0}
              maxValue={500}
              format={(v) => `${v} mSv`}
              ranges={{
                good: [0, 200],
                yellow: [200, 350],
                bad: [350, 500],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Flux">
            <RoundGauge
              size={2}
              value={flux}
              minValue={0}
              maxValue={100}
              format={(v) => `${v}%`}
              ranges={{
                good: [0, 50],
                yellow: [50, 80],
                bad: [80, 100],
              }}
            />
          </LabeledControls.Item>
        </LabeledControls>
      </Section>

      <Section title="Reactor Integrity">
        <ProgressBar
          value={pct}
          maxValue={100}
          ranges={{
            good: [75, 100],
            yellow: [50, 75],
            average: [25, 50],
            bad: [10, 25],
            purple: [0, 10],
          }}
        >
          {pct}%
        </ProgressBar>
      </Section>
    </Flex>
  );
};

export default RBMKOverview;
