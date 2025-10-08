import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Flex, Box } from '../components';
import { resolveAsset } from '../assets';
import { BooleanLike } from 'common/react';

type Hotspot = {
  center_y: number;
  center_x: number;
  radius: number;
  locked: BooleanLike;
};

type Data = {
  hotspots: Hotspot[];
  map_image: string;
  x?: number;
  y?: number;
};

export const TrenchMap = (_props) => {
  const { data } = useBackend<Data>();
  const { map_image } = data;
  return (
    <Window width={510} height={600}>
      <HotspotRender />
      <YouAreHere />
      <Box as="img" src={resolveAsset(map_image)} />
      <MapInfo />
    </Window>
  );
};
// TODO: Create a seperate style sheet for the MapInfo
const MapInfo = (_props) => {
  const { data } = useBackend<Data>();
  return (
    <Flex mt={1} align="center" justify="space-between">
      <Flex.Item ml={1}>
        <div>
          <div
            style={{
              float: 'left',
              height: '15px',
              width: '15px',
              clear: 'both',
              border: '1px solid black',
              'background-color': '#0000FF',
            }}
          />
          Trench Wall
        </div>
      </Flex.Item>
      <Flex.Item ml={1}>
        <div>
          <div
            style={{
              float: 'left',
              height: '15px',
              width: '15px',
              clear: 'both',
              border: '1px solid black',
              'background-color': '#00FF95',
            }}
          />
          Station
        </div>
      </Flex.Item>
      <Flex.Item ml={1}>
        <div>
          <div
            style={{
              float: 'left',
              height: '15px',
              width: '15px',
              clear: 'both',
              border: '1px solid black',
              'background-color': '#FF0000',
            }}
          />
          Locked Hotspot
        </div>
      </Flex.Item>
      <Flex.Item ml={1}>
        <div>
          <div
            style={{
              float: 'left',
              height: '15px',
              width: '15px',
              clear: 'both',
              border: '1px solid black',
              'background-color': '#FF7878',
            }}
          />
          Moving Hotspot
        </div>
      </Flex.Item>
      <Flex.Item ml={1}>
        <div>
          <div
            style={{
              float: 'left',
              height: '15px',
              width: '15px',
              clear: 'both',
              border: '1px solid black',
              'background-color': '#008800',
            }}
          />
          You Are Here
        </div>
      </Flex.Item>
      <Flex.Item ml={1}>
        <div>
          <div
            style={{
              float: 'left',
              height: '15px',
              width: '15px',
              clear: 'both',
              border: '1px solid black',
              'background-color': '#49A0C2',
            }}
          />
          Other
        </div>
      </Flex.Item>
    </Flex>
  );
};

const HotspotRender = (_props) => {
  const { data } = useBackend<Data>();
  const { hotspots = [] } = data;

  return (
    <Box>
      {hotspots.map((hotspot) => (
        <div
          key={hotspot.center_y + hotspot.center_x}
          style={{
            bottom: `${hotspot.center_y * 2 + 60}px`,
            left: `${hotspot.center_x * 2}px`,
            width: `${hotspot.radius * 4 + 2}px`,
            height: `${hotspot.radius * 4 + 2}px`,
            background: `${
              hotspot.locked
                ? 'rgba(255, 120, 120, 0.6)'
                : 'rgba(255, 0, 0, 0.8)'
            }`,
            'margin-left': `-${hotspot.radius * 2}px`,
            'margin-bottom': `-${hotspot.radius * 2}px`,
            position: 'absolute',
          }}
        />
      ))}
    </Box>
  );
};

const YouAreHere = (_props) => {
  const {
    data: { x, y },
  } = useBackend<Data>();

  if (!x || !y) {
    return;
  }

  const RADIUS = 1;

  return (
    <Box>
      <div
        style={{
          bottom: `${y * 2 + 60}px`,
          left: `${x * 2}px`,
          width: `${RADIUS * 4 + 2}px`,
          height: `${RADIUS * 4 + 2}px`,
          background: 'rgb(0, 136, 0)',
          'margin-left': `-${RADIUS * 2}px`,
          'margin-bottom': `-${RADIUS * 2}px`,
          position: 'absolute',
        }}
      />
    </Box>
  );
};
