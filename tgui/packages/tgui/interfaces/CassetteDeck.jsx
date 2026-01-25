import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  LabeledList,
  Section,
  Stack,
  Input,
  Knob,
} from '../components';
import { Window } from '../layouts';

const panelStyle = {
  backgroundColor: '#2e2e2e',
  border: '2px solid #555',
  boxShadow: '0 0 10px #000000a0',
  padding: '0.75em',
};

const moduleStyle = {
  border: '1px solid #1a1a1a',
  backgroundColor: '#3a3a3a',
  padding: '0.5em',
  marginBottom: '0.75em',
  boxShadow: 'inset 1px 1px 3px #000000c0',
  borderRadius: '3px',
};

const controlLabelStyle = {
  fontSize: '0.7em',
  textAlign: 'center',
  color: '#cccccc',
  marginTop: '0.2em',
  fontWeight: 'normal',
};

const KnobControl = ({
  label,
  value,
  action,
  min = 0,
  max = 100,
  step = 1,
  className,
}) => (
  <Stack.Item
    className={`Layout--stack-vertical Layout--stack--center ${className}`}
  >
    {' '}
    <Knob
      value={value}
      minValue={min}
      maxValue={max}
      step={step}
      style={{
        width: '38px',
        height: '38px',
        borderRadius: '50%',
        backgroundColor: '#777777',
        border: '1px solid #aaaaaa',
        boxShadow: 'inset 0 0 5px #000000',
      }}
    />
    <Box style={controlLabelStyle}>{label}</Box>{' '}
    <Box
      style={{
        fontSize: '0.8em',
        marginTop: '0.2em',
        backgroundColor: '#000',
        color: '#00ff44',
        padding: '0 4px',
        border: '1px solid #1a1a1a',
      }}
    >
      {Math.round(value)}{' '}
    </Box>{' '}
  </Stack.Item>
);

const ActionButton = ({
  content,
  icon,
  onClick,
  style,
  selected = false,
  className,
}) => (
  <Button
    content={content}
    icon={icon}
    onClick={onClick}
    selected={selected}
    className={className}
    style={{
      ...style,
      fontSize: '0.75em',
      padding: '0.3em 0.6em',
      border: selected ? '2px solid #00aaff' : '1px solid #555',
      backgroundColor: selected ? '#004d80' : '#444',
      color: selected ? 'white' : '#cccccc',
      boxShadow: selected ? '0 0 5px #00aaff' : 'none',
    }}
  />
);

