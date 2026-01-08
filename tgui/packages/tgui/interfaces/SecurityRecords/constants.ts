export const CRIMESTATUS2COLOR = {
  Arrest: 'bad',
  Discharged: 'blue',
  Incarcerated: 'average',
  Parole: 'good',
  Suspected: 'teal',
  Search: 'purple',
} as const;

export const CRIMESTATUS2DESC = {
  Arrest: 'Arrest. Target must have valid crimes to set this status.',
  Discharged: 'Discharged. Individual has served their time and been released.',
  Incarcerated: 'Incarcerated. Individual is currently serving a sentence.',
  Parole: 'Parole. Released from prison, but still under supervision.',
  Suspected: 'Suspected. Monitor closely for criminal activity.',
  Search: 'Search. Suspect needs to be searched and cleared.',
} as const;
