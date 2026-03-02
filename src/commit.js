'use strict';

const inquirer = require('inquirer');
const { execSync } = require('child_process');
const chalk = require('chalk');

async function commit() {
  // Show staged changes
  let staged;
  try {
    staged = execSync('git diff --cached --stat', { encoding: 'utf8' });
  } catch {
    console.error(chalk.red('✗ Not inside a git repository.'));
    process.exit(1);
  }

  if (!staged.trim()) {
    console.log(chalk.yellow('\n⚠  No staged changes found. Run git add first.\n'));
    process.exit(1);
  }

  console.log(chalk.cyan('\n📋 Staged changes:\n'));
  console.log(staged);

  const { type } = await inquirer.prompt([
    {
      type: 'list',
      name: 'type',
      message: 'Commit type:',
      choices: [
        { name: '✨  FEATURE  – new feature',  value: 'FEATURE' },
        { name: '🐛  BUGFIX   – bug fix',       value: 'BUGFIX'  },
        { name: '🔥  HOTFIX   – urgent fix',    value: 'HOTFIX'  },
        { name: '⏪  REVERT   – revert change', value: 'REVERT'  },
        { name: '🔖  BUMP     – version bump',  value: 'BUMP'    },
      ],
    },
  ]);

  const { message } = await inquirer.prompt([
    {
      type: 'input',
      name: 'message',
      message: 'Commit message:',
      validate: (v) => (v.trim() ? true : 'Message cannot be empty'),
    },
  ]);

  const commitMsg = `${type}: ${message.trim()}`;
  console.log(chalk.green(`\n✅ Committing: "${commitMsg}"\n`));

  try {
    execSync(`git commit -m ${JSON.stringify(commitMsg)}`, { stdio: 'inherit' });
  } catch {
    console.error(chalk.red('\n✗ Commit failed.'));
    process.exit(1);
  }

  const branch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8' }).trim();
  console.log(chalk.cyan(`\n🚀 Pushing to origin/${branch}...\n`));

  try {
    execSync(`git push origin ${branch}`, { stdio: 'inherit' });
    console.log(chalk.green('\n✅ Done!\n'));
  } catch {
    console.error(chalk.red('\n✗ Push failed. You may need to set the upstream or check your connection.'));
    process.exit(1);
  }
}

module.exports = { commit };
