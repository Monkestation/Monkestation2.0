import { useEffect, useMemo, useState } from 'react';
import { Icon } from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { logger } from '../../logging';
import { CrossbreedsPage } from './CrossbreedsPage';
import { SlimesPage } from './SlimesPage';
import {
  type SlimepediaData,
  type SlimepediaNavigation,
  SlimepediaPage,
} from './types';

export { SlimepediaPage };

export const SLIMEPEDIA_TABS = [
  { page: SlimepediaPage.Slimes, label: 'Slimes', icon: 'tint' },
  { page: SlimepediaPage.Crossbreeds, label: 'Crossbreeds', icon: 'flask' },
] as const;

/** Loads once per window, so call it at the window's root rather than inside a tab. */
export function useSlimepediaData() {
  const [data, setData] = useState<SlimepediaData>();

  useEffect(() => {
    fetchRetry(resolveAsset('slimepedia.json'))
      .then((response) => response.json())
      .then((slimepedia: SlimepediaData) => setData(slimepedia))
      .catch((error) => {
        logger.log('Failed to fetch slimepedia.json', JSON.stringify(error));
      });
  }, []);

  return data;
}

type Props = {
  data: SlimepediaData | undefined;
  page: SlimepediaPage;
  onPageChange: (page: SlimepediaPage) => void;
  /** Color name to open on, like the scanner's current slime. */
  initialColorName?: string;
};

export function Slimepedia(props: Props) {
  const { data } = props;

  if (!data) {
    return (
      <div className="SlimeRancher__empty">
        <Icon name="spinner" spin size={3} />
        <p>Opening the field guide...</p>
      </div>
    );
  }

  return <SlimepediaBody {...props} data={data} />;
}

function SlimepediaBody(props: Props & { data: SlimepediaData }) {
  const { data, page, onPageChange, initialColorName } = props;
  const [colorId, setColorId] = useState<string>();
  const [familyId, setFamilyId] = useState<string>();

  const colors = useMemo(
    () => new Map(data.colors.map((color) => [color.id, color])),
    [data],
  );

  const color =
    (colorId && colors.get(colorId)) ||
    data.colors.find((entry) => entry.name === initialColorName) ||
    data.colors[0];
  const family =
    data.families.find((entry) => entry.id === familyId) || data.families[0];

  const navigation: SlimepediaNavigation = {
    colors,
    showColor: (id) => {
      setColorId(id);
      onPageChange(SlimepediaPage.Slimes);
    },
    showFamily: (id) => {
      setFamilyId(id);
      onPageChange(SlimepediaPage.Crossbreeds);
    },
  };

  switch (page) {
    case SlimepediaPage.Slimes:
      return (
        <SlimesPage
          data={data}
          color={color}
          navigation={navigation}
          onSelect={setColorId}
        />
      );
    case SlimepediaPage.Crossbreeds:
      return (
        <CrossbreedsPage
          data={data}
          family={family}
          navigation={navigation}
          onSelect={setFamilyId}
        />
      );
  }
}
