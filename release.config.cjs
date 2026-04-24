// eslint-disable-next-line no-undef
const process = require('process')
// eslint-disable-next-line no-undef
const fs = require('fs')

// Check for the existence of the commit partial file
if (!fs.existsSync('./release-commit-partial.hbs')) {
  console.error('\x1b[31m✘\x1b[0m The commit partial file does not exist.')

  process.exit(1)
}

let commitPartial
try {
  commitPartial = fs.readFileSync('./release-commit-partial.hbs', 'utf8')
} catch (error) {
  console.error('\x1b[31m✘\x1b[0m An error occurred while reading the partial file.')
  process.exit(1)
}

/**
 * @type {import('semantic-release').GlobalConfig}
 */
// eslint-disable-next-line no-undef
module.exports = {
  branches: ['main'],
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits',
        releaseRules: [
          { breaking: true, release: 'major' },
          { type: 'feat', release: 'minor' },
          { type: 'fix', release: 'patch' },
          { type: 'build', release: 'patch' },
          { type: 'chore', release: 'patch' },
          { type: 'ci', release: 'patch' },
          { type: 'docs', release: 'patch' },
          { type: 'style', release: 'patch' },
          { type: 'refactor', release: 'patch' },
          { type: 'perf', release: 'patch' },
          { type: 'test', release: 'patch' },
        ],
      },
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        presetConfig: {
          issuePrefixes: ['APP-'],
          issueUrlFormat: 'https://delupay.atlassian.net/browse/{{prefix}}{{id}}',
          types: [
            { type: 'feat', section: 'Features' },
            { type: 'fix', section: 'Bug Fixes' },
            { type: 'build', section: 'Dependencies Updates' },
            { type: 'chore', section: 'Maintenance' },
            { type: 'ci', section: 'CI/CD' },
            { type: 'docs', section: 'Documentation' },
            { type: 'style', section: 'Styles' },
            { type: 'refactor', section: 'Refactor' },
            { type: 'perf', section: 'Performance' },
            { type: 'test', section: 'Tests' },
          ],
        },
        writerOpts: {
          commitPartial,
        },
      },
    ],
    [
      '@semantic-release/npm',
      {
        npmPublish: false,
      },
    ],
    '@semantic-release/gitlab',
  ],
}
