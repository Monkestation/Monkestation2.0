import { Window } from '../layouts';
import { MalfAiModules } from './common/MalfAiModules';

export const MalfunctionModulePicker = (props) => {
  return (
    <Window width={620} height={525} theme="malfunction">
      <Window.Content>
        <MalfAiModules />
      </Window.Content>
    </Window>
  );
};
