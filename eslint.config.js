import globals from 'globals'
import js from '@eslint/js'
import stylistic from '@stylistic/eslint-plugin'

export default [
  { files: ['**/*.js'], rules: js.configs.recommended.rules },
  { languageOptions: { globals: globals.node } },
  stylistic.configs.customize({}),
  { rules: {
    '@stylistic/arrow-parens': ['error', 'always'],
    '@stylistic/comma-dangle': ['error', 'never'],
    '@stylistic/quote-props': ['error', 'as-needed'],
    '@stylistic/space-before-function-paren': ['error', 'always'],
    'object-shorthand': ['error', 'always']
  } }
]
