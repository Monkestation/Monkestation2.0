import { useBackend } from '../backend';
import { Stack } from '../components';
import type { Reagent } from '../interfaces/BorgChemicalDispenser';

import {
  BorgHypoChemicals,
  BorgHypoRecipeDisplay,
  BorgHypoRecipes,
  BorgHypoSettings,
} from '../interfaces/BorgChemicalDispenser';
import { Window } from '../layouts';

type GeneralContext = {
  theme: string;
  amount: number;
  transferAmounts: number[];
  minTransferVolume: number;
  maxTransferVolume: number;
  maxReagentVolume: number;
  reagents_alc: Reagent[];
  reagents_nonalc: Reagent[];
  selectedReagent?: string;
  saved_recipes: Record<string, number>;
  selectedRecipeId?: string;
  recording: boolean;
  recordingRecipe: string[];
};

export const BorgChemicalCondiments = () => {
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
          <Stack.Item grow={1.25}>
            <BorgHypoChemicals
              sectionTitle={'Condiments'}
              maximumChemicalVolume={maxReagentVolume}
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
