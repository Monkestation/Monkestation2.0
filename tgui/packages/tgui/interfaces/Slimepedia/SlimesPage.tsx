import { Icon, Tooltip } from 'tgui-core/components';
import { capitalize, capitalizeAll } from 'tgui-core/string';

import { RequirementCell, SlimeName } from '../common/SlimeRancher';
import { SlimepediaSprite } from './SlimepediaSprite';
import type {
  Mutation,
  SlimeColor,
  SlimepediaData,
  SlimepediaNavigation,
} from './types';

type Props = {
  data: SlimepediaData;
  color: SlimeColor;
  navigation: SlimepediaNavigation;
  onSelect: (id: string) => void;
};

export function SlimesPage(props: Props) {
  const { data, color, navigation, onSelect } = props;

  return (
    <div className="Slimepedia__layout">
      <nav
        className="SlimeRancher__card SlimeRancher__scroll Slimepedia__index"
        aria-label="Slime colors"
      >
        <div className="Slimepedia__grid">
          {data.colors.map((entry) => (
            <button
              key={entry.id}
              type="button"
              className="Slimepedia__cell"
              aria-pressed={entry.id === color.id}
              onClick={() => onSelect(entry.id)}
            >
              <span className="Slimepedia__well">
                <SlimepediaSprite
                  id={`slime-${entry.id}`}
                  transparent={entry.transparent}
                />
              </span>
              <span>{capitalizeAll(entry.name)}</span>
            </button>
          ))}
        </div>
      </nav>
      <SlimeDetail data={data} color={color} navigation={navigation} />
    </div>
  );
}

function SlimeDetail(props: Omit<Props, 'onSelect'>) {
  const { data, color, navigation } = props;
  const { colors, showColor, showFamily } = navigation;
  const family = data.families.find((entry) => entry.id === color.effect);
  const crossbreeds = data.families.flatMap((entry) =>
    entry.crossbreeds
      .filter((crossbreed) => crossbreed.color === color.id)
      .map((crossbreed) => ({ family: entry.id, desc: crossbreed.desc })),
  );

  return (
    <article
      key={color.id}
      className="SlimeRancher__card SlimeRancher__scroll Slimepedia__detail"
    >
      <header className="Slimepedia__header">
        <span className="Slimepedia__portrait">
          <SlimepediaSprite
            id={`slime-${color.id}`}
            scale={3}
            transparent={color.transparent}
          />
        </span>
        <div className="Slimepedia__title">
          <h1>
            <SlimeName color={color.name} hex={color.hex} suffix="slime" />
          </h1>
          {color.parents.length === 0 && (
            <span className="SlimeRancher__chip">Starter color</span>
          )}
        </div>
      </header>

      <section className="Slimepedia__section">
        <h2 className="SlimeRancher__heading">Mutates into</h2>
        {color.mutations.length === 0 ? (
          <p className="Slimepedia__muted">
            Nothing. This color is the end of the line.
          </p>
        ) : (
          color.mutations.map((mutation) => (
            <MutationRow
              key={mutation.into}
              mutation={mutation}
              target={colors.get(mutation.into)}
              onClick={() => showColor(mutation.into)}
            />
          ))
        )}
      </section>

      {color.parents.length > 0 && (
        <section className="Slimepedia__section">
          <h2 className="SlimeRancher__heading">Comes from</h2>
          <div className="Slimepedia__chips">
            {color.parents.map((id) => {
              const parent = colors.get(id);
              return (
                parent && (
                  <button
                    key={id}
                    type="button"
                    className="Slimepedia__link"
                    onClick={() => showColor(id)}
                  >
                    <SlimepediaSprite
                      id={`slime-${id}`}
                      scale={1}
                      transparent={parent.transparent}
                    />
                    {capitalizeAll(parent.name)}
                  </button>
                )
              );
            })}
          </div>
        </section>
      )}

      <section className="Slimepedia__section">
        <h2 className="SlimeRancher__heading">Extract</h2>
        <div className="SlimeRancher__well Slimepedia__extract">
          <SlimepediaSprite id={`extract-${color.id}`} />
          <strong>{capitalizeAll(color.name)} extract</strong>
          {family ? (
            <button
              type="button"
              className="Slimepedia__link"
              onClick={() => showFamily(family.id)}
            >
              Makes {family.id} crossbreeds
              <Icon name="chevron-right" />
            </button>
          ) : (
            <span className="Slimepedia__muted">Makes no crossbreeds</span>
          )}
        </div>
      </section>

      <section className="Slimepedia__section">
        <h2 className="SlimeRancher__heading">Injections</h2>
        {color.reactions.length === 0 ? (
          <p className="Slimepedia__muted">Nothing reacts with this extract.</p>
        ) : (
          color.reactions.map((reaction) => (
            <div key={reaction.desc} className="Slimepedia__reaction">
              <span className="Slimepedia__chips">
                {reaction.reagents.map((reagent) => (
                  <span key={reagent.name} className="SlimeRancher__chip">
                    {reagent.amount > 1 && `${reagent.amount}u `}
                    {reagent.name}
                  </span>
                ))}
              </span>
              <span>{reaction.desc}</span>
            </div>
          ))
        )}
      </section>

      {crossbreeds.length > 0 && (
        <section className="Slimepedia__section">
          <h2 className="SlimeRancher__heading">Crossbreeds in this color</h2>
          <div className="Slimepedia__chips">
            {crossbreeds.map((crossbreed) => (
              <Tooltip
                key={crossbreed.family}
                content={`${capitalize(crossbreed.family)}: ${crossbreed.desc}`}
              >
                <button
                  type="button"
                  className="Slimepedia__link"
                  onClick={() => showFamily(crossbreed.family)}
                >
                  <SlimepediaSprite
                    id={`cross-${crossbreed.family}-${color.id}`}
                    scale={1}
                  />
                  {capitalize(crossbreed.family)}
                </button>
              </Tooltip>
            ))}
          </div>
        </section>
      )}
    </article>
  );
}

function MutationRow(props: {
  mutation: Mutation;
  target: SlimeColor | undefined;
  onClick: () => void;
}) {
  const { mutation, target, onClick } = props;

  return (
    <div className="Slimepedia__mutation">
      <button
        type="button"
        className="Slimepedia__mutation-heading"
        onClick={onClick}
      >
        <SlimepediaSprite
          id={`slime-${mutation.into}`}
          scale={1}
          transparent={target?.transparent}
        />
        {target && <SlimeName color={target.name} hex={target.hex} />}
        <Icon name="chevron-right" />
      </button>
      <div className="Slimepedia__requirements">
        {mutation.items.map((item) => (
          <RequirementCell key={item.name} requirement={item}>
            <span className="Slimepedia__muted">Eat</span>
          </RequirementCell>
        ))}
        {mutation.drains.map((drain) => (
          <RequirementCell key={drain.name} requirement={drain}>
            <span className="Slimepedia__muted">Drain {drain.amount}</span>
          </RequirementCell>
        ))}
      </div>
    </div>
  );
}
