/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  changeSettingsTab,
  loadSettings,
  openChatSettings,
  toggleSettings,
  updateSettings,
  addHighlightSetting,
  removeHighlightSetting,
  updateHighlightSetting,
  importSettings,
} from './actions';
import { createDefaultHighlightSetting } from './model';
import { SETTINGS_TABS, FONTS } from './constants';

const defaultHighlightSetting = createDefaultHighlightSetting();

const initialState = {
  version: 1,
  fontSize: 13,
  fontFamily: FONTS[0],
  lineHeight: 1.2,
  theme: 'light',
  adminMusicVolume: 0.5,
  // Keep these two state vars for compatibility with other servers
  highlightText: '',
  highlightColor: '#ffdd44',
  // END compatibility state vars
  highlightSettings: [defaultHighlightSetting.id],
  highlightSettingById: {
    [defaultHighlightSetting.id]: defaultHighlightSetting,
  },
  view: {
    visible: false,
    activeTab: SETTINGS_TABS[0].id,
  },
  statLinked: true,
  statFontSize: 12,
  statTabsStyle: 'default',
  initialized: false,
  websocketEnabled: false,
  websocketServer: '',
};

export const settingsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    case updateSettings.type: {
      return {
        ...state,
        ...payload,
      };
    }
    case loadSettings.type: {
      // Validate version and/or migrate state
      if (!payload?.version) {
        const nextState = {
          ...state,
          ...payload,
        };
        nextState.initialized = true;
        return nextState;
      }

      delete payload.view;
      const nextState = {
        ...state,
        ...payload,
      };
      nextState.initialized = true;
      // Lazy init the list for compatibility reasons
      if (!nextState.highlightSettings) {
        nextState.highlightSettings = [defaultHighlightSetting.id];
        nextState.highlightSettingById[defaultHighlightSetting.id] =
          defaultHighlightSetting;
      }
      // Compensating for mishandling of default highlight settings
      else if (!nextState.highlightSettingById[defaultHighlightSetting.id]) {
        nextState.highlightSettings = [
          defaultHighlightSetting.id,
          ...nextState.highlightSettings,
        ];
        nextState.highlightSettingById[defaultHighlightSetting.id] =
          defaultHighlightSetting;
      }
      // Migrate old highlights to include enabled: true
      Object.keys(nextState.highlightSettingById).forEach((key) => {
        if (nextState.highlightSettingById[key].enabled === undefined) {
          nextState.highlightSettingById[key].enabled = true;
        }
      });
      // Update the highlight settings for default highlight
      // settings compatibility
      const highlightSetting =
        nextState.highlightSettingById[defaultHighlightSetting.id];
      highlightSetting.highlightColor = nextState.highlightColor;
      highlightSetting.highlightText = nextState.highlightText;
      return nextState;
    }
    case importSettings.type: {
      const newSettings = payload.newSettings;
      if (!newSettings) {
        return state;
      }
      const nextState = {
        ...state,
        ...newSettings,
      };
      return nextState;
    }
    case toggleSettings.type: {
      return {
        ...state,
        view: {
          ...state.view,
          visible: !state.view.visible,
        },
      };
    }
    case openChatSettings.type: {
      return {
        ...state,
        view: {
          ...state.view,
          visible: true,
          activeTab: 'chatPage',
        },
      };
    }
    case changeSettingsTab.type: {
      const { tabId } = payload;
      return {
        ...state,
        view: {
          ...state.view,
          activeTab: tabId,
        },
      };
    }
    case addHighlightSetting.type: {
      const highlightSetting = payload;
      return {
        ...state,
        highlightSettings: [...state.highlightSettings, highlightSetting.id],
        highlightSettingById: {
          ...state.highlightSettingById,
          [highlightSetting.id]: highlightSetting,
        },
      };
    }
    case removeHighlightSetting.type: {
      const { id } = payload;
      const nextState = {
        ...state,
        highlightSettings: [...state.highlightSettings],
        highlightSettingById: {
          ...state.highlightSettingById,
        },
      };
      if (id === defaultHighlightSetting.id) {
        nextState.highlightSettings[defaultHighlightSetting.id] =
          defaultHighlightSetting;
      } else {
        delete nextState.highlightSettingById[id];
        nextState.highlightSettings = nextState.highlightSettings.filter(
          (sid) => sid !== id,
        );
        if (!nextState.highlightSettings.length) {
          nextState.highlightSettings.push(defaultHighlightSetting.id);
          nextState.highlightSettingById[defaultHighlightSetting.id] =
            defaultHighlightSetting;
        }
      }
      return nextState;
    }
    case updateHighlightSetting.type: {
      const { id, ...settings } = payload;
      const nextState = {
        ...state,
        highlightSettings: [...state.highlightSettings],
        highlightSettingById: {
          ...state.highlightSettingById,
        },
      };

      // Transfer this data from the default highlight setting
      // so they carry over to other servers
      if (id === defaultHighlightSetting.id) {
        if (settings.highlightText) {
          nextState.highlightText = settings.highlightText;
        }
        if (settings.highlightColor) {
          nextState.highlightColor = settings.highlightColor;
        }
      }

      if (nextState.highlightSettingById[id]) {
        nextState.highlightSettingById[id] = {
          ...nextState.highlightSettingById[id],
          ...settings,
        };
      }

      return nextState;
    }
  }

  return state;
};
