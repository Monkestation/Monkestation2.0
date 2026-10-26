import { afterEach, beforeEach, expect, mock, test } from 'bun:test';
import { act } from 'react';
import { createRoot, type Root } from 'react-dom/client';

const rod = '/obj/item/rbmk/fuel_rod/supermatter';
const other = '/obj/item/other';
let backend: Record<string, unknown>;
let resolveStored: (path: string) => void;
let stored: Promise<string>;
const send = mock(() => {});
mock.module('../../backend', () => ({
  useBackend: () => ({ act: send, data: backend }),
}));
mock.module('common/storage', () => ({
  storage: {
    get: (key: string) =>
      key === 'spawnpanel-selectedObj' ? stored : Promise.resolve(undefined),
    set: () => {},
  },
}));
const Container = ({ children }: any) => <div>{children}</div>;
const Button = ({ children, onClick }: any) => (
  <button onClick={onClick}>{children}</button>
);
Object.assign(Container, { Item: Container });
Object.assign(Button, { Checkbox: Button });
mock.module('tgui-core/components', () => ({
  Button, DmIcon: () => null, Input: () => null, NoticeBox: Container,
  Section: Container, Stack: Container, VirtualList: Container,
}));
mock.module('tgui-core/fuzzysearch', () => ({
  useFuzzySearch: ({ searchArray }: any) => ({
    query: 'supermatter', setQuery: () => {}, results: searchArray,
  }),
}));
mock.module('./CreateObjectSettings', () => ({ CreateObjectSettings: () => null }));
const { CreateObject } = await import('./CreateObject');
let root: Root | undefined;
let host: HTMLDivElement;
const props = {
  objList: { atoms: {
    [rod]: { name: 'supermatter fuel rod', icon: '', icon_state: '', mapping: false, type: 'Objects' as const },
    [other]: { name: 'other object', icon: '', icon_state: '', mapping: false, type: 'Objects' as const },
  } },
  setAdvancedSettings: () => {},
  iconSettings: { icon: null, iconState: null, iconSize: 100 },
  onIconSettingsChange: () => {},
};
async function render() {
  await act(async () => {
    root!.render(<CreateObject {...props} />);
    for (let i = 0; i < 10; i++) await Promise.resolve();
  });
}
beforeEach(() => {
  (globalThis as any).IS_REACT_ACT_ENVIRONMENT = true;
  backend = {};
  send.mockClear();
  stored = new Promise((resolve) => { resolveStored = resolve; });
  host = document.createElement('div');
  document.body.append(host);
  root = createRoot(host);
});
afterEach(async () => {
  if (root) await act(async () => root!.unmount());
  root = undefined;
  host.remove();
});

test('restoring the remembered rod informs a fresh server as well as selecting its row', async () => {
  await render();
  expect(send).not.toHaveBeenCalled();
  await act(async () => resolveStored(rod));
  expect(send).toHaveBeenCalledTimes(1);
  expect(send).toHaveBeenCalledWith('selected-atom-changed', { newObj: rod });
  expect(host.textContent).toContain('supermatter fuel rod');
});

for (const field of ['selected_object', 'copied_type']) {
  test(`late storage cannot overwrite a newer server ${field}`, async () => {
    await render();
    backend = { [field]: other };
    await render();
    await act(async () => resolveStored(rod));
    expect(send).not.toHaveBeenCalled();
  });
}

test('late storage cannot overwrite a manual row selection', async () => {
  await render();
  const button = [...host.querySelectorAll('button')].find((node) => node.textContent?.includes('other object'))!;
  await act(async () => button.click());
  await act(async () => resolveStored(rod));
  expect(send).toHaveBeenCalledTimes(1);
  expect(send).toHaveBeenCalledWith('selected-atom-changed', { newObj: other });
});

test('unmounted or obsolete cached selections send no action', async () => {
  await render();
  await act(async () => root!.unmount());
  root = undefined;
  await act(async () => resolveStored(rod));
  expect(send).not.toHaveBeenCalled();
});

test('a removed cached type sends no action', async () => {
  await render();
  await act(async () => resolveStored('/obj/removed'));
  expect(send).not.toHaveBeenCalled();
});

