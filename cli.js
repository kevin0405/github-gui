#!/usr/bin/env node
'use strict';

const command = process.argv[2];

switch (command) {
  case 'commit':
    require('./src/commit').commit().catch((err) => {
      console.error(err);
      process.exit(1);
    });
    break;
  case 'branch':
    require('./src/branch').branch().catch((err) => {
      console.error(err);
      process.exit(1);
    });
    break;
  case 'help':
    require('./src/help').help();
    break;
  default:
    console.error(`Usage: github-gui <commit|branch|help>`);
    process.exit(1);
}
