import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Button,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

type GeneralContext = {
  theme: string; // Theme of the UI.
  amount: number; // The selected amount of reagents we transfer at a time.
  transferAmounts: number[]; // All transfer amounts.
  minTransferVolume: number; // Minimum transfer volume.
  maxTransferVolume: number; // Maximum transfer volume.
  maxReagentVolume: number; // Max volume for each reagent.
  reagents: Reagent[]; // Information for each reagent.
  selectedReagent?: string; // Our selected reagent typepath, if we ever selected one.
  saved_recipes: Record<string, Recipe[]>;
  selectedRecipeId?: string; // Our selected recipe ID, if we ever selected one.
  recording: boolean;
  recordingRecipe: Recipe[];
};

export type Reagent = {
  typepath: string;
  name: string;
  volume: number;
  description: string;
};

export type Recipe = {
  typepath: string;
  name: string;
  volume: number;
};

export const BorgChemicalDispenser = () => {
  const { act, data } = useBackend<GeneralContext>();
  const {
    theme,
    amount,
    transferAmounts,
    minTransferVolume,
    maxTransferVolume,
    saved_recipes,
    recordingRecipe,
    reagents,
    selectedReagent,
    selectedRecipeId,
  } = data;

  return (
    <Window width={680} height={610} theme={theme}>
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
                  <Stack.Item basis="70%">
                    <BorgHypoRecipes
                      recipes={saved_recipes}
                      recordingRecipe={recordingRecipe}
                      recordAct={() => act('record_recipe')}
                      cancelAct={() => act('cancel_recording')}
                      saveAct={() => act('save_recording')}
                      dispenseAct={(recipe) => act('select_recipe', { recipe })}
                      removeAct={(recipe) => act('remove_recipe', { recipe })}
                      getDispenseButtonSelected={(recipe) => {
                        return selectedRecipeId === recipe;
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item basis="30%">
                    <BorgHypoRecipeDisplay />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={2}>
            <BorgHypoChemicals
              sectionTitle={'Chemicals'}
              chemicals={reagents}
              dispenseAct={(reagentTypepath) => {
                act('select_reagent', {
                  typepath: reagentTypepath,
                });
              }}
              chemicalButtonSelect={(reagentTypepath) =>
                selectedReagent === reagentTypepath
              }
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const BorgHypoSettings = (props: {
  /** The dispense amount the user has currently selected. */
  selectedAmount: number;
  /** Available amounts for this dispenser to use. */
  availableAmounts: number[];
  /** The minimum allowed selectable amount. Used for the slider UI element. */
  minAmount: number;
  /** The maximum allowed selectable amount. Used for the slider UI element. */
  maxAmount: number;
  /** Called when the user tries to change the dispensed amount. Arg is the amount the user is trying to set it to. */
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
        <LabeledList.Item label="Custom Amount">
          <Slider
            step={1}
            stepPixelSize={75}
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

export const BorgHypoRecipes = (props: {
  /** Associated list of saved recipe macros. */
  recipes: Record<string, Recipe[]>;
  /** The current recipe macro that's being recorded, if any. We assume we aren't recording a recipe if this is undefined! */
  recordingRecipe: Recipe[];
  /** Called when the user attempts to start a recipe recording. */
  recordAct: () => void;
  /** Called when the user attempts to cancel a recipe recording. */
  cancelAct: () => void;
  /** Called when the user attempts to save a recipe recording. */
  saveAct: () => void;
  /** Called when the user attempts to use a recipe macro. */
  dispenseAct: (recipe: string) => void;
  /** Called when a recipe dispense button is checking whether or not it will appear "selected". Arg is the ID of the button's reagent. Defaults to false if undefined. */
  getDispenseButtonSelected?: (recipe: string) => BooleanLike;
  /** Called when the user attempts to remove a recipe macro. */
  removeAct: (recipe: string) => void;
}) => {
  const {
    recipes,
    recordingRecipe,
    recordAct,
    cancelAct,
    saveAct,
    dispenseAct,
    getDispenseButtonSelected,
    removeAct,
  } = props;

  const isRecording: boolean = !!recordingRecipe;
  const recipeData = Object.keys(recipes).sort();

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
        ? recipeData.map((recipe) => (
            <Stack key={recipe}>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="flask"
                  selected={
                    getDispenseButtonSelected
                      ? getDispenseButtonSelected(recipe)
                      : undefined
                  }
                  onClick={() => dispenseAct(recipe)}
                >
                  {recipe}
                </Button>
              </Stack.Item>
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
          ))
        : ''}
    </Section>
  );
};

export const BorgHypoRecipeDisplay = () => {
  const { data } = useBackend<GeneralContext>();
  const { recordingRecipe } = data;

  const recording = !!recordingRecipe;

  const recordedContents =
    recording &&
    recordingRecipe.map((recipe) => ({
      typepath: recipe.typepath,
      name: recipe.name,
      volume: recipe.volume,
    }));

  return (
    <Section title="Recipe Creation" fill scrollable>
      {recording && (
        <Stack align="start" justify="space-between" direction="column">
          {recordedContents.map((reagent, i) => (
            <Stack.Item key={i} color="label">
              {reagent.volume}u of {reagent.name}
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

export const BorgHypoChemicals = (props: {
  /** The title of the section. */
  sectionTitle: string;
  /** All reagents that should be given a dispense button.  */
  chemicals: Reagent[];
  /** Called when the user clicks on a reagent dispense button. Arg is the ID of the button's reagent. */
  dispenseAct: (reagentId: string) => void;
  /** Optional callback that returns whether or not a reagent dispense button will appear "activated". Arg is the ID of the button's reagent. */
  chemicalButtonSelect?: (reagentId: string) => BooleanLike;
}) => {
  const { chemicals, sectionTitle, dispenseAct, chemicalButtonSelect } = props;
  return (
    <Section title={sectionTitle} fill scrollable>
      {chemicals.map((reagent) => (
        <Flex key={reagent.name} m={0.5}>
          <Flex.Item grow>
            <ProgressBar value={reagent.volume / 30}>
              <Flex>
                <Flex.Item grow textAlign={'left'}>
                  {reagent.name}
                </Flex.Item>
                <Flex.Item>{`${reagent.volume}u`}</Flex.Item>
              </Flex>
            </ProgressBar>
          </Flex.Item>
          <Flex.Item mx={1}>
            <Button
              icon={'info-circle'}
              textAlign={'center'}
              tooltip={reagent.description}
            />
          </Flex.Item>
          <Flex.Item textAlign={'right'}>
            <Button
              icon={'syringe'}
              content={'Select'}
              textAlign={'center'}
              selected={
                chemicalButtonSelect
                  ? chemicalButtonSelect(reagent.typepath)
                  : false
              }
              onClick={() => dispenseAct(reagent.typepath)}
            />
          </Flex.Item>
        </Flex>
      ))}
    </Section>
  );
};
