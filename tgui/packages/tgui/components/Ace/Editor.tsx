import { Component } from 'inferno';
import ace from 'ace-builds';

import 'ace-builds/src-noconflict/theme-tomorrow_night';
import 'ace-builds/src-noconflict/mode-lua';
import 'ace-builds/src-noconflict/mode-text';
import 'ace-builds/src-noconflict/ext-searchbox';
import 'ace-builds/src-noconflict/ext-statusbar';
import { BoxProps, computeBoxClassName, computeBoxProps } from '../Box';
import { classes } from 'common/react';
import { NTSLMode } from './languages/ntsl';

type Props = {
  value?: string;
  language?: 'lua' | 'text' | 'ntsl';
  readOnly?: boolean;
  onChange?: (value: string) => void;
} & BoxProps;

export class AceEditor extends Component<Props> {
  private container?: HTMLDivElement;
  private editor?: ace.Ace.Editor;
  private suppressChange = false;
  private debounceTimer: number | null = null;

  private lastSentValue = '';
  private lastRemoteValue?: string;
  private isSynced = true;
  private hasReceivedInitialValue = false;

  componentDidMount() {
    this.editor = ace.edit(this.container!);

    this.editor.setTheme('ace/theme/tomorrow_night');
    if (this.props.language === 'ntsl') {
      this.editor.session.setMode(new NTSLMode());
    } else {
      this.editor.session.setMode(`ace/mode/${this.props.language ?? 'text'}`);
    }

    this.editor.setOptions({
      fontSize: '12px',
      showPrintMargin: false,
      wrap: true,
      readOnly: this.props.readOnly ?? false,
      enableLiveAutocompletion: true,
      enableBasicAutocompletion: true,
    });

    if (this.props.value !== undefined) {
      this.suppressChange = true;
      this.editor.setValue(this.props.value);
      this.lastSentValue = this.props.value;
      this.lastRemoteValue = this.props.value;
      this.hasReceivedInitialValue = true;
      this.suppressChange = false;
    }

    this.editor.session.on('change', () => {
      if (this.suppressChange) return;

      this.isSynced = false;
      this.forceUpdate();

      if (this.debounceTimer !== null) clearTimeout(this.debounceTimer);
      this.debounceTimer = window.setTimeout(() => {
        this.debounceTimer = null;
        this.sendCurrentValue();
      }, 200);
    });

    this.editor.commands.addCommand({
      name: 'save',
      bindKey: { win: 'Ctrl-S', mac: 'Command-S' },
      exec: () => {
        if (!this.editor) return;
        if (this.debounceTimer !== null) {
          clearTimeout(this.debounceTimer);
          this.debounceTimer = null;
        }
        if (this.sendCurrentValue()) this.showSavedPopup();
      },
    });
  }

  sendCurrentValue(): boolean {
    if (!this.editor) return false;
    const value = this.editor.getValue();
    if (value === this.lastSentValue) return false;

    this.lastSentValue = value;
    this.props.onChange?.(value);
    // mark as dirty until server echoes back
    this.isSynced = this.lastRemoteValue === value;
    this.forceUpdate();
    return true;
  }

  showSavedPopup(text = 'Saved') {
    if (!this.editor) return;

    const pos = this.editor.getCursorPosition();
    const coords = this.editor.renderer.textToScreenCoordinates(
      pos.row,
      pos.column,
    );

    const popup = document.createElement('div');
    popup.textContent = text;
    popup.style.position = 'fixed';
    popup.style.left = `${coords.pageX + 8}px`;
    popup.style.top = `${coords.pageY - 20}px`;
    popup.style.padding = '2px 6px';
    popup.style.fontSize = '11px';
    popup.style.background = 'rgba(0, 0, 0, 0.85)';
    popup.style.color = '#fff';
    popup.style.borderRadius = '4px';
    popup.style.pointerEvents = 'none';
    popup.style.zIndex = '9999';
    popup.style.opacity = '1';
    popup.style.transition = 'opacity 150ms ease-out';

    document.body.appendChild(popup);

    setTimeout(() => {
      popup.style.opacity = '0';
      setTimeout(() => popup.remove(), 150);
    }, 700);
  }

  componentDidUpdate(prev: Props) {
    if (!this.editor) return;

    if (prev.language !== this.props.language) {
      if (this.props.language === 'ntsl')
        this.editor.session.setMode(new NTSLMode());
      else
        this.editor.session.setMode(
          `ace/mode/${this.props.language ?? 'text'}`,
        );
    }

    if (prev.readOnly !== this.props.readOnly) {
      this.editor.setReadOnly(this.props.readOnly ?? false);
    }

    if (
      this.props.value !== undefined &&
      this.props.value !== this.lastRemoteValue
    ) {
      const current = this.editor.getValue();

      if (!this.hasReceivedInitialValue || current !== this.props.value) {
        this.suppressChange = true;
        this.editor.setValue(this.props.value); // preserve cursor
        this.lastSentValue = this.props.value;
        this.suppressChange = false;

        this.hasReceivedInitialValue = true;
      }

      this.lastRemoteValue = this.props.value;
      this.isSynced = this.lastSentValue === this.lastRemoteValue;
      this.forceUpdate();
    }
  }

  componentWillUnmount() {
    if (this.debounceTimer !== null) clearTimeout(this.debounceTimer);
    this.editor?.destroy();
    this.container = undefined;
  }

  render() {
    const { onChange, language, value, ...rest } = this.props;
    return (
      <div
        className={classes([computeBoxClassName(rest)])}
        ref={(el) => (this.container = el!)}
        style={{ width: '100%', height: '100%', position: 'relative' }}
        {...computeBoxProps(rest)}
      >
        <div
          style={{
            position: 'absolute',
            bottom: '1em',
            left: '1em',
            width: '16px',
            height: '16px',
            'z-index': 4,
            'border-radius': '50%',
            'background-color': this.isSynced ? '#3fb950' : '#3b82f6',
            'box-shadow': '0 0 4px rgba(0,0,0,0.6)',
            'pointer-events': 'none',
          }}
          title={this.isSynced ? 'All changes saved' : 'Unsaved changes'}
        />
      </div>
    );
  }
}
