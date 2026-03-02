'use strict';

const chalk = require('chalk');

function help() {
  console.log('');
  console.log(chalk.cyan('╔══════════════════════════════════════════════╗'));
  console.log(chalk.cyan('║              github-gui commands             ║'));
  console.log(chalk.cyan('╚══════════════════════════════════════════════╝'));
  console.log('');

  console.log(chalk.yellow('  GUIs'));
  row('gcb',  'interactive branch creator');
  row('gc',   'interactive commit + push');
  console.log('');

  console.log(chalk.yellow('  Shortcuts'));
  row('ga',   'git add');
  row('gb',   'git branch');
  row('gbD',  'git branch -D   (force delete)');
  row('gco',  'git checkout');
  row('gd',   'git diff');
  row('gpl',  'git pull');
  row('gps',  'git push');
  row('gs',   'git switch');
  row('gst',  'git status');
  console.log('');

  console.log(chalk.yellow('  Help'));
  row('ghelp', 'show this list');
  console.log('');
}

function row(alias, description) {
  console.log(`  ${chalk.green(alias.padEnd(6))}  ${chalk.white(description)}`);
}

module.exports = { help };
