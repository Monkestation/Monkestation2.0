import { Box, Button, Flex, Section, TextArea } from 'tgui-core/components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { TEXTAREA_INPUT_HEIGHT } from './PaperSheet/constants';
import { canEdit } from './PaperSheet/helpers';
import { PrimaryView } from './PaperSheet/PrimaryView';
import { PreviewView } from './PaperSheet/Preview';
import { PaperSheetStamper } from './PaperSheet/Stamper';
import { StampView } from './PaperSheet/StampView';
import {
  InteractionType,
  type PaperContext,
  type PaperInput,
} from './PaperSheet/types';

type HRChoice = { id: string; label: string };

type HRPaperContext = PaperContext & {
  hr_can_mark: boolean;
  hr_revision: number;
  hr_choices: HRChoice[];
  hr_targets: HRChoice[];
  hr_selected_option?: string | null;
  hr_selected_target_key?: string | null;
};

class HRPaperPreviewView extends PreviewView {
  render() {
    const { act, data } = useBackend<HRPaperContext>();
    const {
      paper_color,
      held_item_details,
      hr_choices = [],
      hr_targets = [],
      hr_can_mark,
      hr_selected_option,
      hr_selected_target_key,
    } = data;
    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;

    const dmTextPreviewData = this.createPreviewFromDM();
    let previewText = dmTextPreviewData.text;
    if (interactMode === InteractionType.writing) {
      previewText += this.createPreviewFromTextArea(
        dmTextPreviewData.newFieldCount,
      );
    }

    // Checkbox order must match the server-rendered paper.
    const printedMarks = [
      ...hr_targets.map((choice) => ({
        kind: 'hr_mark_target',
        choice,
        checked: hr_selected_target_key === choice.id,
      })),
      ...hr_choices.map((choice) => ({
        kind: 'hr_mark_option',
        choice,
        checked: hr_selected_option === choice.id,
      })),
    ];
    let markIndex = 0;
    const interactivePreview = previewText.replace(
      /□|☐|☑|☒|&#9633;|&#9744;|&#9745;/g,
      (originalMark) => {
        const index = markIndex++;
        const mark = printedMarks[index];
        if (!mark) return originalMark;
        const checked = mark.checked ? '☑' : '☐';
        const disabled = hr_can_mark ? '' : 'disabled';
        return `<button type="button" data-hr-index="${index}" ${disabled} style="border:0;background:transparent;color:inherit;padding:0 2px;cursor:pointer;font:inherit" title="Mark response">${checked}</button>`;
      },
    );

    const { scrollableRef, handleOnScroll } = this.props;
    return (
      <Section
        fill
        fitted
        scrollable
        ref={scrollableRef}
        onScroll={handleOnScroll as any}
      >
        <Box
          fillPositionedParent
          position="relative"
          bottom="100%"
          minHeight="100%"
          backgroundColor={paper_color}
          className="Paper__Page"
          dangerouslySetInnerHTML={{
            __html: `<span className='paper-text'>${interactivePreview}</span>`,
          }}
          onClick={(event) => {
            const element = event.target as HTMLButtonElement;
            if (!hr_can_mark || element?.tagName !== 'BUTTON') return;
            const rawIndex = element.getAttribute('data-hr-index');
            if (rawIndex === null) return;
            const index = Number(rawIndex);
            const entry = printedMarks[index];
            if (!Number.isInteger(index) || !entry) return;
            act(entry.kind, { id: entry.choice.id });
          }}
          p="10px"
        />
        <StampView />
      </Section>
    );
  }
}

class HRPaperPrimaryView extends PrimaryView {
  render() {
    const { act, data } = useBackend<HRPaperContext>();
    const {
      raw_text_input,
      raw_field_input,
      default_pen_font,
      default_pen_color,
      paper_color,
      held_item_details,
      max_length,
    } = data;

    const useFont = held_item_details?.font || default_pen_font;
    const useColor = held_item_details?.color || default_pen_color;
    const useBold = held_item_details?.use_bold || false;
    const [inputFieldData, setInputFieldData] = useLocalState(
      'inputFieldData',
      {},
    );
    const [textAreaText, setTextAreaText] = useLocalState('textAreaText', '');
    const interactMode =
      held_item_details?.interaction_mode || InteractionType.reading;
    const savableData =
      textAreaText.length || Object.keys(inputFieldData).length;
    const dmCharacters =
      raw_text_input?.reduce((lhs: number, rhs: PaperInput) => {
        return lhs + rhs.raw_text.length;
      }, 0) || 0;
    const usedCharacters = dmCharacters + textAreaText.length;
    const tooManyCharacters = usedCharacters > max_length;
    const canEdit = interactMode === InteractionType.writing;

    return (
      <>
        <PaperSheetStamper scrollableRef={this.scrollableRef} />
        <Flex direction="column" fillPositionedParent>
          <Flex.Item grow={3} basis={1}>
            <HRPaperPreviewView
              key={`${raw_field_input?.length || 0}_${
                raw_text_input?.length || 0
              }`}
              scrollableRef={this.scrollableRef}
              handleOnScroll={this.onScrollHandler}
              textArea={textAreaText}
              canEdit={canEdit}
            />
          </Flex.Item>
          {canEdit && (
            <Flex.Item shrink={1} height={`${TEXTAREA_INPUT_HEIGHT}px`}>
              <Section
                title="Insert Text"
                fitted
                fill
                buttons={
                  <>
                    <Box
                      inline
                      pr={'5px'}
                      color={tooManyCharacters ? 'bad' : 'default'}
                    >
                      {`${usedCharacters} / ${max_length}`}
                    </Box>
                    <Button.Confirm
                      disabled={!savableData || tooManyCharacters}
                      color="good"
                      onClick={() => {
                        if (textAreaText.length) {
                          act('add_text', { text: textAreaText });
                          setTextAreaText('');
                        }
                        if (Object.keys(inputFieldData).length) {
                          act('fill_input_field', {
                            field_data: inputFieldData,
                          });
                          setInputFieldData({});
                        }
                      }}
                    >
                      Save
                    </Button.Confirm>
                  </>
                }
              >
                <TextArea
                  style={{ border: 'none' }}
                  value={textAreaText}
                  textColor={useColor}
                  fontFamily={useFont}
                  bold={useBold}
                  height="100%"
                  fluid
                  backgroundColor={paper_color}
                  onChange={(value) => {
                    setTextAreaText(value);
                    if (this.scrollableRef.current) {
                      const thisDistFromBottom =
                        this.scrollableRef.current.scrollHeight -
                        this.scrollableRef.current.scrollTop;
                      this.scrollableRef.current.scrollTop +=
                        thisDistFromBottom - this.lastDistanceFromBottom;
                    }
                  }}
                />
              </Section>
            </Flex.Item>
          )}
        </Flex>
      </>
    );
  }
}

export function CCPostHRPaper() {
  const { data } = useBackend<HRPaperContext>();
  const { paper_color, paper_name, held_item_details, hr_revision } = data;
  const writeMode = canEdit(held_item_details);

  if (!writeMode) {
    const [inputFieldData, setInputFieldData] = useLocalState(
      'inputFieldData',
      {},
    );
    if (Object.keys(inputFieldData).length) {
      setInputFieldData({});
    }
  }

  return (
    <Window
      title={paper_name}
      theme="paper"
      width={420}
      height={500 + (writeMode ? TEXTAREA_INPUT_HEIGHT : 0)}
    >
      <Window.Content backgroundColor={paper_color}>
        <HRPaperPrimaryView key={hr_revision} />
      </Window.Content>
    </Window>
  );
}
