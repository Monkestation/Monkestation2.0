import type { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import type { Material, MaterialMap } from './Fabrication/Types';

type InsertedRod = {
  index: number;
  name: string;
  desc: string;
  rod_type: string;
  depleted: BooleanLike;
};

type OutputItem = {
  index: number;
  name: string;
  desc: string;
};

type Recipe = {
  id: string;
  name: string;
  description: string;
  cost: MaterialMap;
  requires_inserted_rod: BooleanLike;
  creates_spent_casing: BooleanLike;
  visible: BooleanLike;
  can_start: BooleanLike;
  block_reason: string | null;
  max_batch: number;
};

type Data = {
  processing: BooleanLike;
  current_process: string | null;
  current_batch_size: number;
  process_progress: number;

  inserted_rods: InsertedRod[];
  max_batch_size: number;
  output_items: OutputItem[];
  recipes: Recipe[];

  materials: Material[];
  SHEET_MATERIAL_AMOUNT: number;
  onHold: BooleanLike;
};

const formatSheetAmount = (amount: number, sheetMaterialAmount: number) => {
  if (!sheetMaterialAmount) {
    return `${amount}`;
  }

  return formatSiUnit(amount / sheetMaterialAmount, 0);
};

const RecipeMaterialStrip = (props: {
  cost: MaterialMap;
  requiresInsertedRod: BooleanLike;
  availableMaterials: MaterialMap;
  sheetMaterialAmount: number;
}) => {
  const { cost, requiresInsertedRod, availableMaterials, sheetMaterialAmount } =
    props;
  const costEntries = Object.entries(cost || {});

  if (!costEntries.length) {
    return (
      <Box color={requiresInsertedRod ? 'average' : 'label'}>
        {requiresInsertedRod ? 'Inserted depleted rod' : 'No material cost'}
      </Box>
    );
  }

  return (
    <>
      <MaterialCostSequence
        costMap={cost}
        available={availableMaterials}
        SHEET_MATERIAL_AMOUNT={sheetMaterialAmount}
        justify="flex-start"
      />
      <Box color="label" mt={0.5}>
        {costEntries
          .map(
            ([material, amount]) =>
              `${formatSheetAmount(amount, sheetMaterialAmount)} ${material}`,
          )
          .join(', ')}
      </Box>
    </>
  );
};

const InsertedRodDisplay = (props: {
  insertedRods: InsertedRod[];
  processing: BooleanLike;
  maxBatchSize: number;
}) => {
  const { act } = useBackend<Data>();
  const { insertedRods, processing, maxBatchSize } = props;

  return (
    <Section title={`Loaded Rods (${insertedRods.length}/${maxBatchSize})`}>
      {insertedRods.length ? (
        <Table>
          <Table.Row header>
            <Table.Cell>Rod</Table.Cell>
            <Table.Cell collapsing>Action</Table.Cell>
          </Table.Row>
          {insertedRods.map((rod) => (
            <Table.Row key={rod.index}>
              <Table.Cell>
                <Box bold>{rod.name}</Box>
                <Box color="label">
                  {rod.rod_type} — {rod.depleted ? 'Depleted' : 'Active'}
                </Box>
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  icon="eject"
                  disabled={!!processing}
                  onClick={() =>
                    act('eject_inserted_rod', { index: rod.index })
                  }
                >
                  Eject
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Box color="label">
          Insert up to {maxBatchSize} depleted uranium or thorium fuel rods for
          bulk isotope extraction.
        </Box>
      )}
    </Section>
  );
};

const OutputTray = (props: {
  outputItems: OutputItem[];
  processing: BooleanLike;
}) => {
  const { act } = useBackend<Data>();
  const { outputItems, processing } = props;

  return (
    <Section title="Output Tray">
      {!outputItems.length ? (
        <Box color="label">No completed outputs.</Box>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Item</Table.Cell>
            <Table.Cell collapsing>Action</Table.Cell>
          </Table.Row>

          {outputItems.map((item) => (
            <Table.Row key={item.index}>
              <Table.Cell>
                <Box bold>{item.name}</Box>
                <Box color="label">{item.desc}</Box>
              </Table.Cell>

              <Table.Cell collapsing>
                <Button
                  icon="eject"
                  disabled={!!processing}
                  onClick={() =>
                    act('eject_output', {
                      index: item.index,
                    })
                  }
                >
                  Eject
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const Recipes = (props: {
  recipes: Recipe[];
  sheetMaterialAmount: number;
  availableMaterials: MaterialMap;
  processing: BooleanLike;
  showCatalog: boolean;
  onToggleCatalog: () => void;
}) => {
  const { act } = useBackend<Data>();
  const {
    recipes,
    sheetMaterialAmount,
    availableMaterials,
    processing,
    showCatalog,
    onToggleCatalog,
  } = props;

  const displayedRecipes = showCatalog
    ? recipes
    : recipes.filter((recipe) => !!recipe.visible);

  return (
    <Section
      title={showCatalog ? 'Recipe Catalog' : 'Available Processes'}
      buttons={
        <Button
          icon={showCatalog ? 'eye-slash' : 'book'}
          selected={showCatalog}
          onClick={onToggleCatalog}
        >
          {showCatalog ? 'Hide Catalog' : 'Show Recipe Catalog'}
        </Button>
      }
    >
      {!displayedRecipes.length ? (
        <NoticeBox>
          No processes are currently available. Insert materials, load a
          depleted fuel rod, or open the recipe catalog.
        </NoticeBox>
      ) : (
        displayedRecipes.map((recipe) => (
          (() => {
            const batchOptions = Array.from(
              new Set([1, 5, 10, recipe.max_batch]),
            ).filter((amount) => amount > 0 && amount <= recipe.max_batch);

            return (
          <Box
            key={recipe.id}
            mb={1}
            p={1}
            style={{
              background: 'rgba(255, 255, 255, 0.035)',
              borderLeft: recipe.can_start
                ? '3px solid #45a049'
                : '3px solid #3d4f61',
              borderTop: '1px solid rgba(96, 160, 220, 0.35)',
            }}
          >
            <Stack align="center">
              <Stack.Item width="44px">
                <Box
                  textAlign="center"
                  style={{
                    color: recipe.can_start ? '#7bd36f' : '#7d8790',
                    fontSize: '22px',
                  }}
                >
                  <Icon
                    name={
                      recipe.requires_inserted_rod ? 'radiation' : 'industry'
                    }
                  />
                </Box>
              </Stack.Item>

              <Stack.Item grow>
                <Box bold>{recipe.name}</Box>
                <Box color="label">{recipe.description}</Box>

                <Box
                  mt={1}
                  pt={0.5}
                  style={{ borderTop: '1px solid rgba(255,255,255,0.12)' }}
                >
                  <RecipeMaterialStrip
                    cost={recipe.cost}
                    requiresInsertedRod={recipe.requires_inserted_rod}
                    availableMaterials={availableMaterials}
                    sheetMaterialAmount={sheetMaterialAmount}
                  />
                </Box>

                {!!recipe.requires_inserted_rod && (
                  <Box color="average" mt={0.5}>
                    Requires inserted depleted rod.
                  </Box>
                )}

                {!!recipe.creates_spent_casing && (
                  <Box color="bad" mt={0.5}>
                    Produces spent casing waste.
                  </Box>
                )}

                {showCatalog && !recipe.visible && (
                  <Box color="label" mt={0.5}>
                    Catalog entry.
                  </Box>
                )}
              </Stack.Item>

              <Stack.Item width="190px">
                <Box
                  color={recipe.can_start ? 'good' : 'bad'}
                  mb={1}
                  textAlign="right"
                >
                  {recipe.can_start ? 'Ready' : recipe.block_reason}
                </Box>
                <Stack justify="flex-end" wrap>
                  {batchOptions.map((amount) => (
                    <Stack.Item key={amount}>
                      <Button
                        icon="play"
                        disabled={!recipe.can_start || !!processing}
                        color={
                          recipe.creates_spent_casing ? 'bad' : undefined
                        }
                        onClick={() =>
                          act('start', {
                            recipe: recipe.id,
                            quantity: amount,
                          })
                        }
                      >
                        x{amount}
                      </Button>
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
            );
          })()
        ))
      )}
    </Section>
  );
};

export const RBMKFuelProcessor = () => {
  const { act, data } = useBackend<Data>();
  const [showCatalog, setShowCatalog] = useLocalState('showCatalog', false);

  const {
    processing,
    current_process,
    current_batch_size,
    process_progress,

    inserted_rods = [],
    max_batch_size,
    output_items = [],
    recipes = [],

    materials = [],
    SHEET_MATERIAL_AMOUNT,
    onHold,
  } = data;

  const availableMaterials: MaterialMap = {};
  for (const material of materials) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window width={920} height={720}>
      <Window.Content scrollable>
        {!!onHold && (
          <NoticeBox>Linked ore silo access is currently suspended.</NoticeBox>
        )}

        {!!processing && (
          <NoticeBox>
            {current_process || 'Processing...'} — Batch x{current_batch_size}
            <ProgressBar value={process_progress / 100} mt={1}>
              {process_progress}%
            </ProgressBar>
          </NoticeBox>
        )}

        <Section title="RBMK Fuel Processor">
          <LabeledList>
            <LabeledList.Item label="Status">
              {processing ? 'Processing' : 'Ready'}
            </LabeledList.Item>
            <LabeledList.Item label="Fuel Chain">
              Uranium → Thorium → Plutonium
            </LabeledList.Item>
            <LabeledList.Item label="Rod Casing">
              3 iron sheets per fabricated rod
            </LabeledList.Item>
            <LabeledList.Item label="Isotope Recovery">
              5 sheets per depleted rod
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Stack>
          <Stack.Item grow>
            <InsertedRodDisplay
              insertedRods={inserted_rods}
              processing={processing}
              maxBatchSize={max_batch_size}
            />
          </Stack.Item>

          <Stack.Item grow>
            <OutputTray outputItems={output_items} processing={processing} />
          </Stack.Item>
        </Stack>

        <Recipes
          recipes={recipes}
          sheetMaterialAmount={SHEET_MATERIAL_AMOUNT}
          availableMaterials={availableMaterials}
          processing={processing}
          showCatalog={showCatalog}
          onToggleCatalog={() => setShowCatalog(!showCatalog)}
        />

        <Section title="Linked Materials">
          <Box color="label" mb={1}>
            Inserted material stacks are sent to linked material storage.
          </Box>

          <MaterialAccessBar
            availableMaterials={materials}
            SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
            onEjectRequested={(material, amount) =>
              act('remove_mat', {
                ref: material.ref,
                amount,
              })
            }
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

export default RBMKFuelProcessor;
