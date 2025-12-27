import { useBackend } from '../../backend';
import {
  Section,
  Flex,
  ProgressBar,
  LabeledControls,
  RoundGauge,
} from '../../components';


export const RBMKOverview = () => {
  const { data } = useBackend<any>();

  /* ---- Core Telemetry ---- */
  const temperature = Number(data?.temperature ?? 0);
  const maxTemp = Number(data?.max_temp ?? 20000);

  const radiation = Number(data?.radiation ?? 0);
  const maxRadiation = Number(data?.max_radiation ?? 500);

  const flux = Number(data?.flux ?? 0);
  const maxFlux = Number(data?.max_flux ?? 500);

  const voidCoefficient = Number(data?.void_coefficient ?? 0);

  const integrity = Number(data?.integrity ?? 0);
  const maxIntegrity = Math.max(1, Number(data?.max_integrity ?? 100));
  const pct = Math.max(
    0,
    Math.min(100, Math.round((integrity / maxIntegrity) * 100))
  );

  return (
    <Flex direction="column" gap={1}>
      <Section title="Reactor Parameters">
        <LabeledControls justify="space-around" wrap>

          {/* Temperature */}
          <LabeledControls.Item label="Temperature">
            <RoundGauge
              size={2}
              value={temperature}
              minValue={0}
              maxValue={maxTemp}
              format={(v) => `${v.toFixed(0)} K`}
              ranges={{
                good: [0, maxTemp * 0.3],
                yellow: [maxTemp * 0.3, maxTemp * 0.7],
                bad: [maxTemp * 0.7, maxTemp],
              }}
            />
          </LabeledControls.Item>

          {/* Void Coefficient */}
          <LabeledControls.Item label="Void Coefficient">
            <RoundGauge
              size={2}
              value={voidCoefficient}
              minValue={-0.5}
              maxValue={0.6}
              format={(v) => v.toFixed(3)}
              ranges={{
                good: [-0.5, 0],
                yellow: [0, 0.3],
                bad: [0.3, 0.6],
              }}
            />
          </LabeledControls.Item>

          {/* Radiation */}
          <LabeledControls.Item label="Radiation">
            <RoundGauge
              size={2}
              value={radiation}
              minValue={0}
              maxValue={maxRadiation}
              format={(v) => `${v.toFixed(1)} mSv`}
              ranges={{
                good: [0, maxRadiation * 0.4],
                yellow: [maxRadiation * 0.4, maxRadiation * 0.7],
                bad: [maxRadiation * 0.7, maxRadiation],
              }}
            />
          </LabeledControls.Item>

          {/* Flux */}
          <LabeledControls.Item label="Flux">
            <RoundGauge
              size={2}
              value={flux}
              minValue={0}
              maxValue={maxFlux}
              format={(v) => v.toFixed(0)}
              ranges={{
                good: [0, maxFlux * 0.5],
                yellow: [maxFlux * 0.5, maxFlux * 0.8],
                bad: [maxFlux * 0.8, maxFlux],
              }}
            />
          </LabeledControls.Item>

        </LabeledControls>
      </Section>

      {/* Integrity */}
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
