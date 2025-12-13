import { Stack, Icon, Dimmer } from '../../components';

type LoadingScreenProps = {
  CustomText?: string;
  CustomIcon?: string;
};
/** Spinner that represents loading states.
 *
 * @usage
 * ```tsx
 * /// rest of the component
 * return (
 * ///... content to overlay
 * {!!loading && <LoadingScreen />}
 * /// ... content to overlay
 * );
 * ```
 * OR
 * ```tsx
 * return (
 * {loading ? <LoadingScreen /> : <ContentToHide />}
 * )
 * ```
 */
export const LoadingScreen = (props: LoadingScreenProps) => {
  return (
    <Dimmer>
      <Stack align="center" fill justify="center" vertical>
        <Stack.Item>
          <Icon
            color="blue"
            name={props.CustomIcon || 'toolbox'}
            spin
            size={4}
          />
        </Stack.Item>
        <Stack.Item>{props.CustomText || 'Please wait...'}</Stack.Item>
      </Stack>
    </Dimmer>
  );
};
