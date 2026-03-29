/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
import './styles/main.scss';
import './styles/themes/abductor.scss';
import './styles/themes/cardtable.scss';
import './styles/themes/spookyconsole.scss';
import './styles/themes/hackerman.scss';
import './styles/themes/malfunction.scss';
import './styles/themes/neutral.scss';
import './styles/themes/ntos.scss';
import './styles/themes/ntos_cat.scss';
import './styles/themes/ntos_darkmode.scss';
import './styles/themes/ntos_lightmode.scss';
import './styles/themes/ntOS95.scss';
import './styles/themes/ntos_synth.scss';
import './styles/themes/ntos_terminal.scss';
import './styles/themes/ntos_spooky.scss';
import './styles/themes/paper.scss';
import './styles/themes/retro.scss';
import './styles/themes/syndicate.scss';
import './styles/themes/wizard.scss';
import './styles/themes/admin.scss';
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
