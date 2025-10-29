import { useBackend } from 'tgui/backend';
import {
  Button,
  Collapsible,
  LabeledList,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

type BattleRoyalePanelContext = {
  active_dataset: royaledataset[];
  prizes: prizelist[];
  max_duration: string;
  custom_datasets: royaledataset[];
  storm_delay?: string;
};

type prizelist = {
  coins: number;
  high_tokens: number;
  medium_tokens: number;
  low_tokens: number;
};

type royaledataset = {
  active_time?: number;
  common_weight: number;
  utility_weight: number;
  rare_weight: number;
  super_rare_weight: number;
  misc_weight: number;
  extra_loot_prob: number;
  rare_drop_prob: number;
  super_drop_prob: number;
  pods_per_second: number;
  converted_time?: string;
};

export const BattleRoyalePanel = (props) => {
  const { act, data } = useBackend<BattleRoyalePanelContext>();
  const active_dataset = data.active_dataset || [];
  const prizes = data.prizes;
  const custom_datasets = data.custom_datasets || [];
  return (
    <Window title="Battle Royale Panel" width={700} height={525}>
      <Window.Content scrollable>
        <Button content="Start Battle Royale" onClick={() => act('start')} />
        <Button
          content="Adjust storm delay"
          onClick={() => act('adjust_storm_delay')}
        />
        Expected maximum duration: {'[' + data.max_duration + ']   '}
        Storm delay:{' '}
        {data.storm_delay ? '[' + data.storm_delay + ']' : '[Unset]'}
        <Section title="Currently active data">
          {active_dataset.length
            ? active_dataset.map((royaledataset) => (
                <LabeledList key={royaledataset.active_time}>
                  <div>
                    <LabeledList.Item label="Active Time">
                      {royaledataset.active_time}
                    </LabeledList.Item>
                    <LabeledList.Item label="Common Weight">
                      {royaledataset.common_weight}
                    </LabeledList.Item>
                    <LabeledList.Item label="Utility Weight">
                      {royaledataset.utility_weight}
                    </LabeledList.Item>
                    <LabeledList.Item label="Rare Weight">
                      {royaledataset.rare_weight}
                    </LabeledList.Item>
                    <LabeledList.Item label="Super Rare Weight">
                      {royaledataset.super_rare_weight}
                    </LabeledList.Item>
                    <LabeledList.Item label="Misc Weight">
                      {royaledataset.misc_weight}
                    </LabeledList.Item>
                    <LabeledList.Item label="Extra Loot Prob">
                      {royaledataset.extra_loot_prob}
                    </LabeledList.Item>
                    <LabeledList.Item label="Rare Drop Prob">
                      {royaledataset.rare_drop_prob}
                    </LabeledList.Item>
                    <LabeledList.Item label="Super Drop Prob">
                      {royaledataset.super_drop_prob}
                    </LabeledList.Item>
                    <LabeledList.Item label="Pods Per Second">
                      {royaledataset.pods_per_second}
                    </LabeledList.Item>
                  </div>
                </LabeledList>
              ))
            : 'None'}
        </Section>
        <Section
          title="Prizes"
          buttons={
            <Button
              content="Adjust prizes"
              onClick={() => act('adjust_prizes')}
            />
          }
        >
          {prizes.map((prizelist) => (
            <LabeledList key={prizelist.coins}>
              <div>
                <LabeledList.Item label="Coins">
                  {prizelist.coins}
                </LabeledList.Item>
                <LabeledList.Item label="High level tokens">
                  {prizelist.high_tokens}
                </LabeledList.Item>
                <LabeledList.Item label="Medium level tokens">
                  {prizelist.medium_tokens}
                </LabeledList.Item>
                <LabeledList.Item label="Low level tokens">
                  {prizelist.low_tokens}
                </LabeledList.Item>
              </div>
            </LabeledList>
          ))}
        </Section>
        <Section
          title="Custom datasets"
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  content="Add dataset"
                  onClick={() => act('add_custom_dataset')}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  content="Remove dataset"
                  onClick={() => act('remove_custom_dataset')}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  content="Adjust dataset"
                  onClick={() => act('adjust_custom_dataset')}
                />
              </Stack.Item>
            </Stack>
          }
        >
          {custom_datasets.length
            ? custom_datasets.map((royaledataset) => (
                <Collapsible
                  title={royaledataset.converted_time}
                  key={royaledataset.active_time}
                >
                  <LabeledList>
                    <div>
                      <LabeledList.Item label="Active Time">
                        {royaledataset.active_time}
                      </LabeledList.Item>
                      <LabeledList.Item label="Common Weight">
                        {royaledataset.common_weight}
                      </LabeledList.Item>
                      <LabeledList.Item label="Utility Weight">
                        {royaledataset.utility_weight}
                      </LabeledList.Item>
                      <LabeledList.Item label="Rare Weight">
                        {royaledataset.rare_weight}
                      </LabeledList.Item>
                      <LabeledList.Item label="Super Rare Weight">
                        {royaledataset.super_rare_weight}
                      </LabeledList.Item>
                      <LabeledList.Item label="Misc Weight">
                        {royaledataset.misc_weight}
                      </LabeledList.Item>
                      <LabeledList.Item label="Extra Loot Prob">
                        {royaledataset.extra_loot_prob}
                      </LabeledList.Item>
                      <LabeledList.Item label="Rare Drop Prob">
                        {royaledataset.rare_drop_prob}
                      </LabeledList.Item>
                      <LabeledList.Item label="Super Drop Prob">
                        {royaledataset.super_drop_prob}
                      </LabeledList.Item>
                      <LabeledList.Item label="Pods Per Second">
                        {royaledataset.pods_per_second}
                      </LabeledList.Item>
                    </div>
                  </LabeledList>
                </Collapsible>
              ))
            : 'None'}
        </Section>
      </Window.Content>
    </Window>
  );
};
