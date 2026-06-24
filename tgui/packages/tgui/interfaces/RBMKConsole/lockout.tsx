// RBMKLockout.tsx
import { useBackend } from '../../backend';
import { Box, LabeledList } from '../../components';

const formatDeciseconds = (timeLeft: number) => {
  const totalSeconds = Math.max(Math.ceil(timeLeft / 10), 0);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;

  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};

export const RBMKLockout = () => {
  const { data } = useBackend<any>();

  const status = data?.supermatter_cascade_status || 'CONTROL LOCKOUT';
  const timeLeft = Number(data?.supermatter_cascade_time_left ?? 0);
  const finalCountdown = Boolean(data?.supermatter_cascade_final_countdown);

  return (
    <Box className="RBMKConsole__CascadeLockout">
      <Box className="RBMKConsole__CascadeLock">🔒</Box>

      <Box className="RBMKConsole__CascadeTitle">
        Syndicate Override Active
      </Box>

      <Box className="RBMKConsole__CascadeSubtitle">
        Supermatter Rod Cascade Control Lockout
      </Box>

      <Box
        className={
          finalCountdown
            ? 'RBMKConsole__CascadeTimer RBMKConsole__CascadeTimer--final'
            : 'RBMKConsole__CascadeTimer'
        }>
        {formatDeciseconds(timeLeft)}
      </Box>

      <Box className="RBMKConsole__CascadeStatus">{status}</Box>

      <Box className="RBMKConsole__CascadeInfo">
        <LabeledList>
          <LabeledList.Item label="Console">
            Remote reactor control disabled
          </LabeledList.Item>
          <LabeledList.Item label="Required Action">
            Manually remove the supermatter fuel rod
          </LabeledList.Item>
          <LabeledList.Item label="Recovery">
            Automatic SCRAM after successful rod removal
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Box>
  );
};

export default RBMKLockout;
