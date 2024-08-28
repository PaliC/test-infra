-- !!! Query is not converted to CH syntax yet.  Delete this line when it gets converted
-- This query is used by Dr.CI to get all the failed jobs from the base commit. They can then be
-- used to decide if a failure is due to broken trunk
with relevant_pushes as (
  select
    p.head_commit.timestamp,
    p.after
  from commons.push p
  where
    ARRAY_CONTAINS(
      SPLIT(:shas, ','), p.after
    )
)
SELECT
  j.id,
  j.name AS jobName,
  CONCAT(w.name, ' / ', j.name) AS name,
  j.runner_name AS runnerName,
  w.head_commit.author.email as authorEmail,
  j.conclusion,
  j.completed_at,
  j.html_url,
  j.head_sha,
  p.timestamp AS head_sha_timestamp,
  j.head_branch,
  j.torchci_classification.captures AS failure_captures,
  IF(j.torchci_classification.line IS NULL, null, ARRAY_CREATE(j.torchci_classification.line)) AS failure_lines,
  j.torchci_classification.context AS failure_context,
  j._event_time AS time,
FROM
  commons.workflow_run w
  JOIN commons.workflow_job j ON w.id = j.run_id HINT(join_broadcast = true)
  -- Do a left join here because the push table won't have any information about
  -- commits from forked repo
  LEFT JOIN relevant_pushes p ON p.after = j.head_sha HINT(join_strategy = lookup)
WHERE
  ARRAY_CONTAINS(
    SPLIT(: shas, ','),
    j.head_sha
  )
  AND j.conclusion IN ('failure', 'cancelled')
