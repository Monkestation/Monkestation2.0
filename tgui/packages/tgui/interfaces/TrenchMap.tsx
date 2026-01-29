import type { BooleanLike } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Flex, Image } from '../components';
import { Window } from '../layouts';

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
      <Image src={resolveAsset(map_image)} />
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
              backgroundColor: '#0000FF',
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
              backgroundColor: '#00FF95',
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
              backgroundColor: '#FF0000',
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
              backgroundColor: '#FF7878',
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
              backgroundColor: '#008800',
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
              backgroundColor: '#49A0C2',
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
            marginLeft: `-${hotspot.radius * 2}px`,
            marginBottom: `-${hotspot.radius * 2}px`,
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
    return null;
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
          marginLeft: `-${RADIUS * 2}px`,
          marginBottom: `-${RADIUS * 2}px`,
          position: 'absolute',
        }}
      />
    </Box>
  );
};
