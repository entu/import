import stylistic from '@stylistic/eslint-plugin'
import unicorn from 'eslint-plugin-unicorn'

import guardBraces from './eslint-guard-braces.js'

export default [
  {
    ignores: ['.claude/']
  },
  {
    plugins: {
      '@stylistic': stylistic,
      entu: { rules: { 'guard-braces': guardBraces } },
      unicorn
    },
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module'
    },
    rules: {
      // Guard clauses stay inline and brace-less (`if (x) return` /
      // `continue` / `break` — value-less only); every other if/else/loop
      // body, including `return <value>`, must be a multiline braced
      // block. Enforced by three rules together:
      // - curly multi-line: anything spanning lines needs braces
      // - nonblock-statement-body-position: a brace-less body sits on the
      //   same line as its `if`
      // - entu/guard-braces (local, auto-fixable): only a bare guard may
      //   go brace-less, and a block holding ONLY a bare guard is inlined
      curly: ['error', 'multi-line'],
      '@stylistic/nonblock-statement-body-position': ['error', 'beside'],
      'entu/guard-braces': 'error',
      '@stylistic/arrow-parens': ['error', 'always'],
      '@stylistic/brace-style': ['error', 'stroustrup'],
      '@stylistic/comma-dangle': ['error', 'never'],
      '@stylistic/eol-last': 'error',
      '@stylistic/indent': ['error', 2],
      '@stylistic/no-multi-spaces': 'error',
      '@stylistic/no-multiple-empty-lines': ['error', { max: 1 }],
      '@stylistic/no-trailing-spaces': 'error',
      '@stylistic/object-curly-spacing': ['error', 'always'],
      '@stylistic/quote-props': ['error', 'as-needed'],
      '@stylistic/quotes': ['error', 'single'],
      '@stylistic/semi': ['error', 'never'],
      '@stylistic/space-before-function-paren': ['error', 'always'],
      'unicorn/no-duplicate-if-branches': 'error',
      'unicorn/no-for-each': 'error',
      'unicorn/no-lonely-if': 'error',
      'unicorn/no-useless-undefined': 'error',
      'unicorn/prefer-array-flat-map': 'error',
      'unicorn/prefer-at': 'error',
      'unicorn/prefer-boolean-return': 'error',
      'unicorn/prefer-date-now': 'error',
      'unicorn/prefer-early-return': 'error',
      'unicorn/prefer-else-if': 'error',
      'unicorn/prefer-includes': 'error',
      'unicorn/prefer-number-properties': 'error',
      'unicorn/prefer-simplified-conditions': 'error',
      'unicorn/prefer-string-slice': 'error'
    }
  }
]
