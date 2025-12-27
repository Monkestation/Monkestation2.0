import { BandcampImageSize } from './types';

export const getThumbnailUrl = async (
  inputUrl: string,
): Promise<string | null> => {
  if (!inputUrl) return null;
  inputUrl = normalizeTrackUrl(inputUrl);

  const cacheKey = `thumb:${inputUrl}`;
  const cached = localStorage.getItem(cacheKey);
  if (cached !== null) {
    return cached === 'null' ? null : cached;
  }

  try {
    const url = new URL(inputUrl);
    let thumbnail: string | null = null;

    // YouTube watch?v=...
    if (url.hostname.includes('youtube.com') && url.searchParams.has('v')) {
      const id = url.searchParams.get('v');
      thumbnail = `https://img.youtube.com/vi/${id}/hqdefault.jpg`;
    }

    // YouTube short link (i sure hope you're not putting youtube short links in your cassettes)
    else if (url.hostname === 'youtu.be') {
      const id = url.pathname.slice(1);
      thumbnail = `https://img.youtube.com/vi/${id}/hqdefault.jpg`;
    }

    // soundcloud
    else if (url.hostname.includes('soundcloud.com')) {
      const clientId = 'AZQrFd27PgXn40c5dbumOYPFBlIRBVbu';
      const apiUrl = `https://api-v2.soundcloud.com/resolve?client_id=${clientId}&url=${encodeURIComponent(
        inputUrl,
      )}`;
      const res = await fetch(apiUrl);
      if (res.ok) {
        const data = await res.json();
        thumbnail = data.artwork_url || data.user?.avatar_url || null;
      }
    }

    // Bandcamp
    else if (url.hostname.includes('bandcamp.com')) {
      const dommy = await getDocumentForURL(url);
      if (dommy) {
        const firstImg = dommy.querySelector(
          "link[rel='shortcut icon']",
        ) as HTMLLinkElement;
        if (firstImg) {
          const imgId = firstImg.href.match(/img\/(.+)_.*\./)?.[1];
          if (imgId) {
            thumbnail = getBandcampThumbnailUrl(
              imgId,
              BandcampImageSize.JPEG_350,
            );
          }
        }
      }
    }

    localStorage.setItem(cacheKey, thumbnail ?? 'null');

    return thumbnail;
  } catch {
    localStorage.setItem(cacheKey, 'null');
    return null;
  }
};

export const getDocumentForURL = async (url: URL): Promise<Document | null> => {
  try {
    const response = await fetch(url);
    const htmlString = await response.text();

    if (htmlString) {
      const parser = new DOMParser();
      const doc = parser.parseFromString(htmlString, 'text/html');
      return doc;
    } else {
      console.log('No HTML content in the response body.');
      return null;
    }
  } catch (error) {
    console.error('Error during fetch or parsing:', error);
    return null;
  }
};

const getBandcampThumbnailUrl = (imgId: string, type: BandcampImageSize) => {
  return `https://f4.bcbits.com/img/${imgId}_${type}.jpg`;
};

const normalizeTrackUrl = (inputUrl) => {
  try {
    const url = new URL(inputUrl);

    url.hash = '';

    // keep only ?v=videoid
    if (url.hostname.includes('youtube.com')) {
      const videoId = url.searchParams.get('v');
      url.search = '';
      if (videoId) {
        url.searchParams.set('v', videoId);
      }
      return url.toString();
    }

    // shortform, https://youtu.be/videoid, keep path only?
    if (url.hostname === 'youtu.be') {
      return `https://youtu.be${url.pathname}`;
    }

    if (url.hostname.includes('soundcloud.com')) {
      url.search = '';
      return url.toString();
    }

    if (url.hostname.includes('bandcamp.com')) {
      url.search = '';
      return url.toString();
    }

    const trackingParams = [
      /^utm_/i,
      /^fbclid$/i,
      /^gclid$/i,
      /^mc_cid$/i,
      /^mc_eid$/i,
    ];
    for (const [key] of url.searchParams) {
      if (trackingParams.some((p) => p.test(key))) {
        url.searchParams.delete(key);
      }
    }

    return url.toString();
  } catch {
    return inputUrl;
  }
};

const keyReplacePattern = /[^\da-z]/g;
export const ckey = (key: string): string => {
  return key.toLowerCase().replaceAll(keyReplacePattern, '').trim();
};
