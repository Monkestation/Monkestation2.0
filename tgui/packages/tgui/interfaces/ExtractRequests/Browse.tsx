import { Fragment, type ReactNode } from 'react';
import { Box, Button, Icon, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { capitalize, capitalizeAll } from 'tgui-core/string';

import { SlimeChip, SlimeName } from '../common/SlimeRancher';
import { SlimepediaSprite } from '../Slimepedia/SlimepediaSprite';
import type {
  Crossbreed,
  Family,
  SlimeColor,
  SlimepediaData,
} from '../Slimepedia/types';
import { itemName, tierLabel } from './items';
import { Ingredient, ItemPreview } from './Shared';

const TIERS = [0, 1, 2, 3, 4, 5, null];

function Socket(props: {
  sprite: string;
  name: string;
  selected: boolean;
  dim: boolean;
  onSelect: () => void;
}) {
  const { sprite, name, selected, dim, onSelect } = props;

  return (
    <Button
      className={classes([
        'ExtractRequests__socket',
        dim && 'ExtractRequests__socket--unbred',
      ])}
      selected={selected}
      onClick={onSelect}
    >
      <SlimepediaSprite id={sprite} scale={2} />
      <Box className="ExtractRequests__socket-name">{capitalizeAll(name)}</Box>
    </Button>
  );
}

function Details(props: { sprite: string; children: ReactNode }) {
  return (
    <Box className="ExtractRequests__details">
      <ItemPreview sprite={props.sprite} />
      <Box className="ExtractRequests__details-scroll SlimeRancher__scroll">
        {props.children}
      </Box>
    </Box>
  );
}

export function ExtractsBrowser(props: {
  catalog: SlimepediaData;
  bred: Set<string>;
  selected: SlimeColor;
  onSelect: (id: string) => void;
}) {
  const { catalog, bred, selected, onSelect } = props;

  return (
    <Box className="ExtractRequests__workspace">
      <Box className="ExtractRequests__tray SlimeRancher__scroll">
        {TIERS.map((tier) => (
          <Fragment key={tier ?? 'special'}>
            <Tooltip content={tierLabel(tier)}>
              <Box className="ExtractRequests__tier">
                {tier === null ? <Icon name="star" /> : tier}
              </Box>
            </Tooltip>
            {catalog.colors
              .filter((color) => color.tier === tier)
              .map((color) => (
                <Socket
                  key={color.id}
                  sprite={`extract-${color.id}`}
                  name={color.name}
                  selected={color.id === selected.id}
                  dim={!bred.has(color.id)}
                  onSelect={() => onSelect(color.id)}
                />
              ))}
          </Fragment>
        ))}
      </Box>
      <Details sprite={`extract-${selected.id}`}>
        <Box className="ExtractRequests__title">
          <Box as="h2">
            <SlimeName color={selected.name} hex={selected.hex} />
          </Box>
          <Box className="ExtractRequests__chips">
            <SlimeChip>{tierLabel(selected.tier)}</SlimeChip>
            {!bred.has(selected.id) && (
              <SlimeChip tone="muted">Not bred yet</SlimeChip>
            )}
          </Box>
        </Box>
        <Box className="SlimeRancher__rule" />
        {selected.reactions.map((reaction) => (
          <Box key={reaction.desc} className="ExtractRequests__reaction">
            <Box className="ExtractRequests__chips">
              {reaction.reagents.map((reagent) => (
                <Box
                  as="span"
                  key={reagent.name}
                  className="ExtractRequests__reagent"
                >
                  {reagent.amount > 1 && `${reagent.amount}u `}
                  {reagent.name}
                </Box>
              ))}
            </Box>
            {reaction.desc}
          </Box>
        ))}
      </Details>
    </Box>
  );
}

export function CrossbreedsBrowser(props: {
  catalog: SlimepediaData;
  families: Family[];
  family: Family;
  crossbreed: Crossbreed;
  colors: Map<string, SlimeColor>;
  bred: Set<string>;
  onFamily: (id: string) => void;
  onColor: (id: string) => void;
}) {
  const {
    catalog,
    families,
    family,
    crossbreed,
    colors,
    bred,
    onFamily,
    onColor,
  } = props;
  const selected = colors.get(crossbreed.color);
  const source = colors.get(family.source);

  return (
    <Box className="ExtractRequests__workspace">
      <Box className="ExtractRequests__cross">
        <Box className="ExtractRequests__families SlimeRancher__scroll">
          {families.map((entry) => (
            <Button
              key={entry.id}
              className="ExtractRequests__family"
              selected={entry.id === family.id}
              onClick={() => onFamily(entry.id)}
            >
              <SlimepediaSprite
                id={`cross-${entry.id}-${entry.source}`}
                scale={1}
              />
              {capitalize(entry.id)}
            </Button>
          ))}
        </Box>
        <Box className="ExtractRequests__grid SlimeRancher__scroll">
          {catalog.colors.map((color) => {
            const entry = family.crossbreeds.find(
              (candidate) => candidate.color === color.id,
            );
            if (!entry?.orderable) {
              const name = itemName(
                { family: family.id, color: color.id },
                colors,
              );
              return (
                <Tooltip
                  key={color.id}
                  content={
                    entry
                      ? `${name} falls apart when made, so it can't be ordered`
                      : `There's no ${name} crossbreed`
                  }
                >
                  <Box className="ExtractRequests__socket ExtractRequests__socket--missing">
                    <Box className="ExtractRequests__missing-mark">?</Box>
                    {capitalizeAll(color.name)}
                  </Box>
                </Tooltip>
              );
            }
            return (
              <Socket
                key={color.id}
                sprite={`cross-${family.id}-${color.id}`}
                name={color.name}
                selected={color.id === crossbreed.color}
                dim={!bred.has(family.source) || !bred.has(color.id)}
                onSelect={() => onColor(color.id)}
              />
            );
          })}
        </Box>
      </Box>
      {!!selected && !!source && (
        <Details sprite={`cross-${family.id}-${selected.id}`}>
          <Box className="ExtractRequests__title">
            <Box as="h2">
              <SlimeName
                color={selected.name}
                hex={selected.hex}
                label={`${family.id} ${selected.name}`}
              />
            </Box>
            <Box className="ExtractRequests__chips">
              <SlimeChip>Crossbreed</SlimeChip>
            </Box>
          </Box>
          <Box className="SlimeRancher__rule" />
          <Box className="ExtractRequests__reaction">{crossbreed.desc}</Box>
          <Box className="ExtractRequests__recipe">
            <Box bold>Extract compressor</Box>
            {source.id === selected.id ? (
              <Ingredient
                color={source}
                count={catalog.effect_extracts + catalog.color_extracts}
                role="Both tanks"
                bred={bred.has(source.id)}
              />
            ) : (
              <>
                <Ingredient
                  color={source}
                  count={catalog.effect_extracts}
                  role="Type tank"
                  bred={bred.has(source.id)}
                />
                <Ingredient
                  color={selected}
                  count={catalog.color_extracts}
                  role="Color tank"
                  bred={bred.has(selected.id)}
                />
              </>
            )}
          </Box>
        </Details>
      )}
    </Box>
  );
}
