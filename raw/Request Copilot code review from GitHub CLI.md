---
title: "Request Copilot code review from GitHub CLI"
source: "https://github.blog/changelog/2026-03-11-request-copilot-code-review-from-github-cli/?utm_source=github&utm_medium=email&utm_campaign=FY26APR-WW-LCM-PL-X-AA-Admin-PRM-X-701Kg000000PiEPIA0"
author:
  - "[[Allison]]"
published: 2026-03-11
created: 2026-04-14
description: "You can now request a review from GitHub Copilot directly from your terminal using the GitHub CLI. Whether you’re editing an existing pull request or creating a new one, Copilot…"
tags:
  - "clippings"
---
You can now request a review from GitHub Copilot directly from your terminal using the GitHub CLI. Whether you’re editing an existing pull request or creating a new one, Copilot is available as a reviewer option in `gh pr edit` and `gh pr create`. There’s no need to switch to the browser.

## How it works

**Non-interactive:** Add Copilot as a reviewer with `gh pr edit --add-reviewer @copilot`.

![A terminal showing gh pr create with the reviewer copilot flag, creating a pull request and outputting the pull request URL](https://github.com/user-attachments/assets/bddd22ab-ff4d-4a07-a9ae-9e4c3d461d19)

**Interactive:** When you select reviewers through the interactive prompts, Copilot appears alongside your teammates.

![The GitHub CLI interactive reviewer selection prompt showing a search for "monalisa", with Copilot selected as a reviewer](https://github.com/user-attachments/assets/45544789-2ad8-41a0-825c-549ac78b00ea)

## Faster reviewer and assignee selection

This release also introduces a search-based experience for selecting reviewers and assignees. Instead of loading all collaborators and teams upfront, results are now fetched as you type. This dramatically improves performance for large organizations and resolves accessibility issues where screen readers were reading thousands of options aloud.

## Who can use this

This feature is available on all [plans that include Copilot code review](https://docs.github.com/copilot/concepts/agents/code-review#availability). [Install or upgrade](https://github.com/cli/cli?tab=readme-ov-file#installation) to GitHub CLI [v2.88.0](https://github.com/cli/cli/releases/tag/v2.88.0) or later to get started.

For more details, check out [the GitHub CLI release notes](https://github.com/cli/cli/releases). To learn more about Copilot code review, visit the [Copilot code review documentation](https://docs.github.com/copilot/using-github-copilot/code-review/using-copilot-code-review).

Have feedback or run into an issue? [Open an issue in the cli/cli repository](https://github.com/cli/cli/issues).

[

Back to top

](#start-of-content)