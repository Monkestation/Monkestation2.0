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
  theme: string;
  amount: number;
  transferAmounts: number[];
  minTransferVolume: number;
  maxTransferVolume: number;
  maxReagentVolume: number;
  reagents: Reagent[];
  selectedReagent?: string;
  saved_recipes: Record<string, number>;
  selectedRecipeId?: string;
  recording: boolean;
  recordingRecipe: string[];
  canReagentSearch: boolean;
};

export type Reagent = {
  name: string;
  volume: number;
  description: string;
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
    canReagentSearch,
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
                  <Stack.Item basis="60%">
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
                  <Stack.Item basis="40%">
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
              dispenseAct={(reagentName) => {
                act('select_reagent', {
                  reagent_name: reagentName,
                });
              }}
              chemicalButtonSelect={(reagentName) =>
                selectedReagent === reagentName
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

export const BorgHypoRecipes = (props: {
  /** Associated list of saved recipe macros. */
  recipes: Record<string, number>;
  /** The current recipe macro that's being recorded, if any. We assume we aren't recording a recipe if this is undefined! */
  recordingRecipe: string[];
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

export const BorgHypoChemicals = (props: {
  /** The title of the section. */
  sectionTitle: string;
  /** All reagents that should be given a dispense button.  */
  chemicals: Reagent[];
  /** Called when the user clicks on a reagent dispense button. Arg is the name of the button's reagent. */
  dispenseAct: (reagentName: string) => void;
  /** Optional callback that returns whether or not a reagent dispense button will appear "activated". Arg is the name of the button's reagent. */
  chemicalButtonSelect?: (reagentName: string) => BooleanLike;
  /** Optional boolean that gives a button to perform Reagent Search. */
  offerReagentSearch?: boolean;
  /** Optional boolean that disables Reagent Search from being clicked on. */
  disableReagentSearch?: boolean;
}) => {
  const { act } = useBackend();
  const {
    chemicals,
    sectionTitle,
    dispenseAct,
    chemicalButtonSelect,
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
                  ? chemicalButtonSelect(reagent.name)
                  : false
              }
              onClick={() => dispenseAct(reagent.name)}
            />
          </Flex.Item>
        </Flex>
      ))}
    </Section>
  );
};
