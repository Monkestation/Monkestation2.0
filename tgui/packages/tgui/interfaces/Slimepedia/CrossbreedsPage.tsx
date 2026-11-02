import { capitalize, capitalizeAll } from 'tgui-core/string';

import { SlimeName } from '../common/SlimeRancher';
import { SlimepediaSprite } from './SlimepediaSprite';
import type { Family, SlimepediaData, SlimepediaNavigation } from './types';

type Props = {
  data: SlimepediaData;
  family: Family;
  navigation: SlimepediaNavigation;
  onSelect: (id: string) => void;
};

export function CrossbreedsPage(props: Props) {
  const { data, family, navigation, onSelect } = props;
  const { colors, showColor } = navigation;
  const source = colors.get(family.source);

  return (
    <div className="Slimepedia__layout">
      <nav
        className="SlimeRancher__card SlimeRancher__scroll Slimepedia__index"
        aria-label="Crossbreed effects"
      >
        <div className="Slimepedia__list">
          {data.families.map((entry) => (
            <button
              key={entry.id}
              type="button"
              className="Slimepedia__family"
              aria-pressed={entry.id === family.id}
              onClick={() => onSelect(entry.id)}
            >
              <span className="Slimepedia__well">
                <SlimepediaSprite id={`extract-${entry.source}`} scale={1} />
              </span>
              <span>
                <strong>{capitalize(entry.id)}</strong>
                <small>
                  {capitalizeAll(colors.get(entry.source)?.name ?? '')} extract
                </small>
              </span>
            </button>
          ))}
        </div>
      </nav>
      <article
        key={family.id}
        className="SlimeRancher__card SlimeRancher__scroll Slimepedia__detail"
      >
        <header className="Slimepedia__header">
          <span className="Slimepedia__portrait">
            <SlimepediaSprite id={`extract-${family.source}`} scale={3} />
          </span>
          <div className="Slimepedia__title">
            <h1>{capitalize(family.id)} crossbreeds</h1>
            {source && (
              <p>
                Load {data.effect_extracts} {source.name} extracts and{' '}
                {data.color_extracts} extracts of any color below into an
                extract compressor.
              </p>
            )}
          </div>
        </header>
        <section className="Slimepedia__section">
          {family.crossbreeds.map((crossbreed) => {
            const color = colors.get(crossbreed.color);
            return (
              color && (
                <div key={crossbreed.color} className="Slimepedia__crossbreed">
                  <span className="Slimepedia__well">
                    <SlimepediaSprite
                      id={`cross-${family.id}-${crossbreed.color}`}
                    />
                  </span>
                  <div>
                    <button
                      type="button"
                      className="Slimepedia__name-link"
                      onClick={() => showColor(crossbreed.color)}
                    >
                      <SlimeName color={color.name} hex={color.hex} />
                    </button>
                    <p>{crossbreed.desc}</p>
                  </div>
                </div>
              )
            );
          })}
        </section>
      </article>
    </div>
  );
}
