/** Shared Central Command visual vocabulary. Style only, no backend actions. */
import './CCPostTheme.scss';

type CCPostHeaderProps = {
  title: string;
  division?: string;
  status?: string;
};

export const CCPostHeader = ({
  title,
  division = 'CENTRAL COMMAND',
  status = 'SECURE NETWORK',
}: CCPostHeaderProps) => (
  <div className="CCPostHeader">
    <div className="CCPostHeader__identity">
      <svg className="CCPostHeader__logo" viewBox="0 0 425 200" role="img" aria-label="NanoTrasen emblem">
        <path d="m178.004,0.039 -71.204,0 a6.761,6.025 0 0 0 -6.761,6.025 l0,187.872 a6.761,6.025 0 0 0 6.761,6.025 l53.107,0 a6.761,6.025 0 0 0 6.761,-6.025 l0,-101.544 72.216,104.699 a6.761,6.025 0 0 0 5.76,2.87 l73.555,0 a6.761,6.025 0 0 0 6.761,-6.025 l0,-187.872 a6.761,6.025 0 0 0 -6.761,-6.025 l-54.716,0 a6.761,6.025 0 0 0 -6.761,6.025 l0,102.619 L183.764,2.909 a6.761,6.025 0 0 0 -5.76,-2.87 z" />
        <path d="M4.845,22.109 A13.412,12.502 0 0 1 13.478,.039 l66.118,0 a5.365,5.001 0 0 1 5.365,5.001 l0,79.879 z" />
        <path d="M420.155,177.891 A13.412,12.502 0 0 1 411.522,199.961 l-66.118,0 a5.365,5.001 0 0 1 -5.365,-5.001 l0,-79.879 z" />
      </svg>
      <div className="CCPostHeader__brand">
        <div className="CCPostHeader__corporation">NANOTRASEN</div>
        <div className="CCPostHeader__division">{division}</div>
      </div>
      <div className="CCPostHeader__separator" />
      <div className="CCPostHeader__title">{title}</div>
    </div>
    <div className="CCPostHeader__status">{status}</div>
  </div>
);


/** Cached round-local HR portrait. Only callers with authorized personnel data receive an image. */
export const CCPostPersonnelPortrait = ({
  portrait,
  label = 'IDENTITY FILE',
}: {
  portrait?: string | null;
  label?: string;
}) => (
  <div className="CCPostPortrait" aria-label={label}>
    {portrait ? (
      <img className="CCPostPortrait__image" src={`data:image/png;base64,${portrait}`} alt="Registered personnel portrait" />
    ) : (
      <div className="CCPostPortrait__placeholder">NO IMAGE</div>
    )}
    <div className="CCPostPortrait__caption">{label}</div>
  </div>
);

/** Shared local-server outage notice, also displayed before login. */
export const CCPostServerUnavailable = ({ status = 'SERVER MISSING' }: { status?: string }) => (
  <div className="CCPostOutage" role="status">
    <div className="CCPostOutage__title">LOCAL ADMINISTRATIVE SERVER UNAVAILABLE</div>
    <div>Tasking and sector correspondence services are suspended.</div>
    <div className="CCPostOutage__condition">CONDITION: {status}</div>
    <div className="CCPostOutage__help">Power loss requires power restoration; synchronization faults require manual recalibration at the physical Tasking Distribution Server.</div>
  </div>
);
