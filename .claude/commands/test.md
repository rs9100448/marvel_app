---
description: Run the MarvelApp unit test suite via Fastlane and report results
allowed-tools: Bash(bundle exec fastlane test:*)
---

Run the unit tests with:

```bash
bundle exec fastlane test
```

Then report:
- Whether the run passed or failed (`TEST SUCCEEDED` / `TEST FAILED`).
- The count of passing/failing tests, and for any failure, the test name and the
  assertion message.

Notes:
- Use `bundle exec` so the pinned Fastlane/Ruby (rbenv 3.3.6) is used — the system
  Ruby crashes with SIGKILL.
- Do not change app code to make a test pass unless I ask; just report failures.
