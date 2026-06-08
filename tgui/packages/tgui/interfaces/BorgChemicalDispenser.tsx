import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

/**
 * BackEnd Context data
 */
type GeneralContext = {
  theme: string;
  amount: number;
  transferAmounts: number[];
  minTransferVolume: number;
  maxTransferVolume: number;
  maxReagentVolume: number;
  reagents: Reagent[];
  selectedReagentLeft?: string;
  selectedReagentRight?: string;
  saved_recipes: Record<string, Record<string, number>>;
  selectedRecipeIdLeft?: string;
  selectedRecipeIdRight?: string;
  recording: boolean;
  recordingRecipe: string[];
  canReagentSearch: boolean;
};

/**
 * Reagent: name, storage capacity, description.
 */
export type Reagent = {
  name: string;
  full_name: string;
  id: string;
  volume: number;
  description: string;
};

/**
 * The main component (body) of the Borg chemical Hypospray interface.
 */
export const BorgChemicalDispenser = () => {
  const { act, data } = useBackend<GeneralContext>();
  const {
    theme,
    amount,
    transferAmounts,
    minTransferVolume,
    maxTransferVolume,
    maxReagentVolume,
    saved_recipes,
    recordingRecipe,
    reagents,
    selectedReagentLeft,
    selectedReagentRight,
    selectedRecipeIdLeft,
    selectedRecipeIdRight,
    canReagentSearch,
  } = data;

  // Height calculation for the right column (chemicals)
  const reagentBaseCount = 7;
  const reagentBaseHeight = 400;
  const reagentPerPixel = 10;
  const rightColumnHeight =
    reagentBaseHeight +
    Math.max(0, reagents.length - reagentBaseCount) * reagentPerPixel;

  // Height calculation for the left column (recipes)
  const recipeBaseCount = 4;
  const recipeBaseHeight = 400;
  const recipePerPixel = 44;
  const leftColumnHeight =
    recipeBaseHeight +
    Math.max(0, Object.keys(saved_recipes).length - recipeBaseCount) *
      recipePerPixel;

  // Total window height = maximum of two columns, but not less than 400 and not more than 800
  const dynamicHeight = Math.min(
    800,
    Math.max(400, Math.max(leftColumnHeight, rightColumnHeight)),
  );

  return (
    <Window width={560} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <BorgHypoSettings
                  selectedAmount={amount}
                  availableAmounts={transferAmounts}
                  minAmount={minTransferVolume}
                  maxAmount={maxTransferVolume}
                  amountAct={(amt) => act('set_amount', { amount: amt })}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Stack vertical fill>
                  <Stack.Item basis="60%">
                    <BorgHypoRecipes
                      recipes={saved_recipes}
                      recordingRecipe={recordingRecipe}
                      recordAct={() => act('record_recipe')}
                      cancelAct={() => act('cancel_recording')}
                      saveAct={() => act('save_recording')}
                      dispenseActLeft={(recipe) =>
                        act('select_recipe_left', { recipe })
                      }
                      dispenseActRight={(recipe) =>
                        act('select_recipe_right', { recipe })
                      }
                      removeAct={(recipe) => act('remove_recipe', { recipe })}
                      getDispenseButtonSelectedLeft={(recipe) =>
                        selectedRecipeIdLeft === recipe
                      }
                      getDispenseButtonSelectedRight={(recipe) =>
                        selectedRecipeIdRight === recipe
                      }
                    />
                  </Stack.Item>
                  <Stack.Item basis="40%">
                    <BorgHypoRecipeDisplay />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={1.25}>
            <BorgHypoChemicals
              sectionTitle={'Chemicals'}
              maximumChemicalVolume={maxReagentVolume}
              chemicals={reagents}
              dispenseActLeft={(reagentId) => {
                act('select_reagent_left', { reagent_id: reagentId });
              }}
              dispenseActRight={(reagentId) => {
                act('select_reagent_right', { reagent_id: reagentId });
              }}
              chemicalButtonSelectLeft={(reagentId) =>
                selectedReagentLeft === reagentId
              }
              chemicalButtonSelectRight={(reagentId) =>
                selectedReagentRight === reagentId
              }
              offerReagentSearch={true}
              disableReagentSearch={!canReagentSearch}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * The hypospray settings component.
 * Allows you to select the injection volume as from preset buttons,
 * and through the slider for an arbitrary value.
 */
export const BorgHypoSettings = (props: {
  selectedAmount: number;
  availableAmounts: number[];
  minAmount: number;
  maxAmount: number;
  amountAct: (amount: number) => void;
}) => {
  const { selectedAmount, availableAmounts, minAmount, maxAmount, amountAct } =
    props;
  return (
    <Section title="Settings" fill>
      <LabeledList>
        <LabeledList.Item label="Dispense" verticalAlign="middle">
          <Stack g={0.1}>
            {availableAmounts.map((a, i) => (
              <Stack.Item key={i}>
                <Button
                  textAlign="center"
                  selected={selectedAmount === a}
                  m="0"
                  onClick={() => amountAct(a)}
                >
                  {`${a}u`}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Custom">
          <Slider
            step={1}
            stepPixelSize={30}
            value={selectedAmount}
            minValue={minAmount}
            maxValue={maxAmount}
            onChange={(_, value) => amountAct(value)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

/**
 * Recipe management component (chem cocktails).
 * Allows you to record, save, select (LMB/RMB) and delete recipes.
 */
export const BorgHypoRecipes = (props: {
  recipes: Record<string, Record<string, number>>;
  recordingRecipe: string[];
  recordAct: () => void;
  cancelAct: () => void;
  saveAct: () => void;
  dispenseActLeft: (recipe: string) => void;
  dispenseActRight: (recipe: string) => void;
  removeAct: (recipe: string) => void;
  getDispenseButtonSelectedLeft?: (recipe: string) => BooleanLike;
  getDispenseButtonSelectedRight?: (recipe: string) => BooleanLike;
}) => {
  const {
    recipes,
    recordingRecipe,
    recordAct,
    cancelAct,
    saveAct,
    dispenseActLeft,
    dispenseActRight,
    removeAct,
    getDispenseButtonSelectedLeft,
    getDispenseButtonSelectedRight,
  } = props;

  const isRecording: boolean = !!recordingRecipe;
  const recipeData = Object.keys(recipes).sort();

  // Formatting the composition of a recipe for a tooltip
  const formatRecipeTooltip = (recipeContents: Record<string, number>) => {
    return (
      <div>
        {Object.entries(recipeContents).map(([reagentName, volume], index) => (
          <div key={index}>
            {volume}u of {reagentName}
          </div>
        ))}
      </div>
    );
  };

  return (
    <Section
      title="Recipes"
      fill
      scrollable
      buttons={
        <Stack>
          {!isRecording && (
            <Stack.Item>
              <Button icon="circle" onClick={recordAct}>
                Record
              </Button>
            </Stack.Item>
          )}
          {isRecording && (
            <Stack.Item>
              <Button icon="ban" color="bad" onClick={cancelAct}>
                Discard
              </Button>
            </Stack.Item>
          )}
          {isRecording && (
            <Stack.Item>
              <Button icon="save" color="green" onClick={saveAct}>
                Save
              </Button>
            </Stack.Item>
          )}
        </Stack>
      }
    >
      {recipeData.length
        ? recipeData.map((recipe) => {
            const recipeContents = recipes[recipe];
            const tooltipContent = formatRecipeTooltip(recipeContents);

            return (
              <Stack key={recipe} m={0.5}>
                {/* Left mouse button (LMB)*/}
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="flask"
                    color={
                      getDispenseButtonSelectedLeft?.(recipe)
                        ? 'green'
                        : 'default'
                    }
                    onClick={() => dispenseActLeft(recipe)}
                    tooltip={tooltipContent}
                    tooltipPosition="bottom-start"
                  >
                    {recipe} (LMB)
                  </Button>
                </Stack.Item>

                {/* Right mouse button (RMB)*/}
                <Stack.Item>
                  <Button
                    fluid
                    color={
                      getDispenseButtonSelectedRight?.(recipe)
                        ? 'orange'
                        : 'default'
                    }
                    onClick={() => dispenseActRight(recipe)}
                    tooltip={tooltipContent}
                    tooltipPosition="bottom-start"
                  >
                    RMB
                  </Button>
                </Stack.Item>

                {/* Recipe deletion button */}
                <Stack.Item>
                  <Button.Confirm
                    icon="trash"
                    confirmIcon="triangle-exclamation"
                    confirmContent={''}
                    color="bad"
                    onClick={() => removeAct(recipe)}
                  />
                </Stack.Item>
              </Stack>
            );
          })
        : ''}
    </Section>
  );
};

/**
 * The component for displaying the currently recorded recipe.
 * Shows a list of reagents and their volumes added to the recipe.
 */
export const BorgHypoRecipeDisplay = () => {
  const { data } = useBackend<GeneralContext>();
  const { recordingRecipe } = data;

  const isRecording = !!recordingRecipe;
  const recordedContents =
    isRecording &&
    Object.keys(recordingRecipe).map((id) => ({
      id,
      volume: recordingRecipe[id],
    }));

  return (
    <Section title="Recipe Creation" fill scrollable>
      {isRecording && (
        <Stack align="start" justify="space-between" direction="column">
          {recordedContents.map((reagent, i) => (
            <Stack.Item key={i} color="label">
              {reagent.volume}u of {reagent.id}
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

/**
 * A component for displaying a list of available chemicals.
 * Each reagent has two selection buttons: for the left (LMB) and right (RMB) mouse buttons.
 * It also supports the search for reagents through an external container.
 */
export const BorgHypoChemicals = (props: {
  sectionTitle: string;
  maximumChemicalVolume: number;
  chemicals: Reagent[];
  dispenseActLeft: (reagentId: string) => void;
  dispenseActRight: (reagentId: string) => void;
  chemicalButtonSelectLeft?: (reagentId: string) => BooleanLike;
  chemicalButtonSelectRight?: (reagentId: string) => BooleanLike;
  offerReagentSearch?: boolean;
  disableReagentSearch?: boolean;
}) => {
  const { act } = useBackend();
  const {
    chemicals,
    maximumChemicalVolume,
    sectionTitle,
    dispenseActLeft,
    dispenseActRight,
    chemicalButtonSelectLeft,
    chemicalButtonSelectRight,
    offerReagentSearch,
    disableReagentSearch,
  } = props;

  return (
    <Section
      title={sectionTitle}
      fill
      scrollable
      buttons={
        offerReagentSearch
          ? [
              <Button
                key="reaction_lookup"
                icon="book"
                content="Reaction Search"
                tooltip="Look up recipes and reagents!"
                tooltipPosition="bottom-start"
                disabled={disableReagentSearch}
                onClick={() => act('reaction_lookup')}
              />,
            ]
          : []
      }
    >
      {chemicals.map((reagent) => (
        <Flex key={reagent.id} m={0.5}>
          <Flex.Item grow mr={1}>
            <ProgressBar value={reagent.volume / maximumChemicalVolume}>
              <Flex>
                <Flex.Item grow textAlign={'left'}>
                  <Tooltip
                    content={
                      <Box backgroundColor="#1a1a1a" p={1}>
                        <Box color="green" bold>
                          {reagent.full_name}
                        </Box>
                        <Box color="label" mt={0.5}>
                          {reagent.description}
                        </Box>
                      </Box>
                    }
                    position="bottom-start"
                  >
                    <span style={{ cursor: 'help' }}>
                      <i
                        className="fas fa-syringe"
                        style={{ marginRight: '6px' }}
                      />
                      {reagent.name}
                    </span>
                  </Tooltip>
                </Flex.Item>
                <Flex.Item>{`${reagent.volume}u`}</Flex.Item>
              </Flex>
            </ProgressBar>
          </Flex.Item>

          <Flex.Item textAlign={'right'} mr={0.5}>
            <Button
              content={'LMB'}
              textAlign={'center'}
              color={
                chemicalButtonSelectLeft?.(reagent.id) ? 'green' : 'default'
              }
              onClick={() => dispenseActLeft(reagent.id)}
              tooltip="Select for left mouse button"
            />
          </Flex.Item>

          <Flex.Item textAlign={'right'}>
            <Button
              content={'RMB'}
              textAlign={'center'}
              color={
                chemicalButtonSelectRight?.(reagent.id) ? 'orange' : 'default'
              }
              onClick={() => dispenseActRight(reagent.id)}
              tooltip="Select for right mouse button"
            />
          </Flex.Item>
        </Flex>
      ))}
    </Section>
  );
};
