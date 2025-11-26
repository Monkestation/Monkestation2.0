/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { setClientTheme } from '../themes';
import {
  loadSettings,
  updateSettings,
  addHighlightSetting,
  removeHighlightSetting,
  updateHighlightSetting,
  exportSettings,
} from './actions';
import { selectSettings } from './selectors';
import { FONTS_DISABLED } from './constants';
import { setDisplayScaling } from './scaling';
import { exportChatSettings } from './settingsImExport';

let setStatFontTimer;
let statTabsTimer;

const setGlobalFontSize = (fontSize, statFontSize, statLinked) => {
  document.documentElement.style.setProperty('font-size', fontSize + 'px');
  document.body.style.setProperty('font-size', fontSize + 'px');

  // Used solution from theme.ts
  clearInterval(setStatFontTimer);
  Byond.command(
    `.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`,
  );
  setStatFontTimer = setTimeout(() => {
    Byond.command(
      `.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`,
    );
  }, 1500);
};

const setGlobalFontFamily = (fontFamily) => {
  if (fontFamily === FONTS_DISABLED) fontFamily = null;

  document.documentElement.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-family', fontFamily);
};

const setStatTabsStyle = (style) => {
  clearInterval(statTabsTimer);
  Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  statTabsTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  }, 1500);
};

export const settingsMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      setDisplayScaling();
      storage.get('panel-settings').then((settings) => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (type === exportSettings.type) {
      const state = store.getState();
      const settings = selectSettings(state);
      exportChatSettings(settings, state.chat.pageById);
      return;
    }
    if (
      type === updateSettings.type ||
      type === loadSettings.type ||
      type === addHighlightSetting.type ||
      type === removeHighlightSetting.type ||
      type === updateHighlightSetting.type
    ) {
      // Set client theme
      const theme = payload?.theme;
      if (theme) {
        setClientTheme(theme);
      }
      // Pass action to get an updated state
      next(action);
      const settings = selectSettings(store.getState());
      // Update stat panel settings
      setStatTabsStyle(settings.statTabsStyle);
      // Update global UI font size
      setGlobalFontSize(
        settings.fontSize,
        settings.statFontSize,
        settings.statLinked,
      );
      setGlobalFontFamily(settings.fontFamily);
      // Save settings to the web storage
      storage.set('panel-settings', settings);
      return;
    }
    return next(action);
  };
};
