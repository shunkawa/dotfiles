#!/usr/bin/env node

const execa = require('execa');
const path = require('path');
const vfileReporterJson = require('vfile-reporter-json');

const [, , ...args] = process.argv;

execa(
  path.resolve(path.join(__dirname, 'node_modules', '.bin', 'remark')),
  [
    '--rc-path',
    path.resolve(path.join(__dirname, 'remarkrc.json')),
    '--no-stdout',
    ...args.map((element, index, array) => {
      // If `--report json` is passed as an argument, replace `json` with the
      // full path to the vfile-reporter-json module.
      if (element === 'json' && array[index - 1] === '--report') {
        return require.cache[require.resolve('vfile-reporter-json')].filename;
      }
      return element;
    }),
  ],
  { stdio: 'inherit' },
).catch((error) => {
  if (error && error.exitCode) {
    process.exit(error.exitCode);
  }

  process.exit(1);
});