export const CassetteDeck = (props) => {
  const { act, data } = useBackend();
  const { active, track_selected, songs: raw_songs } = data;

  const [selectedDesign, setSelectedDesign] = useLocalState(
    data,
    'cassette_design',
    'TYPE IV (Standard)',
  );

  const [selectedAge, setSelectedAge] = useLocalState(data, 'cassette_age', 50);

  const [selectedSticker, setSelectedSticker] = useLocalState(
    data,
    'cassette_sticker',
    'Default',
  );

  const songs = flow([sortBy((song) => song.name)])(raw_songs || []);

  const cassetteTypes = [
    { label: 'TYPE I', value: 'TYPE I', sub: 'CHEAP' },
    { label: 'TYPE II', value: 'TYPE II', sub: 'VALUE' },
    { label: 'TYPE III', value: 'TYPE III', sub: 'STANDARD' },
    { label: 'TYPE IV', value: 'TYPE IV', sub: 'STANDARD' },
    { label: 'TYPE V', value: 'TYPE V', sub: 'STANDARD' },
    { label: 'BYPASS', value: 'BYPASS (Master)', sub: 'MASTER' },
  ].reverse();

  const stickerDesigns = [
    'Default',
    'Skull',
    'Fire',
    'Heart',
    'Mix Tape',
    'Cool Cat',
  ];

  return (
    <Window width={1000} height={500}>
      {' '}
      <Window.Content style={panelStyle}>
        {' '}
        <Stack fill>
          {' '}
          <Stack.Item
            basis="30%"
            grow
            style={{ paddingRight: '1em', borderRight: '1px solid #555' }}
          >
            {' '}
            <Stack>
              {' '}
              <Stack.Item basis="20%">
                {' '}
                <Box
                  className="Layout--stack-vertical Layout--stack--center"
                  style={{
                    paddingTop: '0.5em',
                    backgroundColor: '#1a1a1a',
                    borderRadius: '3px',
                  }}
                >
                  {' '}
                  {cassetteTypes.map((type) => {
                    const isSelected = selectedDesign === type.value;
                    return (
                      <Box
                        key={type.value}
                        style={{
                          padding: '0.3em 0.5em',
                          width: '90%',
                          marginBottom: '5px',
                          backgroundColor: isSelected ? '#004d80' : '#444',
                          border: isSelected
                            ? '1px solid #00aaff'
                            : '1px solid #2e2e2e',
                          borderRadius: '2px',
                        }}
                        onClick={() =>
                          act('set_design', { design: type.value })
                        }
                      >
                        {' '}
                        <Box
                          className="Layout--stack-vertical Layout--stack--center"
                          style={{ color: isSelected ? 'white' : '#999' }}
                        >
                          {' '}
                          <Box
                            style={{
                              fontSize: '0.8em',
                              fontWeight: 'bold',
                            }}
                          >
                            {type.label}{' '}
                          </Box>{' '}
                          <Box style={{ fontSize: '0.6em' }}>
                            {type.sub}
                          </Box>{' '}
                        </Box>{' '}
                      </Box>
                    );
                  })}{' '}
                </Box>{' '}
              </Stack.Item>{' '}
              <Stack.Item grow basis="80%">
                {' '}
                <Box
                  style={{
                    border: '2px solid #555',
                    height: '150px',
                    backgroundColor: '#000',
                    padding: '5px',
                    marginTop: '0.5em',
                    marginLeft: '0.5em',
                    boxShadow: 'inset 0 0 5px #00aaff40',
                  }}
                >
                  {' '}
                  <Box className="Layout--stack Layout--stack--center">
                    {' '}
                    <DmIcon
                      icon={'icons/obj/cassettes/walkman.dmi'}
                      icon_state={selectedDesign}
                      width={'150px'}
                      height={'100px'}
                    />{' '}
                  </Box>{' '}
                </Box>{' '}
                <Box
                  style={{
                    ...moduleStyle,
                    marginLeft: '0.5em',
                    marginTop: '0.75em',
                  }}
                >
                  {' '}
                  <Section
                    title="AGE"
                    level={2}
                    style={{ padding: '0.2em', color: '#ccc' }}
                  >
                    {' '}
                    <LabeledList>
                      {' '}
                      <LabeledList.Item
                        label="WORN LEVEL"
                        labelColor="lightgray"
                      >
                        {' '}
                        <Stack align="center">
                          {' '}
                          <Stack.Item style={controlLabelStyle}>
                            NEW
                          </Stack.Item>{' '}
                          <Stack.Item grow>
                            {' '}
                            <Input
                              type="range"
                              min={0}
                              max={100}
                              step={1}
                              value={selectedAge}
                              onChange={(e, value) => {
                                setSelectedAge(value);
                                act('set_age', { age: value });
                              }}
                            />{' '}
                          </Stack.Item>{' '}
                          <Stack.Item style={controlLabelStyle}>
                            WORN{' '}
                          </Stack.Item>{' '}
                        </Stack>{' '}
                      </LabeledList.Item>{' '}
                    </LabeledList>{' '}
                  </Section>{' '}
                </Box>{' '}
              </Stack.Item>{' '}
            </Stack>{' '}
            <Box style={moduleStyle}>
              {' '}
              <Section
                title="Sticker Design"
                level={2}
                style={{ padding: '0.2em', color: '#ccc' }}
              >
                {' '}
                <LabeledList>
                  {' '}
                  <LabeledList.Item label="Sticker" labelColor="lightgray">
                    {' '}
                    <Dropdown
                      overflow-y="scroll"
                      width="100%"
                      options={stickerDesigns}
                      selected={selectedSticker}
                      onSelected={(value) => {
                        setSelectedSticker(value);
                        act('select_sticker', { sticker: value });
                      }}
                    />{' '}
                  </LabeledList.Item>{' '}
                </LabeledList>{' '}
              </Section>{' '}
            </Box>{' '}
            <Box style={moduleStyle}>
              {' '}
              <Stack justify="space-around">
                {' '}
                <KnobControl
                  label="HISS"
                  value={data.hiss || 0}
                  action="set_hiss"
                  min={0}
                  max={100}
                  step={1}
                />{' '}
                <KnobControl
                  label="SATURATION"
                  value={data.saturation || 0}
                  action="set_sat"
                  min={0}
                  max={100}
                  step={1}
                />{' '}
                <KnobControl
                  label="DEPTH"
                  value={data.depth || 0}
                  action="set_depth"
                  min={0}
                  max={100}
                  step={1}
                />{' '}
              </Stack>{' '}
            </Box>{' '}
          </Stack.Item>{' '}
          <Stack.Item
            basis="40%"
            grow
            style={{ padding: '0 1em', borderRight: '1px solid #555' }}
          >
            {' '}
            <Box style={moduleStyle}>
              {' '}
              <Section
                title="LEVEL METERS"
                level={2}
                style={{ padding: '0.2em', color: '#ccc' }}
              >
                {' '}
                <Stack justify="space-around" align="baseline">
                  {' '}
                  <Stack.Item basis="20%" style={controlLabelStyle}>
                    IN{' '}
                  </Stack.Item>{' '}
                  <Stack.Item grow>
                    {' '}
                    <Box
                      style={{
                        height: '70px',
                        border: '1px solid #555',
                        background: '#1a1a1a',
                      }}
                    >
                      {' '}
                      <Box
                        className="Layout--stack Layout--stack--center"
                        style={{ height: '100%' }}
                      >
                        {' '}
                        <Box
                          style={{
                            width: '10px',
                            height: '80%',
                            backgroundColor: '#00ff44',
                            border: '1px solid #000',
                          }}
                        />{' '}
                        <Box
                          style={{
                            width: '10px',
                            height: '60%',
                            backgroundColor: '#ff0000',
                            border: '1px solid #000',
                            marginLeft: '5px',
                          }}
                        />{' '}
                      </Box>{' '}
                    </Box>{' '}
                  </Stack.Item>{' '}
                  <Stack.Item basis="20%" style={controlLabelStyle}>
                    OUT{' '}
                  </Stack.Item>{' '}
                </Stack>{' '}
              </Section>{' '}
            </Box>{' '}
            <Stack justify="space-around">
              {' '}
              {['WOW', 'FLUTTER'].map((section) => (
                <Stack.Item basis="48%" key={section}>
                  {' '}
                  <Box style={moduleStyle}>
                    {' '}
                    <Section
                      title={section}
                      level={2}
                      style={{ padding: '0.2em', color: '#ccc' }}
                    >
                      {' '}
                      <Stack justify="space-around">
                        {' '}
                        <KnobControl
                          label="DEPTH"
                          value={
                            section === 'WOW'
                              ? data.wow_depth || 0
                              : data.flutter_depth || 0
                          }
                          action={`set_${section.toLowerCase()}_depth`}
                          min={0}
                          max={100}
                          step={1}
                        />{' '}
                        <KnobControl
                          label="RATE"
                          value={
                            section === 'WOW'
                              ? data.wow_rate || 0
                              : data.flutter_rate || 0
                          }
                          action={`set_${section.toLowerCase()}_rate`}
                          min={0}
                          max={100}
                          step={1}
                        />{' '}
                      </Stack>{' '}
                    </Section>{' '}
                  </Box>{' '}
                </Stack.Item>
              ))}{' '}
            </Stack>{' '}
            <Box style={moduleStyle}>
              {' '}
              <Section
                title="DROPOUTS"
                level={2}
                style={{ padding: '0.2em', color: '#ccc' }}
              >
                {' '}
                <Stack justify="space-around">
                  {' '}
                  <KnobControl
                    label="WIDTH"
                    value={data.dropout_width || 0}
                    action="set_dropout_width"
                    min={0}
                    max={100}
                    step={1}
                  />{' '}
                  <KnobControl
                    label="INTENSITY"
                    value={data.dropout_intensity || 0}
                    action="set_dropout_intensity"
                    min={0}
                    max={100}
                    step={1}
                  />{' '}
                </Stack>{' '}
              </Section>{' '}
            </Box>{' '}
          </Stack.Item>{' '}
          <Stack.Item basis="30%" style={{ paddingLeft: '1em' }}>
            {' '}
            <Stack justify="space-around">
              {' '}
              <Stack.Item basis="48%">
                {' '}
                <Box style={moduleStyle}>
                  {' '}
                  <Section
                    title="MIX"
                    level={2}
                    style={{ padding: '0.2em', color: '#ccc' }}
                  >
                    {' '}
                    <Stack justify="space-around">
                      {' '}
                      <KnobControl
                        label="TAPE"
                        value={data.tape_mix || 100}
                        action="set_tape_mix"
                        min={0}
                        max={100}
                        step={1}
                      />{' '}
                      <KnobControl
                        label="COMP"
                        value={data.comp_mix || 0}
                        action="set_comp_mix"
                        min={0}
                        max={100}
                        step={1}
                      />{' '}
                    </Stack>{' '}
                  </Section>{' '}
                </Box>{' '}
              </Stack.Item>{' '}
              <Stack.Item basis="48%">
                {' '}
                <Box style={moduleStyle}>
                  {' '}
                  <Section
                    title="NR COMP."
                    level={2}
                    style={{ padding: '0.2em', color: '#ccc' }}
                  >
                    {' '}
                    <Stack justify="space-around">
                      {' '}
                      <KnobControl
                        label="BRIGHT."
                        value={data.nr_bright || 0}
                        action="set_nr_bright"
                        min={0}
                        max={100}
                        step={1}
                      />{' '}
                      <KnobControl
                        label="AMOUNT"
                        value={data.nr_amount || 0}
                        action="set_nr_amount"
                        min={0}
                        max={100}
                        step={1}
                      />{' '}
                    </Stack>{' '}
                    <ActionButton
                      content={'ON / OFF'}
                      selected={data.nr_comp_on}
                      onClick={() => act('toggle_nr_comp')}
                      style={{ width: '100%', marginTop: '0.5em' }}
                    />{' '}
                  </Section>{' '}
                </Box>{' '}
              </Stack.Item>{' '}
            </Stack>{' '}
            <hr
              style={{
                borderTop: '1px solid #555',
                marginTop: '0.5em',
                marginBottom: '0.5em',
              }}
            />{' '}
            <Box style={moduleStyle}>
              {' '}
              <Section
                title="Track Selector"
                level={2}
                style={{ padding: '0.2em', color: '#ccc' }}
              >
                {' '}
                <Dropdown
                  overflow-y="scroll"
                  width="100%"
                  options={songs.map((song) => song.name)}
                  disabled={active}
                  selected={track_selected || 'Select a Track'}
                  onSelected={(value) => act('select_track', { track: value })}
                />{' '}
                <ActionButton
                  icon={'minus'}
                  content={'Remove Selected Song'}
                  onClick={() => act('remove')}
                  className="mt-1 Button--red"
                />{' '}
              </Section>{' '}
            </Box>{' '}
            <Box style={moduleStyle}>
              {' '}
              <Section
                title="Data Port"
                level={2}
                style={{ padding: '0.2em', color: '#ccc' }}
              >
                {' '}
                <Input
                  placeholder="Paste URL/Data here..."
                  onCommit={(e, value) => act('url', { url: value })}
                />{' '}
                <ActionButton
                  icon={'plus'}
                  content={'Load Data'}
                  onClick={() => act('url')}
                  className="mt-1 Button--green"
                />{' '}
              </Section>{' '}
            </Box>{' '}
            <ActionButton
              icon={'eject'}
              content={'EJECT CARTRIDGE'}
              onClick={() => act('eject')}
              className="mt-2 Button--orange"
              style={{ width: '100%', fontWeight: 'bold', padding: '0.5em' }}
            />{' '}
          </Stack.Item>{' '}
        </Stack>{' '}
      </Window.Content>{' '}
    </Window>
  );
};
