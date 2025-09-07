import type { Dispatch } from 'common/redux';
import type { Page } from '../chat/types';
import { importSettings } from './actions';

export const exportChatSettings = (
  settings: Record<string, any>,
  pages: Record<string, Page>[],
) => {
  const filename = `ss13-chatsettings-${new Date().toJSON().slice(0, 10)}.json`;
  const mimeType = 'application/json';

  const pagesEntry: Record<string, Page>[] = [];
  pagesEntry['chatPages'] = pages;

  const exportObject = Object.assign(settings, pagesEntry);

  const jsonString = JSON.stringify(exportObject, null, ' ');

  Byond.saveBlob(new Blob([jsonString], { type: mimeType }), filename, '.json');
};

export const importChatSettings = (
  dispatch: Dispatch,
  settings: string | string[],
) => {
  if (Array.isArray(settings)) {
    return;
  }
  const ourImport = JSON.parse(settings);
  if (!ourImport?.version) {
    return;
  }
  const pageRecord = ourImport['chatPages'];
  delete ourImport['chatPages'];

  dispatch(importSettings(ourImport, pageRecord));
};
