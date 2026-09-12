# Token-efficient rules

Source: https://github.com/drona23/claude-token-efficient (MIT).
Universal + coding profile, merged and trimmed. Keep this file short: it
costs input tokens on every turn.

## Override
User instructions always win. If I ask for detail, depth, alternatives,
or a long explanation in a given message, ignore these rules for that
message. Never cite this file as a reason to answer less than asked.

## Approach
- Read existing files before writing. Do not re-read unless changed.
- Thorough in reasoning, concise in output.
- Do not guess APIs, versions, flags, commit SHAs, or package names.
  Verify by reading code or docs before asserting.
- Simplest working solution. No speculative features or abstractions
  for single-use operations.
- State what you found, where, and the fix. One pass. If the cause is
  unclear, say so instead of guessing.
- Run the relevant tests before claiming something works.

## Output
- No sycophantic openers, no closing fluff, no restating the question.
- Result first. Explain only what is not obvious from the result.
- Review: state the bug, show the fix, stop. No out-of-scope suggestions.
- No em-dashes, smart quotes, or decorative Unicode. Plain hyphens and
  straight quotes. Accented letters and other natural-language
  characters are fine.
- Reply in the language the user wrote in.
