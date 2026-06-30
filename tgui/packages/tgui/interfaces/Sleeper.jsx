import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Oxygen',
    type: 'oxyLoss',
  },
];

export const Sleeper = (props) => {
  const { act, data } = useBackend();
  const {
    open,
    occupant = {},
    occupied,
    inject_amount,
    available_amounts,
    max_custom_storage,
    standard_chems = [],
    custom_chems = [],
    synthesis_active,
    synthesis_rate,
    forced_synthesis_chem,
    forced_synthesis_name,
    is_synthesizing,
  } = data;

  const windowHeight = Math.min(
    800,
    Math.max(550, 550 + custom_chems.length * 28),
  );

  let synthesisTooltip = '';
  if (synthesis_active && is_synthesizing && forced_synthesis_name) {
    synthesisTooltip = `Forced: ${forced_synthesis_name} synthesis is ON (${synthesis_rate}u/2s)`;
  } else if (synthesis_active && is_synthesizing) {
    synthesisTooltip = `General synthesis is ON (${synthesis_rate}u/2s)`;
  } else if (synthesis_active && !is_synthesizing) {
    synthesisTooltip = 'Synthesis paused — all chemicals full';
  } else {
    synthesisTooltip = 'Synthesis is OFF — click to start';
  }

  let forcedText = '';
  if (synthesis_active && is_synthesizing && forced_synthesis_name) {
    forcedText = `Forced: ${forced_synthesis_name}`;
  } else if (synthesis_active && is_synthesizing) {
    forcedText = 'General synthesis';
  } else if (synthesis_active && !is_synthesizing) {
    forcedText = 'Paused (full)';
  } else {
    forcedText = 'Synthesis is OFF';
  }

  return (
    <Window width={560} height={windowHeight}>
      <Window.Content>
        <Stack fill vertical>
          {/* THE UPPER HALF: patient and chems in blood */}
          <Stack.Item grow={1}>
            <Stack fill>
              {/* THE LEFT COLUMN: PATIENT INFORMATION */}
              <Stack.Item basis="50%">
                <Section
                  title={occupant.name ? occupant.name : 'No Occupant'}
                  fill
                  buttons={
                    !!occupant.stat && (
                      <Box inline bold color={occupant.statstate}>
                        {occupant.stat}
                      </Box>
                    )
                  }
                >
                  {!!occupied && (
                    <>
                      <ProgressBar
                        value={occupant.health}
                        minValue={occupant.minHealth}
                        maxValue={occupant.maxHealth}
                        ranges={{
                          good: [50, Infinity],
                          average: [0, 50],
                          bad: [-Infinity, 0],
                        }}
                      />
                      <Box mt={1} />
                      <LabeledList>
                        {damageTypes.map((type) => {
                          const damageValue = occupant[type.type];
                          return (
                            <LabeledList.Item
                              key={type.type}
                              label={type.label}
                            >
                              <ProgressBar
                                value={damageValue}
                                minValue={0}
                                maxValue={occupant.maxHealth}
                                ranges={{
                                  good: [-Infinity, 50],
                                  average: [50, 100],
                                  bad: [100, Infinity],
                                }}
                              />
                            </LabeledList.Item>
                          );
                        })}
                        <LabeledList.Item
                          label="Cells"
                          color={occupant.cloneLoss ? 'bad' : 'good'}
                        >
                          {occupant.cloneLoss ? 'Damaged' : 'Healthy'}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label="Brain"
                          color={occupant.brainLoss ? 'bad' : 'good'}
                        >
                          {occupant.brainLoss ? 'Abnormal' : 'Healthy'}
                        </LabeledList.Item>
                        <LabeledList.Item label="Blood Volume">
                          <ProgressBar
                            value={occupant.blood_volume || 0}
                            minValue={0}
                            maxValue={560}
                            ranges={{
                              good: [448, 560],
                              average: [280, 448],
                              bad: [0, 280],
                            }}
                          />
                        </LabeledList.Item>
                      </LabeledList>
                    </>
                  )}
                </Section>
              </Stack.Item>

              {/* THE RIGHT COLUMN: CHEMICALS IN THE BLOOD */}
              <Stack.Item basis="50%">
                <Section title="Blood Chemicals" fill>
                  {!occupied ? (
                    <Box color="grey" textAlign="center" mt={2}>
                      No occupant
                    </Box>
                  ) : !occupant.blood_chems ||
                    occupant.blood_chems.length === 0 ? (
                    <Box color="grey" textAlign="center" mt={2}>
                      No chemicals detected in blood
                    </Box>
                  ) : (
                    <Box>
                      {occupant.blood_chems.map((chem, index) => (
                        <Box key={index} mb={1}>
                          <Box color={chem.overdosed ? 'bad' : 'good'}>
                            {Math.round(chem.volume * 10) / 10} units of{' '}
                            {chem.name}
                            {chem.overdosed ? ' - OVERDOSING' : ''}
                          </Box>
                        </Box>
                      ))}
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {/* THE LOWER HALF: medicines */}
          <Stack.Item>
            <Section
              title="Medicines"
              buttons={
                <>
                  <Button
                    icon="cog"
                    content={
                      synthesis_active && is_synthesizing
                        ? 'Synthesis: ON'
                        : 'Synthesis: OFF'
                    }
                    color={
                      synthesis_active && is_synthesizing ? 'green' : 'default'
                    }
                    tooltip={synthesisTooltip}
                    onClick={() => act('toggle_synthesis')}
                  />
                  <Button
                    icon={open ? 'door-open' : 'door-closed'}
                    content={open ? 'Open' : 'Closed'}
                    onClick={() => act('door')}
                  />
                </>
              }
            >
              {/* SETTING THE DOSAGE */}
              <Box mb={2}>
                <Box mb={1} fontSize="12px" color="label">
                  Injection Amount:
                </Box>
                <Stack spacing={1}>
                  {available_amounts?.map((amount) => (
                    <Stack.Item key={amount}>
                      <Button
                        content={`${amount} units`}
                        selected={inject_amount === amount}
                        color={inject_amount === amount ? 'green' : 'default'}
                        onClick={() => act('set_amount', { amount: amount })}
                      />
                    </Stack.Item>
                  ))}
                </Stack>
              </Box>

              {/* STANDARD CHEMICALS */}
              <Box mb={2}>
                <Box mb={0.5} fontSize="12px" color="label">
                  Standard Chemicals:
                </Box>
                <Box display="flex" flexWrap="wrap" gap="4px">
                  {standard_chems.map((chem) => (
                    <Tooltip
                      key={chem.id}
                      content={
                        <Box backgroundColor="#1a1a1a" p={1}>
                          <Box color="green" bold>
                            {chem.full_name}
                          </Box>
                          <Box color="label" mt={0.5}>
                            {chem.description}
                          </Box>
                          <Box color="good" mt={0.5}>
                            ♾️ Unlimited
                          </Box>
                        </Box>
                      }
                      position="top"
                    >
                      <Button
                        icon="flask"
                        content={chem.name}
                        disabled={!occupied || !chem.allowed}
                        width="130px"
                        onClick={() =>
                          act('inject', {
                            chem: chem.id,
                          })
                        }
                      />
                    </Tooltip>
                  ))}
                </Box>
              </Box>

              {/* CUSTOM CHEMICALS */}
              <Box>
                <Box mb={0.5} fontSize="12px" color="label">
                  Custom Chemicals:
                  <Box
                    inline
                    color={
                      synthesis_active && is_synthesizing ? 'green' : 'default'
                    }
                    ml={1}
                  >
                    ({forcedText})
                  </Box>
                </Box>
                {custom_chems.length === 0 ? (
                  <Box color="grey" textAlign="center" mt={1}>
                    You can add custom chemicals manually.
                  </Box>
                ) : (
                  <Box display="flex" flexDirection="column" gap="4px">
                    {custom_chems.map((chem) => {
                      const isForced = chem.id === forced_synthesis_chem;
                      return (
                        <Box
                          key={chem.id}
                          display="flex"
                          alignItems="center"
                          gap="4px"
                          flexWrap="nowrap"
                        >
                          {/* The injection button */}
                          <Tooltip
                            content={
                              <Box backgroundColor="#1a1a1a" p={1}>
                                <Box color="green" bold>
                                  {chem.full_name}
                                </Box>
                                <Box color="label" mt={0.5}>
                                  {chem.description}
                                </Box>
                                <Box
                                  color={chem.is_empty ? 'bad' : 'good'}
                                  mt={0.5}
                                >
                                  {chem.is_empty
                                    ? '⚠ EMPTY'
                                    : `${chem.storage}u available`}
                                </Box>
                              </Box>
                            }
                            position="top"
                          >
                            <Button
                              icon="flask"
                              content={chem.name}
                              disabled={!occupied || !chem.allowed}
                              width="130px"
                              onClick={() =>
                                act('inject_custom', { chem: chem.id })
                              }
                            />
                          </Tooltip>

                          {/* Stock scale */}
                          <ProgressBar
                            value={chem.storage}
                            maxValue={chem.max_storage}
                            ranges={{
                              good: [chem.max_storage * 0.5, Infinity],
                              average: [
                                chem.max_storage * 0.25,
                                chem.max_storage * 0.5,
                              ],
                              bad: [0, chem.max_storage * 0.25],
                            }}
                            width="264px"
                          >
                            {`${chem.storage}u / ${chem.max_storage}u (${chem.percent}%)`}
                          </ProgressBar>

                          {/* Chemical Synthesis button */}
                          <Button
                            icon="bolt"
                            content="Synthesis"
                            color={
                              isForced && synthesis_active ? 'green' : 'default'
                            }
                            width="108px"
                            tooltip={
                              isForced && synthesis_active
                                ? 'Forcing synthesis'
                                : 'Click to force synthesis for this chem. Greatly increases energy consumption.'
                            }
                            onClick={() =>
                              act('force_synthesis', { chem: chem.id })
                            }
                          />

                          {/* Line deletion button */}
                          <Button
                            icon="times"
                            color="bad"
                            width="22px"
                            tooltip={`Remove ${chem.full_name}`}
                            onClick={() =>
                              act('remove_custom_chem', { chem: chem.id })
                            }
                          />
                        </Box>
                      );
                    })}
                  </Box>
                )}
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
