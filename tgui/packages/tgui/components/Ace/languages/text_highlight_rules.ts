import { Ace } from 'ace-builds';

type Rule = Ace.HighlightRule;
type HighlightRulesMap = Ace.HighlightRulesMap;

function deepCopy(obj) {
  if (typeof obj !== 'object' || !obj) return obj;
  let copy;
  if (Array.isArray(obj)) {
    copy = [];
    for (let key = 0; key < obj.length; key++) {
      copy[key] = deepCopy(obj[key]);
    }
    return copy;
  }
  if (Object.prototype.toString.call(obj) !== '[object Object]') return obj;

  copy = {};
  for (let key in obj) copy[key] = deepCopy(obj[key]);
  return copy;
}

export class TextHighlightRules implements Ace.HighlightRules {
  // regexp must not have capturing parentheses
  // regexps are ordered -> the first match is used
  $rules: HighlightRulesMap = {
    start: [{ token: 'empty_line', regex: '^$' }, { defaultToken: 'text' }],
  };
  $embeds: string[] = [];
  $keywords: any[];
  $keywordList: string[];
  nextState?: string;

  constructor() {}

  addRules(rules: HighlightRulesMap, prefix?: string): void {
    if (!prefix) {
      for (const key in rules) this.$rules[key] = rules[key];
      return;
    }

    for (const key in rules) {
      const state = rules[key];
      for (let i = 0; i < state.length; i++) {
        const rule = state[i];
        if (rule.next || rule.onMatch) {
          if (typeof rule.next === 'string' && !rule.next.startsWith(prefix)) {
            rule.next = prefix + rule.next;
          }
          if (rule.nextState && !rule.nextState.startsWith(prefix)) {
            rule.nextState = prefix + rule.nextState;
          }
        }
      }
      this.$rules[prefix + key] = state;
    }
  }

  getRules(): HighlightRulesMap {
    return this.$rules;
  }

  embedRules(
    rules: HighlightRulesMap | (new () => Ace.HighlightRules),
    prefix: string,
    escapeRules?: boolean,
    append?: boolean,
  ): void {
    const embedded =
      typeof rules === 'function' ? new rules().getRules() : rules;

    this.addRules(embedded, prefix);

    if (escapeRules) {
      for (const key in embedded) {
        const state = this.$rules[prefix + key];
        if (!state) continue;
        const fn = append ? state.push : state.unshift;
        fn.apply(state, deepCopy(state));
      }
    }

    (this.$embeds ??= []).push(prefix);
  }

  getEmbeds(): string[] {
    return this.$embeds;
  }

  normalizeRules(): void {
    let id = 0;
    const rules = this.$rules;

    const pushState = (currentState: string, stack: string[]): string => {
      if (currentState !== 'start' || stack.length)
        stack.unshift(this.nextState!, currentState);
      return this.nextState!;
    };

    const popState = (_currentState: string, stack: string[]): string => {
      // if (stack[0] === currentState)
      stack.shift();
      return stack.shift() || 'start';
    };

    const processState = (key: string) => {
      const state = rules[key];
      // @ts-ignore
      state.processed = true;

      for (let i = 0; i < state.length; i++) {
        let rule = state[i] as Rule;
        let toInsert: Rule[] | null = null;

        if (Array.isArray(rule)) {
          toInsert = rule;
          rule = {} as Rule;
        }

        const next = rule.next || (rule.push as any);
        if (next && Array.isArray(next)) {
          let stateName = rule.stateName || (rule.token as string);
          if (!stateName) stateName = 'state' + id++;
          rules[stateName] = next;
          rule.next = stateName;
          processState(stateName);
        } else if (next === 'pop') {
          rule.next = popState;
        }

        if (rule.push) {
          rule.nextState = rule.next || rule.push;
          rule.next = pushState;
          delete rule.push;
        }

        if (rule.rules) {
          for (const r in rule.rules) {
            if (rules[r]) {
              if ((rules[r] as any).push)
                (rules[r] as any).push.apply(rules[r], rule.rules[r]);
            } else {
              rules[r] = rule.rules[r];
            }
          }
        }

        const includeName =
          typeof rule === 'string'
            ? (rule as string)
            : (rule.include as Rule['include']);
        if (includeName) {
          if (includeName === '$self') toInsert = rules['start'];
          else if (Array.isArray(includeName))
            toInsert = (includeName as Rule['include']).map((x) => rules[x]);
          else toInsert = rules[includeName];
        }

        if (toInsert) {
          const args: any[] = [i, 1, ...toInsert];
          state.splice.apply(state, args);
          // skip included rules since they are already processed
          //i += args.length - 3;
          i--;
        }

        if (rule.keywordMap) {
          rule.token = this.createKeywordMapper(
            rule.keywordMap,
            rule.defaultToken || 'text',
            rule.caseInsensitive,
          );
          delete rule.defaultToken;
        }
      }
    };

    Object.keys(rules).forEach(processState);
  }

  /**
   * @param map DO NOT PASS AS NULL!
   */
  createKeywordMapper(
    map: Record<string, string> | null,
    defaultToken: string,
    ignoreCase?: boolean,
    splitChar?: string,
  ): Ace.KeywordMapper {
    const keywords: Record<string, string> = Object.create(null);
    this.$keywordList = [];
    Object.keys(map!).forEach((className) => {
      const a = map![className];
      const list = a.split(splitChar || '|');
      for (let i = list.length; i--; ) {
        let word = list[i];
        this.$keywordList.push(word);
        if (ignoreCase) word = word.toLowerCase();
        keywords[word] = className;
      }
    });
    map = null;

    return ignoreCase
      ? (value: string) => keywords[value.toLowerCase()] || defaultToken
      : (value: string) => keywords[value] || defaultToken;
  }

  getKeywords(): string[] | undefined {
    return this.$keywords;
  }
}
