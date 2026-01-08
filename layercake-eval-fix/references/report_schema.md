# Report Parsing Notes

## Report Layout

Layercake reports in `evals\reports` are text files that contain one or more test cases. Each test case typically looks like:

- `Test Case #<n>`
- `Thread ID: <uuid>`
- `Session ID: <session_id>`
- `Metrics Summary:`
  - `- <metric name> (score: <score>, threshold: <threshold>)`

A metric fails when `score < threshold`.

## Transcript Mapping

Transcripts are stored in `evals\debug` as:

`eval_transcript_{Session ID}.txt`

Example:

- Session ID: `eval_session_5d8f46b1-4d2d-48c7-bc48-66ccc6e42abb`
- Transcript: `eval_transcript_eval_session_5d8f46b1-4d2d-48c7-bc48-66ccc6e42abb.txt`

## Test Report Expectations

The consolidated report `evals\test_report.txt` should:

- List each unique issue (grouped by failed metric name)
- For each issue, include the report path, test case number, session id, transcript path
- Provide evidence lines from the transcript (fallback to the first 20 lines if no metric keyword is found)
- Use ASCII output
