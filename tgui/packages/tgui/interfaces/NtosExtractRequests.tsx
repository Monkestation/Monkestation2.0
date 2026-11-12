import { Box } from 'tgui-core/components';

import { NtosWindow } from '../layouts';
import { ExtractRequestsBody } from './ExtractRequests';

export const NtosExtractRequests = () => (
  <NtosWindow width={780} height={640}>
    <NtosWindow.Content>
      {/* NtosWindow forces the PDA's own theme, and every --slime-* var lives under this one */}
      <Box className="theme-slime_rancher ExtractRequests ExtractRequests__ntos">
        <ExtractRequestsBody canPickUp={false} />
      </Box>
    </NtosWindow.Content>
  </NtosWindow>
);
