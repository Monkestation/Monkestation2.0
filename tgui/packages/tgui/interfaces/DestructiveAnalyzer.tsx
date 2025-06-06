import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Box, Section, NoticeBox, DmIcon } from '../components';
import { Window } from '../layouts';

type Data = {
  server_connected: BooleanLike;
  loaded_item: string;
  item_icon: string;
  item_icon_state: string;
  indestructible: BooleanLike;
  already_deconstructed: BooleanLike;
  recoverable_points: string;
  node_data: NodeData[];
  research_point_id: string;
};

type NodeData = {
  node_name: string;
  node_id: string;
  node_hidden: BooleanLike;
};

export const DestructiveAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    server_connected,
    indestructible,
    loaded_item,
    item_icon,
    item_icon_state,
    already_deconstructed,
    recoverable_points,
    research_point_id,
    node_data = [],
  } = data;
  if (!server_connected) {
    return (
      <Window width={400} height={260} title="Destructive Analyzer">
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            Not connected to a server. Please sync one using a multitool.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  if (!loaded_item) {
    return (
      <Window width={400} height={260} title="Destructive Analyzer">
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            No item loaded! <br />
            Put any item inside to see what it&apos;s capable of!
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window
      width={400}
      height={260}
      scrollable
      fill
      title="Destructive Analyzer"
    >
      <Window.Content scrollable>
        <Section
          title={loaded_item}
          buttons={
            <Button
              icon="eject"
              tooltip="Ejects the item currently inside the machine."
              onClick={() => act('eject_item')}
            />
          }
        >
          <DmIcon
            icon={item_icon}
            icon_state={item_icon_state}
            width="64px"
            height="64px"
            verticalAlign="middle"
          />
        </Section>
        <Section title="Deconstruction Methods">
          {!indestructible && (
            <NoticeBox textAlign="center" danger>
              This item can&apos;t be deconstructed!
            </NoticeBox>
          )}
          {!!indestructible && (
            <>
              {!!recoverable_points && (
                <>
                  <Box fontSize="14px">Research points from deconstruction</Box>
                  <Box>{recoverable_points}</Box>
                </>
              )}
              <Button.Confirm
                content="Deconstruct"
                icon="hammer"
                tooltip={
                  already_deconstructed
                    ? 'This item item has already been deconstructed, and will not give any additional information.'
                    : 'Destroys the object currently residing in the machine.'
                }
                onClick={() =>
                  act('deconstruct', { deconstruct_id: research_point_id })
                }
              />
            </>
          )}
          {node_data.map((node) => (
            <Button.Confirm
              content={node.node_name}
              icon="cash-register"
              mt={1}
              disabled={!node.node_hidden}
              key={node.node_id}
              tooltip={
                node.node_hidden
                  ? 'Deconstructing this will allow you to research the node in question by making it visible to R&D consoles.'
                  : 'This node has already been researched, and does not need to be deconstructed.'
              }
              onClick={() =>
                act('deconstruct', { deconstruct_id: node.node_id })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
