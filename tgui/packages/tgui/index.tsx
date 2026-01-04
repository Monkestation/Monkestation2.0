/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
// MONKESTATION ADDITION START
import './styles/themes/clockwork.scss';
import './styles/themes/admintickets.scss';
// MONKESTATION ADDITION END

import './styles/themes/chicken_book.scss';
import './styles/themes/generic-yellow.scss';
import './styles/themes/generic.scss';

import { configureStore } from './store';

import { captureExternalLinks } from './links';
import { createRenderer } from './renderer';
import { perf } from 'common/perf';
import { setupGlobalEvents } from './events';
import { setupHotKeys } from './hotkeys';
import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';
import { setGlobalStore } from './backend';
import { loadIconRefMap } from './icons';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore();

const renderApp = createRenderer(() => {
  setGlobalStore(store);
  loadIconRefMap();

  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent(store);
  return <Component />;
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // Re-render UI on store updates
  store.subscribe(renderApp);

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    // prettier-ignore
    module.hot.accept([
      './components',
      './debug',
      './layouts',
      './routes',
    ], () => {
      renderApp();
    });
  }
};

setupApp();
