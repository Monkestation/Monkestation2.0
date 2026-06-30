import type { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import type { Material } from './Fabrication/Types';

type InsertedRod = {
  name: string;
  desc: string;
  rod_type: string;
  depleted: BooleanLike;
} | null;

type OutputItem = {
  index: number;
  name: string;
  desc: string;
};

type RecipeCost = {
  name: string;
  amount: number;
};

type Recipe = {
  id: string;
  name: string;
  description: string;
  costs: RecipeCost[];
  requires_inserted_rod: BooleanLike;
  creates_spent_casing: BooleanLike;
  visible: BooleanLike;
  can_start: BooleanLike;
  block_reason: string | null;
};

type Data = {
  processing: BooleanLike;
  current_process: string | null;
  process_progress: number;

  inserted_rod: InsertedRod;
  output_items: OutputItem[];
  recipes: Recipe[];

  materials: Material[];
  SHEET_MATERIAL_AMOUNT: number;
  onHold: BooleanLike;
};

const formatSheetAmount = (amount: number, sheetMaterialAmount: number) => {
  if (!sheetMaterialAmount) {
    return amount;
  }

  return amount / sheetMaterialAmount;
};

const CostDisplay = (props: {
  costs: RecipeCost[];
  sheetMaterialAmount: number;
}) => {
  const { costs, sheetMaterialAmount } = props;

  if (!costs.length) {
    return <Box color="label">No material cost.</Box>;
  }

  return (
    <Stack vertical>
      {costs.map((cost) => (
        <Stack.Item key={cost.name}>
          <Box>
            {formatSheetAmount(cost.amount, sheetMaterialAmount)} {cost.name}
          </Box>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const InsertedRodDisplay = (props: {
  insertedRod: InsertedRod;
  processing: BooleanLike;
}) => {
  const { act } = useBackend<Data>();
  const { insertedRod, processing } = props;

  return (
    <Section
      title="Inserted Rod"
      buttons={
        <Button
          icon="eject"
          disabled={!insertedRod || !!processing}
          onClick={() => act('eject_inserted_rod')}
        >
          Eject
        </Button>
      }
    >
      {insertedRod ? (
        <>
          <Box bold>{insertedRod.name}</Box>
          <Box color="label">{insertedRod.desc}</Box>
          <Box mt={1}>
            <LabeledList>
              <LabeledList.Item label="Type">
                {insertedRod.rod_type}
              </LabeledList.Item>
              <LabeledList.Item label="State">
                {insertedRod.depleted ? 'Depleted' : 'Active'}
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </>
      ) : (
        <Box color="label">
          Insert a depleted uranium or thorium fuel rod to unlock isotope
          extraction.
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
  processing: BooleanLike;
  showCatalog: boolean;
  onToggleCatalog: () => void;
}) => {
  const { act } = useBackend<Data>();
  const {
    recipes,
    sheetMaterialAmount,
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
        <Table>
          <Table.Row header>
            <Table.Cell>Process</Table.Cell>
            <Table.Cell>Cost</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell collapsing>Action</Table.Cell>
          </Table.Row>

          {displayedRecipes.map((recipe) => (
            <Table.Row key={recipe.id}>
              <Table.Cell>
                <Box bold>{recipe.name}</Box>
                <Box color="label">{recipe.description}</Box>

                {showCatalog && !recipe.visible && (
                  <Box color="label" mt={0.5}>
                    Catalog entry.
                  </Box>
                )}

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
              </Table.Cell>

              <Table.Cell>
                <CostDisplay
                  costs={recipe.costs}
                  sheetMaterialAmount={sheetMaterialAmount}
                />
              </Table.Cell>

              <Table.Cell>
                {recipe.can_start ? (
                  <Box color="good">Ready</Box>
                ) : (
                  <Box color="bad">{recipe.block_reason}</Box>
                )}
              </Table.Cell>

              <Table.Cell collapsing>
                <Button
                  icon="play"
                  disabled={!recipe.can_start || !!processing}
                  color={recipe.creates_spent_casing ? 'bad' : undefined}
                  onClick={() =>
                    act('start', {
                      recipe: recipe.id,
                    })
                  }
                >
                  Start
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
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
    process_progress,

    inserted_rod,
    output_items = [],
    recipes = [],

    materials = [],
    SHEET_MATERIAL_AMOUNT,
    onHold,
  } = data;

  return (
    <Window width={920} height={720}>
      <Window.Content scrollable>
        {!!onHold && (
          <NoticeBox>
            Linked ore silo access is currently suspended.
          </NoticeBox>
        )}

        {!!processing && (
          <NoticeBox>
            {current_process || 'Processing...'}
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
              insertedRod={inserted_rod}
              processing={processing}
            />
          </Stack.Item>

          <Stack.Item grow>
            <OutputTray outputItems={output_items} processing={processing} />
          </Stack.Item>
        </Stack>

        <Recipes
          recipes={recipes}
          sheetMaterialAmount={SHEET_MATERIAL_AMOUNT}
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
