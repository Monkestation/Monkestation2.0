import {
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
} from '../components';
import { BooleanLike } from 'common/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Data = {
  detail_view: string;
  disk: DiskData;
  has_disk: BooleanLike;
  has_program: BooleanLike;
  programs: ProgramData[];
  categories: string[];
};

type DiskData = {
  name: string;
  desc: string;
};

type ProgramData = {
  name: string;
  desc: string;
  id: string;
};

export const NaniteProgramHub = (props, context) => {
  const { act, data } = useBackend<Data>();
  const {
    detail_view,
    disk,
    has_disk,
    has_program,
    programs = [],
    categories,
  } = data;
  const [selectedCategory, setSelectedCategory] = useSharedState(
    context,
    'category',
  );
  const programsInCategory = (programs && programs[selectedCategory]) || [];

  return (
    <Window width={500} height={700}>
      <Window.Content scrollable>
        <Section
          title="Program Disk"
          buttons={
            <>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('eject')}
              />
              <Button
                icon="minus-circle"
                content="Delete Program"
                onClick={() => act('clear')}
              />
            </>
          }
        >
          {has_disk ? (
            has_program ? (
              <LabeledList>
                <LabeledList.Item label="Program Name">
                  {disk.name}
                </LabeledList.Item>
                <LabeledList.Item label="Description">
                  {disk.desc}
                </LabeledList.Item>
              </LabeledList>
            ) : (
              <NoticeBox>No Program Installed</NoticeBox>
            )
          ) : (
            <NoticeBox>Insert Disk</NoticeBox>
          )}
        </Section>
        <Section
          title="Programs"
          buttons={
            <>
              <Button
                icon={detail_view ? 'info' : 'list'}
                content={detail_view ? 'Detailed' : 'Compact'}
                onClick={() => act('toggle_details')}
              />
              <Button
                icon="sync"
                content="Sync Research"
                onClick={() => act('refresh')}
              />
            </>
          }
        >
          {programs === null ? (
            <NoticeBox>No nanite programs are currently researched.</NoticeBox>
          ) : (
            <Flex>
              <Flex.Item minWidth="110px">
                <Tabs vertical>
                  {categories.map((category) => (
                    <Tabs.Tab
                      key={category}
                      selected={category === selectedCategory}
                      onClick={() => {
                        setSelectedCategory(category);
                      }}
                    >
                      {category.substring(0, category.length - 8)}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Flex.Item>
              <Flex.Item grow={1} basis={0}>
                {detail_view ? (
                  programsInCategory.map((program) => (
                    <Section
                      key={program.id}
                      title={program.name}
                      buttons={
                        <Button
                          icon="download"
                          content="Download"
                          disabled={!has_disk}
                          onClick={() =>
                            act('download', {
                              program_id: program.id,
                            })
                          }
                        />
                      }
                    >
                      {program.desc}
                    </Section>
                  ))
                ) : (
                  <LabeledList>
                    {programsInCategory.map((program) => (
                      <LabeledList.Item
                        key={program.id}
                        label={program.name}
                        buttons={
                          <Button
                            icon="download"
                            content="Download"
                            disabled={!has_disk}
                            onClick={() =>
                              act('download', {
                                program_id: program.id,
                              })
                            }
                          />
                        }
                      />
                    ))}
                  </LabeledList>
                )}
              </Flex.Item>
            </Flex>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
