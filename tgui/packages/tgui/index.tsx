/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
import './styles/main.scss';

import { setupHotReloading } from 'tgui-dev-server/link/client';
import { App } from './app';
import { setupGlobalEvents } from './events';
import { bus } from './events/listeners';
import { setupHotKeys } from './hotkeys';
import { captureExternalLinks } from './links';
import { render } from './renderer';
import { createStackAugmentor } from './stack';

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }
  window.__augmentStack__ = createStackAugmentor();

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => bus.dispatch({ type, payload }));

  render(<App />);

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    // prettier-ignore
    module.hot.accept(['./layouts', './routes', './app'], () => {
      render(<App />);
    });
  }
}

setupApp();
