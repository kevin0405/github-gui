'use strict';

const inquirer = require('inquirer');
const { execSync } = require('child_process');
const chalk = require('chalk');

function toSlug(str) {
  return str
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '');
}

async function branch() {
  const { type } = await inquirer.prompt([
    {
      type: 'list',
      name: 'type',
      message: 'Branch type:',
      choices: [
        { name: '✨  feature  – new feature', value: 'feature' },
        { name: '🐛  bugfix   – bug fix',     value: 'bugfix'  },
        { name: '🔥  hotfix   – urgent fix',  value: 'hotfix'  },
        { name: '🔖  bump     – version bump', value: 'bump'   },
      ],
    },
  ]);

  const { ticket } = await inquirer.prompt([
    {
      type: 'input',
      name: 'ticket',
      message: 'Ticket / Task ID (e.g. SMN-222, leave empty to skip):',
      filter: (v) => v.trim().toUpperCase(),
    },
  ]);

  const { description } = await inquirer.prompt([
    {
      type: 'input',
      name: 'description',
      message: 'Short description (becomes the branch slug):',
      validate: (v) => (v.trim() ? true : 'Description cannot be empty'),
    },
  ]);

  const branchName = ticket
    ? `${type}/${ticket}/${toSlug(description)}`
    : `${type}/${toSlug(description)}`;

  console.log(chalk.cyan(`\n🌿 Creating branch: ${chalk.bold(branchName)}\n`));

  try {
    execSync(`git checkout -b ${branchName}`, { stdio: 'inherit' });
    console.log(chalk.green(`\n✅ Switched to new branch '${branchName}'\n`));
  } catch {
    console.error(chalk.red('\n✗ Branch creation failed. The branch may already exist.'));
    process.exit(1);
  }
}

module.exports = { branch };
