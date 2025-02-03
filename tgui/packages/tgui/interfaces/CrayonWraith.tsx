import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  drawables: Drawable[];
  selected_stencil: string;
  text_buffer: string;
};

type Drawable = {
  items: { item: string }[];
  name: string;
};

export const CrayonWraith = (props) => {
  const { act, data } = useBackend<Data>();
  const { drawables = [], selected_stencil, text_buffer } = data;
  return (
    <Window width={600} height={600}>
      <Window.Content scrollable>
        <Section title="Stencil">
          <LabeledList>
            {drawables.map((drawable) => {
              const items = drawable.items || [];
              return (
                <LabeledList.Item key={drawable.name} label={drawable.name}>
                  {items.map((item) => (
                    <Button
                      key={item.item}
                      content={item.item}
                      selected={item.item === selected_stencil}
                      onClick={() =>
                        act('select_stencil', {
                          item: item.item,
                        })
                      }
                    />
                  ))}
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
        <Section title="Text">
          <LabeledList>
            <LabeledList.Item label="Current Buffer">
              {text_buffer}
            </LabeledList.Item>
          </LabeledList>
          <Button content="New Text" onClick={() => act('enter_text')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
