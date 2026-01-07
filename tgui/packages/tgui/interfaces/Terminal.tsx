import { useBackend } from '../backend';
import { Box, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  uppertext: string;
  messages: { key: string }[];
  tguitheme: string;
};

export const Terminal = (props) => {
  const { data } = useBackend<Data>();
  const { messages = [], uppertext } = data;

  return (
    <Window theme={data.tguitheme} title="Terminal" width={480} height={520}>
      <Window.Content scrollable>
        <NoticeBox textAlign="left">{uppertext}</NoticeBox>
        {messages.map((message) => {
          return (
            <Section key={message.key}>
              <Box dangerouslySetInnerHTML={{ __html: message }} />
            </Section>
          );
        })}
      </Window.Content>
    </Window>
  );
};
