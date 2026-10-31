import { useState } from 'react';
import { Tabs } from 'tgui-core/components';

import { NtosWindow } from '../layouts';
import {
  SLIMEPEDIA_TABS,
  Slimepedia,
  SlimepediaPage,
  useSlimepediaData,
} from './Slimepedia';

export const NtosSlimepedia = () => {
  const data = useSlimepediaData();
  const [page, setPage] = useState(SlimepediaPage.Slimes);

  return (
    <NtosWindow width={780} height={640}>
      <NtosWindow.Content>
        {/* NtosWindow forces the PDA's own theme, and every --slime-* var lives under this one */}
        <div className="theme-slime_rancher Slimepedia__root">
          <Tabs className="SlimeRancher__tabs">
            {SLIMEPEDIA_TABS.map((tab) => (
              <Tabs.Tab
                key={tab.page}
                icon={tab.icon}
                selected={page === tab.page}
                onClick={() => setPage(tab.page)}
              >
                {tab.label}
              </Tabs.Tab>
            ))}
          </Tabs>
          <Slimepedia data={data} page={page} onPageChange={setPage} />
        </div>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
