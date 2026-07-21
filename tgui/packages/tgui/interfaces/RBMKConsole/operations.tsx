import { Box, Flex } from '../../components';
import { RBMKControls } from './controls';
import { RBMKOverview } from './overview';

export const RBMKOperations = () => (
  <Box className="RBMKConsole__Operations">
    <Flex gap={1} align="flex-start">
      <Flex.Item basis="56%" grow>
        <RBMKOverview />
      </Flex.Item>
      <Flex.Item basis="44%" grow>
        <RBMKControls />
      </Flex.Item>
    </Flex>
  </Box>
);

export default RBMKOperations;
