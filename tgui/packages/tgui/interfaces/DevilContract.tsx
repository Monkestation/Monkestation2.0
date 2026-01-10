// THIS IS A MONKESTATION UI FILE
import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

type Data = {
  points: number;
  clauses: Clauses[];
};

type Clauses = {
  name: string;
  desc: string;
  disabled: BooleanLike;
  color: string;
  ref: string;
};

export const DevilContract = (props) => {
  const { data, act } = useBackend<Data>();
  const { clauses, points } = data;
  return (
    <Window width={475} height={400} theme="wizard">
      <Window.Content>
        <Box>
          Current point balance: {points} <br />
          - Currently selected clauses are highlighted in green, whilst
          unselected ones are red
          <br />
          - The contract requires to have negative or 0 points at all times.
          <br />
          - You can hover over clauses to get the general idea of what they do.
          <br />
          (The UI is made in a way that makes you love all other UI interfaces
          better)
          <br /> <br />
          {clauses.map((clause, index) => (
            <Button
              key={index}
              color={clause.color}
              children={clause.name}
              disabled={clause.disabled}
              tooltip={clause.desc}
              onClick={() =>
                act('no_action', { clause: clause.ref, color: clause.color })
              }
            />
          ))}
        </Box>
      </Window.Content>
    </Window>
  );
};
