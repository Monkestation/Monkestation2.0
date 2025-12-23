import { Mode as TextMode } from 'ace-builds/src-noconflict/mode-text';
import { TextHighlightRules } from './text_highlight_rules';

export class NTSLHighlightRules extends TextHighlightRules {
  constructor(config?: any) {
    super();

    this.$rules = {
      start: [
        // Comments
        { regex: /\/\/.*$/, token: 'comment.line.ntsl' },
        { regex: /\/\*[\s\S]*?\*\//, token: 'comment.block.ntsl' },

        // Message variables
        {
          regex:
            /\$(source|content|freq|job|pass|language|common|science|command|medical\$engineering|security|supply|service)\b/,
          token: 'variable.language.ntsl',
        },

        // Strings
        { regex: /"(?:[^"\\]|\\.)*"/, token: 'string.ntsl' },

        // Keywords / control
        {
          regex: /\b(if|else|elseif|def|return|while|break|continue)\b/,
          token: 'keyword.control.ntsl',
        },

        // Constant functions
        {
          regex: /\b(vector|at|signal|broadcast|mem)\b/,
          token: 'support.function.ntsl',
        },

        // User functions (detect function call)
        { regex: /\b([\w_]+)\(/, token: 'support.function.ntsl' },

        // Variables
        { regex: /\$[\w_]+\b/, token: 'variable.name.ntsl' },

        // Operators
        {
          regex: /[\+\-\/\*\(\)\{\}\;\=\,\|\&\~\^\!\%\<\>]/,
          token: 'keyword.operator.ntsl',
        },

        // Values
        {
          regex: /\b(PI|E|SQURT2|FALSE|TRUE|NORTH|SOUTH|EAST|WEST)\b/,
          token: 'storage.type.ntsl',
        },

        // Numbers
        { regex: /\b\d+\b/, token: 'constant.numeric.ntsl' },
      ],
    };

    this.normalizeRules();
  }
}

export class NTSLMode extends TextMode {
  $id: string;
  $highlightRules: { start: { regex: RegExp; token: string }[] };
  constructor() {
    super();
    this.HighlightRules = NTSLHighlightRules;
    this.$id = 'ace/mode/ntsl';
  }

  getRules() {
    return this.$highlightRules;
  }
}
