import { createAction } from 'common/redux';
import { chatRenderer } from './chat/renderer';
import { loadSettings, updateSettings } from './settings/actions';
import { selectSettings } from './settings/selectors';

const sendWSNotice = (message, small = false) => {
  chatRenderer.processBatch([
    {
      html: small
        ? `<span class='adminsay'>${message}</span>`
        : `<div class="boxed_message"><center><span class='alertwarning'>${message}</span></center></div>`,
    },
  ]);
};

export const reconnectWebsocket = createAction('websocket/reconnect');
export const disconnectWebsocket = createAction('websocket/disconnect');

// Websocket close codes
const WEBSOCKET_DISABLED = 4555;
const WEBSOCKET_REATTEMPT = 4556;

export const websocketMiddleware = (store) => {
  let websocket: WebSocket | null = null;

  const setupWebsocket = (store) => {
    const { websocketEnabled, websocketServer } = selectSettings(
      store.getState(),
    );
    if (!websocketEnabled) {
      websocket?.close(WEBSOCKET_REATTEMPT);
      return;
    }

    websocket?.close(WEBSOCKET_REATTEMPT);

    try {
      websocket = new WebSocket(`ws://${websocketServer}`);
    } catch (e) {
      if (e.name === 'SyntaxError') {
        sendWSNotice(
          `Error creating websocket: Invalid address! Make sure you're following the placeholder. Example: <code>localhost:1234</code>`,
        );
        return;
      }
      sendWSNotice(`Error creating websocket: ${e.name} - ${e.message}`);
      return;
    }

    websocket.addEventListener('open', () => {
      sendWSNotice('Websocket connected!', true);
    });

    websocket.addEventListener('close', function closeEventThing(ev) {
      const { websocketEnabled } = selectSettings(store.getState());
      if (!websocketEnabled) {
        // Doing this because eitherwise it 'close' will get called
        // thousands of times per second if the connection wasn't closed properly.
        // I don't know WHY it does that but it just does.
        ev.target?.removeEventListener('close', closeEventThing);
        websocket?.removeEventListener('close', closeEventThing);
        return;
      }
      if (ev.code !== WEBSOCKET_DISABLED && ev.code !== WEBSOCKET_REATTEMPT) {
        sendWSNotice(
          `Websocket disconnected! Code: ${ev.code} Reason: ${ev.reason || 'None provided'}`,
        );
      }
    });

    websocket.addEventListener('error', () => {
      // Really don't think we should do anything here.
      // setTimeout(() => setupWebsocket(store), 2000);
    });
  };

  setTimeout(() => setupWebsocket(store));

  return (next) => (action) => {
    const { type, payload } = action as {
      type: string;
      payload: {
        websocketEnabled: boolean;
        websocketServer: string;
      };
    };
    if (!payload) return next(action);
    if (type === updateSettings.type || type === loadSettings.type) {
      if (typeof payload?.websocketEnabled === 'undefined') {
        store.dispatch(
          updateSettings({
            websocketEnabled: false,
          }),
        );
        return next(action);
      }
      if (!payload.websocketEnabled) {
        websocket?.close(WEBSOCKET_DISABLED);
        websocket = null;
      } else if (
        !websocket ||
        websocket.url !== payload.websocketServer ||
        (payload.websocketEnabled &&
          (!websocket || websocket.readyState !== websocket.OPEN))
      ) {
        websocket?.close(WEBSOCKET_REATTEMPT, 'Websocket settings changed');
        sendWSNotice('Websocket enabled.', true);
        setupWebsocket(store);
      }
      return next(action);
    }

    if (type === reconnectWebsocket.type) {
      const settings = selectSettings(store.getState());
      if (settings.websocketEnabled) setupWebsocket(store);
      return next(action);
    }

    if (type === disconnectWebsocket.type) {
      websocket?.close(WEBSOCKET_DISABLED);
      websocket = null;
      sendWSNotice('Websocket forcefully disconnected.', true);
    }

    websocket &&
      websocket.readyState === websocket.OPEN &&
      websocket?.send(
        JSON.stringify({
          type,
          payload,
        }),
      );
    return next(action);
  };
};
