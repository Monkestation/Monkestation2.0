import { createAction } from 'common/redux';
import { chatRenderer } from './chat/renderer';
import { loadSettings, updateSettings } from './settings/actions';
import { selectSettings } from './settings/selectors';
import { createLogger } from 'tgui/logging';

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

const MAX_RETRIES = 10;
const RETRY_INTERVAL = 500; // ms

// Websocket close codes
const WEBSOCKET_DISABLED = 4555;
const WEBSOCKET_REATTEMPT = 4556;
const SAFE_CLOSE_CODE = 1000;

const logger = createLogger('websocket');

export const websocketMiddleware = (store) => {
  let websocket: WebSocket | null = null;
  let reconnectTimer: number | null = null;
  let retryCount = 0;
  let manuallyClosed = false;

  const clearReconnectTimer = () => {
    if (reconnectTimer !== null) {
      clearInterval(reconnectTimer);
      reconnectTimer = null;
    }
  };

  const safeClose = (code = SAFE_CLOSE_CODE, reason?: string) => {
    if (!websocket) return;
    if (
      websocket.readyState === WebSocket.CLOSED ||
      websocket.readyState === WebSocket.CLOSING
    ) return;

    websocket.close(code, reason);
  };

  const startReconnectLoop = () => {
    if (reconnectTimer !== null) return;

    reconnectTimer = window.setInterval(() => {
      const { websocketEnabled } = selectSettings(store.getState());

      if (!websocketEnabled) {
        clearReconnectTimer();
        return;
      }

      if (retryCount >= MAX_RETRIES) {
        clearReconnectTimer();
        sendWSNotice(
          `Websocket failed to reconnect after ${MAX_RETRIES} attempts.`,
          true,
        );
        return;
      }

      if (
        !websocket ||
        websocket.readyState === WebSocket.CLOSED ||
        websocket.readyState === WebSocket.CLOSING
      ) {
        retryCount++;
        setupWebsocket();
      }
    }, RETRY_INTERVAL);
  };

  const setupWebsocket = (force = false) => {
    const { websocketEnabled, websocketServer } = selectSettings(
      store.getState(),
    );

    if (!websocketEnabled) {
      clearReconnectTimer();
      safeClose(WEBSOCKET_DISABLED);
      websocket = null;
      return;
    }

    if (!force && websocket && websocket.readyState === WebSocket.OPEN) {
      return;
    }

    if (force) {
      clearReconnectTimer();

      if (websocket) {
        manuallyClosed = true;
        try {
          websocket.close(WEBSOCKET_REATTEMPT, 'forced reconnect');
        } catch {
          /* ignore */
        }
        websocket = null;
      }
    }

    try {
      manuallyClosed = false;
      websocket = new WebSocket(`ws://${websocketServer}`);
    } catch (e: any) {
      if (e.name === 'SyntaxError') {
        sendWSNotice(
          `Error creating websocket: Invalid address! Make sure you're following the placeholder. Example: <code>localhost:1234</code>`,
          true,
        );
        return;
      }
      sendWSNotice(`Error creating websocket: ${e.name} - ${e.message}`);
      startReconnectLoop();
      return;
    }

    websocket.addEventListener('open', () => {
      clearReconnectTimer();
      sendWSNotice('Websocket connected!', true);
      retryCount = 0;
    });

    websocket.addEventListener('close', (ev) => {
      websocket = null;

      if (manuallyClosed || ev.code === WEBSOCKET_DISABLED) return;

      sendWSNotice(
        `Websocket disconnected! Code: ${ev.code} Reason: ${ev.reason || 'None provided'}`,
        true,
      );

      startReconnectLoop();
    });

    websocket.addEventListener('error', (ev) => {
      logger.error('got websocket error', ev);
      safeClose(WEBSOCKET_REATTEMPT, 'got error from server');
    });
  };

  // Initial connect
  setupWebsocket();

  return (next) => (action) => {
    const result = next(action);
    const { type, payload } = action as any;

    if (type === updateSettings.type || type === loadSettings.type) {
      if (!payload?.websocketEnabled) {
        manuallyClosed = true;
        clearReconnectTimer();
        safeClose(WEBSOCKET_DISABLED);
        websocket = null;
        return result;
      }

      setupWebsocket();
      return result;
    }

    if (type === reconnectWebsocket.type) {
      setupWebsocket(true);
      sendWSNotice('Attempting to connect to websocket...', true);
      return result;
    }

    if (type === disconnectWebsocket.type) {
      manuallyClosed = true;
      clearReconnectTimer();
      safeClose(WEBSOCKET_DISABLED);
      websocket = null;
      retryCount = 0;
      sendWSNotice(
        'Websocket forcefully disconnected. (Retry count reset)',
        true,
      );
      return result;
    }

    if (websocket?.readyState === WebSocket.OPEN) {
      websocket.send(JSON.stringify({ type, payload }));
    }

    return result;
  };
};
