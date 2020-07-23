#!/usr/bin/env node

const execa = require('execa');
const path = require('path');

const [, , ...args] = process.argv;

execa(
  path.resolve(path.join(__dirname, 'node_modules', '.bin', 'remark')),
  [
    '--rc-path',
    path.resolve(path.join(__dirname, 'remarkrc.json')),
    '--no-stdout',
    ...args,
  ],
  { stdio: 'inherit' },
);
