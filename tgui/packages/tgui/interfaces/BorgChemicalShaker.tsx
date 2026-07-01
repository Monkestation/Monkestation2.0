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
  selectedReagentLeft?: string;
  selectedReagentRight?: string;
  saved_recipes: Record<string, Record<string, number>>;
  selectedRecipeIdLeft?: string;
  selectedRecipeIdRight?: string;
  recording: boolean;
  recordingRecipe: string[];
  canReagentSearch: boolean;
};

export const BorgChemicalShaker = () => {
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
    reagents_alc,
    reagents_nonalc,
    selectedReagentLeft,
    selectedReagentRight,
    selectedRecipeIdLeft,
    selectedRecipeIdRight,
    canReagentSearch,
  } = data;

  return (
    <Window width={1000} height={610} theme={theme}>
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
          <Stack.Item grow={2}>
            <Stack fill>
              <Stack.Item basis="50%">
                <BorgHypoChemicals
                  sectionTitle={'Alcoholic'}
                  maximumChemicalVolume={maxReagentVolume}
                  chemicals={reagents_alc}
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
                />
              </Stack.Item>
              <Stack.Item basis="50%">
                <BorgHypoChemicals
                  sectionTitle={'Non-Alcoholic'}
                  maximumChemicalVolume={maxReagentVolume}
                  chemicals={reagents_nonalc}
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
