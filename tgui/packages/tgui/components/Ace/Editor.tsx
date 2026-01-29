import { useEffect, useRef, useState } from 'react';
import ace from 'ace-builds';

import 'ace-builds/src-noconflict/theme-tomorrow_night';
import 'ace-builds/src-noconflict/mode-lua';
import 'ace-builds/src-noconflict/mode-text';
import 'ace-builds/src-noconflict/ext-options';
import 'ace-builds/src-noconflict/ext-language_tools';
import 'ace-builds/src-noconflict/ext-searchbox';
import 'ace-builds/src-noconflict/ext-statusbar';
import { BoxProps } from '../Box';
import { computeBoxClassName, computeBoxProps } from 'tgui-core/ui';
import { classes } from 'common/react';
import { NTSLMode } from './languages/ntsl';

type Props = {
  value?: string;
  language?: 'lua' | 'text' | 'ntsl';
  readOnly?: boolean;
  onChange?: (value: string) => void;
  onCtrlS?: (value: string) => boolean;
  onCtrlShiftB?: (value: string) => boolean;
  debounceTime?: number;
} & BoxProps;

const DEFAULT_DEBOUNCE_TIME = 500;

export function AceEditor(props: Props) {
  const {
    value,
    language,
    readOnly,
    debounceTime = DEFAULT_DEBOUNCE_TIME,
    onChange,
    onCtrlS,
    onCtrlShiftB,
    ...rest
  } = props;

  const containerRef = useRef<HTMLDivElement | null>(null);
  const editorRef = useRef<ace.Ace.Editor | null>(null);
  const suppressChangeRef = useRef(false);
  const debounceTimerRef = useRef<number | null>(null);

  const lastSentValueRef = useRef('');
  const lastRemoteValueRef = useRef<string | undefined>(undefined);
  const hasReceivedInitialValueRef = useRef(false);

  const [isSynced, setIsSynced] = useState(true);

  const sendCurrentValue = (fromCtrlS = false, fromCtrlShiftB = false) => {
    const editor = editorRef.current;
    if (!editor) return false;

    const current = editor.getValue();
    if (current === lastSentValueRef.current) return false;

    lastSentValueRef.current = current;
    onChange?.(current);
    if (fromCtrlS && onCtrlS) onCtrlS(current);
    if (fromCtrlShiftB && onCtrlShiftB) onCtrlShiftB(current);

    const synced = lastRemoteValueRef.current === current;
    setIsSynced(synced);
    return true;
  };

  const showSavedPopup = (text = 'Saved') => {
    const editor = editorRef.current;
    if (!editor) return;

    const pos = editor.getCursorPosition();
    const coords = editor.renderer.textToScreenCoordinates(pos.row, pos.column);

    const popup = document.createElement('div');
    popup.textContent = text;
    Object.assign(popup.style, {
      position: 'fixed',
      left: `${coords.pageX + 8}px`,
      top: `${coords.pageY - 20}px`,
      padding: '2px 6px',
      fontSize: '11px',
      background: 'rgba(0, 0, 0, 0.85)',
      color: '#fff',
      borderRadius: '4px',
      pointerEvents: 'none',
      zIndex: '9999',
      opacity: '1',
      transition: 'opacity 150ms ease-out',
    });

    document.body.appendChild(popup);

    setTimeout(() => {
      popup.style.opacity = '0';
      setTimeout(() => popup.remove(), 150);
    }, 700);
  };

  useEffect(() => {
    const editor = ace.edit(containerRef.current!);
    editorRef.current = editor;

    editor.setTheme('ace/theme/tomorrow_night');
    if (language === 'ntsl') {
      editor.session.setMode(new NTSLMode());
    } else {
      editor.session.setMode(`ace/mode/${language ?? 'text'}`);
    }

    editor.setOptions({
      fontSize: '12px',
      showPrintMargin: false,
      wrap: true,
      readOnly: readOnly ?? false,
      enableLiveAutocompletion: true,
      enableBasicAutocompletion: true,
      useWorker: false,
    });

    if (value !== undefined) {
      suppressChangeRef.current = true;
      editor.setValue(value);
      lastSentValueRef.current = value;
      lastRemoteValueRef.current = value;
      hasReceivedInitialValueRef.current = true;
      suppressChangeRef.current = false;
    }

    editor.session.on('change', () => {
      if (suppressChangeRef.current) return;

      setIsSynced(false);

      if (debounceTimerRef.current !== null) {
        clearTimeout(debounceTimerRef.current);
      }

      debounceTimerRef.current = window.setTimeout(() => {
        debounceTimerRef.current = null;
        sendCurrentValue();
      }, debounceTime);
    });

    editor.commands.addCommand({
      name: 'save',
      bindKey: { win: 'Ctrl-S', mac: 'Command-S' },
      exec: () => {
        if (debounceTimerRef.current !== null) {
          clearTimeout(debounceTimerRef.current);
          debounceTimerRef.current = null;
        }
        if (sendCurrentValue(true)) {
          showSavedPopup();
        }
      },
    });

    // this really should be a prop for each combination tbh.
    editor.commands.addCommand({
      name: 'saveAndRun',
      bindKey: { win: 'Ctrl-Shift-B', mac: 'Command-Shift-B' },
      exec: async () => {
        if (debounceTimerRef.current !== null) {
          clearTimeout(debounceTimerRef.current);
          debounceTimerRef.current = null;
        }
        if (sendCurrentValue(false, true)) {
          showSavedPopup('Saved & Compiled');
        }
      },
    });

    return () => {
      if (debounceTimerRef.current !== null) {
        clearTimeout(debounceTimerRef.current);
      }
      editor.destroy();
      editorRef.current = null;
    };
  }, []);

  // language change
  useEffect(() => {
    const editor = editorRef.current;
    if (!editor) return;

    if (language === 'ntsl') {
      editor.session.setMode(new NTSLMode());
    } else {
      editor.session.setMode(`ace/mode/${language ?? 'text'}`);
    }
  }, [language]);

  useEffect(() => {
    const editor = editorRef.current;
    if (!editor) return;

    editor.setReadOnly(readOnly ?? false);
  }, [readOnly]);

  useEffect(() => {
    const editor = editorRef.current;
    if (!editor || value === undefined) return;

    if (value !== lastRemoteValueRef.current) {
      const current = editor.getValue();

      if (!hasReceivedInitialValueRef.current || current !== value) {
        suppressChangeRef.current = true;
        editor.setValue(value);
        lastSentValueRef.current = value;
        suppressChangeRef.current = false;
        hasReceivedInitialValueRef.current = true;
      }

      lastRemoteValueRef.current = value;
      setIsSynced(lastSentValueRef.current === value);
    }
  }, [value]);

  return (
    <div
      style={{
        width: '100%',
        height: '100%',
      }}
    >
      <div
        className={classes([computeBoxClassName(rest)])}
        ref={containerRef}
        {...computeBoxProps({
          ...rest,
          style: {
            width: '100%',
            height: '100%',
            position: 'relative',
            ...rest.style,
          },
        })}
      />
      <div
        title={isSynced ? 'All changes saved' : 'Unsaved changes'}
        style={{
          position: 'absolute',
          bottom: '1em',
          left: '1em',
          width: '16px',
          height: '16px',
          zIndex: 4,
          borderRadius: '50%',
          backgroundColor: isSynced ? '#3fb950' : '#3b82f6',
          boxShadow: '0 0 4px rgba(0,0,0,0.6)',
          pointerEvents: 'none',
        }}
      />
    </div>
  );
}
