// Keep these names aligned with the R CMD check matrix. Missing or additional
// matrix jobs must never produce an "all released-R checks passed" message.
const releasedChecks = [
  "macos-latest (release)",
  "windows-latest (release)",
  "ubuntu-latest (release)",
  "ubuntu-latest (oldrel-1)",
  "ubuntu-latest (minimum)",
];
const develCheck = "ubuntu-latest (R-devel - development version of R)";
const expectedChecks = [...releasedChecks, develCheck];

function summarizeRChecks(jobs) {
  // A failed-job rerun can leave successful jobs in an earlier attempt. Use
  // each job's latest execution, including cancellations and pending results.
  const latest = new Map();
  for (const job of [...jobs].sort((a, b) => a.id - b.id)) {
    latest.set(job.name, job);
  }
  const checks = expectedChecks.map(name => latest.get(name) || {name});
  const passed = job => job.status === "completed" && job.conclusion === "success";
  const failed = job => job.status === "completed" &&
    ["failure", "timed_out", "startup_failure", "action_required"].includes(job.conclusion);
  const released = checks.slice(0, releasedChecks.length);
  const devel = checks[releasedChecks.length];
  const unexpected = [...latest.keys()].some(name =>
    /^(ubuntu|windows|macos)-latest \(/.test(name) && !expectedChecks.includes(name));

  if (released.some(failed)) {
    return {kind: "released-failure", title: "Released-R checks failed", checks};
  }
  if (!unexpected && released.every(passed) && failed(devel)) {
    return {kind: "devel-only", title: "Only R-devel failed; all released-R checks passed", checks};
  }
  if (!unexpected && checks.every(passed)) {
    return {kind: "success", title: "All released-R and R-devel checks passed", checks};
  }
  return {kind: "incomplete", title: "R check results are incomplete or cancelled", checks};
}

async function writeSummary({github, context, core}) {
  const jobs = await github.paginate(github.rest.actions.listJobsForWorkflowRun, {
    ...context.repo,
    run_id: context.runId,
    filter: "all",
    per_page: 100,
  });
  const result = summarizeRChecks(jobs);
  const messages = {
    "devel-only": "The failure is confined to the development version of R. All released-R checks passed. Review the R-devel logs for future compatibility; this run does not show a released-R failure.",
    "released-failure": "At least one released-R check failed. This is not an R-devel-only failure and needs investigation.",
    success: "All configured R versions passed their checks.",
    incomplete: "Some expected checks did not complete successfully, or the matrix has changed. The results do not establish that all released-R checks passed.",
  };
  await core.summary.addHeading(result.title)
    .addRaw(messages[result.kind]).addEOL().addEOL()
    .addTable([
      [{data: "R check", header: true}, {data: "Result", header: true}],
      ...result.checks.map(job => [job.name, job.conclusion || job.status || "missing"]),
    ]).write();
  if (result.kind === "devel-only") core.warning(messages[result.kind], {title: result.title});
  if (result.kind === "released-failure") core.error(messages[result.kind], {title: result.title});
  if (result.kind === "incomplete") core.warning(messages[result.kind], {title: result.title});
}

module.exports = {releasedChecks, develCheck, expectedChecks, summarizeRChecks, writeSummary};
