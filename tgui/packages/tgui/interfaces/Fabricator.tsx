import { classes } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Dropdown,
  Flex,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import type { Design, FabricatorData, MaterialMap } from './Fabrication/Types';

export const Fabricator = (props) => {
  const { act, data } = useBackend<FabricatorData>();
  const {
    fabName,
    onHold,
    designs,
    busy,
    SHEET_MATERIAL_AMOUNT,
    ui_theme,
    machine_mode,
    mode_toggle_label,
    lathe_recipe_label,
    lathe_recipe_can_switch,
    lathe_recipe_set,
    lathe_recipe_sets,
  } = data;
  const ammoMode = machine_mode === 'ammo';
  const latheMode = machine_mode === 'lathe';

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title={fabName} width={670} height={600} theme={ui_theme}>
      <Window.Content>
        <Stack vertical fill>
          {!!machine_mode && (
            <Stack.Item>
              <Section
                title={
                  ammoMode
                    ? 'Ammo Workbench Mode'
                    : 'Fabricator Mode'
                }
                buttons={
                  <Stack>
                    {latheMode && (
                      <Stack.Item>
                        <Dropdown
                          width="220px"
                          selected={lathe_recipe_set || 'autolathe'}
                          displayText={lathe_recipe_label || 'Autolathe'}
                          options={lathe_recipe_sets || []}
                          disabled={!lathe_recipe_can_switch || !!busy}
                          onSelected={(recipe_set) =>
                            act('set_recipe_set', { recipe_set })
                          }
                        />
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button
                        icon="exchange-alt"
                        content={mode_toggle_label || 'Switch Mode'}
                        onClick={() => act('switch_mode')}
                      />
                    </Stack.Item>
                  </Stack>
                }
              />
            </Stack.Item>
          )}
          <Stack.Item grow>
            {!ammoMode ? (
              <DesignBrowser
                busy={!!busy}
                designs={Object.values(designs)}
                availableMaterials={availableMaterials}
                buildRecipeElement={(design, availableMaterials) => (
                  <Recipe
                    design={design}
                    available={availableMaterials}
                    SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                  />
                )}
              />
            ) : (
              <AmmoWorkbenchPanel />
            )}
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={data.materials ?? []}
                SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
        {!!onHold && (
          <Dimmer style={{ fontSize: '2em', textAlign: 'center' }}>
            Mineral access is on hold, please contact the quartermaster.
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};

const AmmoWorkbenchPanel = () => {
  const { act, data } = useBackend<FabricatorData>();
  const {
    mag_loaded,
    system_busy,
    error,
    error_type,
    mag_name,
    current_rounds,
    max_rounds,
    available_rounds,
  } = data;

  return (
    <Stack vertical fill>
      {!!error && (
        <Stack.Item>
          <NoticeBox textAlign="center" color={error_type || undefined}>
            {error}
          </NoticeBox>
        </Stack.Item>
      )}
      <Stack.Item>
        <Section
          title="Loaded Magazine"
          buttons={
            <Button
              icon="eject"
              content="Eject"
              disabled={!mag_loaded}
              onClick={() => act('EjectMag')}
            />
          }
        >
          {mag_loaded ? (
            <Stack vertical>
              <Stack.Item>{mag_name}</Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={current_rounds || 0}
                  minValue={0}
                  maxValue={max_rounds || 1}
                >
                  {(current_rounds || 0) + ' / ' + (max_rounds || 0)}
                </ProgressBar>
              </Stack.Item>
            </Stack>
          ) : (
            <Box color="label">Insert a magazine or ammo box to begin.</Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Available Ammunition Types" fill scrollable>
          {!!mag_loaded && (
            <Flex.Item grow={1} basis={0}>
              {(available_rounds || []).map((available_round) => (
                <Box
                  key={available_round.typepath}
                  className="candystripe"
                  p={1}
                  pb={2}
                >
                    <Stack.Item>
                      <Tooltip content={available_round.mats_list} position="right">
                      <Button
                        content={available_round.name}
                        disabled={!!system_busy}
                        onClick={() =>
                          act('FillMagazine', {
                            selected_type: available_round.typepath,
                          })
                        }
                      />
                      </Tooltip>
                    </Stack.Item>
                </Box>
              ))}
            </Flex.Item>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  SHEET_MATERIAL_AMOUNT: number;
  available: MaterialMap;
};

const PrintButton = (props: PrintButtonProps) => {
  const { act } = useBackend<FabricatorData>();
  const { design, quantity, available, SHEET_MATERIAL_AMOUNT } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount * quantity > (available[material] ?? 0),
  );

  return (
    <Tooltip
      content={
        <MaterialCostSequence
          design={design}
          amount={quantity}
          SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
          available={available}
        />
      }
    >
      <div
        className={classes([
          'FabricatorRecipe__Button',
          !canPrint && 'FabricatorRecipe__Button--disabled',
        ])}
        color={'transparent'}
        onClick={() => act('build', { ref: design.id, amount: quantity })}
      >
        &times;{quantity}
      </div>
    </Tooltip>
  );
};

type CustomPrintProps = {
  design: Design;
  available: MaterialMap;
};

const CustomPrint = (props: CustomPrintProps) => {
  const { act } = useBackend();
  const { design, available } = props;
  let maxMult = Object.entries(design.cost).reduce(
    (accumulator: number, [material, required]) => {
      return Math.min(accumulator, (available[material] || 0) / required);
    },
    Infinity,
  );
  maxMult = Math.min(Math.floor(maxMult), 50);
  const canPrint = maxMult > 0;

  return (
    <div
      className={classes([
        'FabricatorRecipe__Button',
        !canPrint && 'FabricatorRecipe__Button--disabled',
      ])}
    >
      <Button.Input
        buttonText={`[Max: ${maxMult}]`}
        color={'transparent'}
        onCommit={(value: string) =>
          act('build', {
            ref: design.id,
            amount: value,
          })
        }
      />
    </div>
  );
};

type RecipeProps = {
  design: Design;
  available: MaterialMap;
  SHEET_MATERIAL_AMOUNT: number;
};

const Recipe = (props: RecipeProps) => {
  const { act } = useBackend<FabricatorData>();
  const { design, available, SHEET_MATERIAL_AMOUNT } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0),
  );

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint && 'FabricatorRecipe__Button--disabled',
          ])}
        >
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={design}
            amount={1}
            SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            available={available}
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() =>
            canPrint && act('build', { ref: design.id, amount: 1 })
          }
        >
          <div className="FabricatorRecipe__Icon">
            <Box
              width={'32px'}
              height={'32px'}
              className={classes(['design32x32', design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{design.name}</div>
        </div>
      </Tooltip>
      <PrintButton
        design={design}
        quantity={5}
        available={available}
        SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
      />
      <PrintButton
        design={design}
        quantity={10}
        available={available}
        SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
      />
      <CustomPrint design={design} available={available} />
    </div>
  );
};
