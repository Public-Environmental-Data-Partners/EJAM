const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { chromium } = require("playwright");

const targetUrl = process.env.EJAM_PDF_VERIFICATION_URL;
if (!targetUrl) {
  throw new Error("EJAM_PDF_VERIFICATION_URL is required.");
}

const parsedUrl = new URL(targetUrl);
if (!["http:", "https:"].includes(parsedUrl.protocol)) {
  throw new Error("EJAM_PDF_VERIFICATION_URL must use http or https.");
}

// Deep link that preloads one Rhode Island point with a 1-mile radius, so the
// check does not depend on clicking the map.
const launchUrl = new URL(parsedUrl.href);
launchUrl.searchParams.set("lat", "41.824");
launchUrl.searchParams.set("lon", "-71.4128");
launchUrl.searchParams.set("radius", "1");

const artifactDir = process.env.EJAM_PDF_VERIFICATION_ARTIFACT_DIR ||
  path.join(os.tmpdir(), "ejam-pdf-verification");
fs.mkdirSync(artifactDir, { recursive: true });

const pdfPath = path.join(artifactDir, "deployed-ejam-verification.pdf");
const screenshotPath = path.join(artifactDir, "failure.png");

function assertPdf(bytes, contentType) {
  if (!/application\/pdf/i.test(contentType || "")) {
    throw new Error(`Expected application/pdf, got '${contentType}'.`);
  }
  if (bytes.length < 100) {
    throw new Error(`Downloaded PDF is unexpectedly small (${bytes.length} bytes).`);
  }
  if (bytes.subarray(0, 5).toString("ascii") !== "%PDF-") {
    throw new Error("Downloaded file does not begin with the %PDF- magic bytes.");
  }
}

// Text of any Shiny progress bars or notifications, for error messages.
async function shinyNotices(page) {
  return page.evaluate(() =>
    Array.from(document.querySelectorAll(".shiny-notification"))
      .map((el) => el.innerText.replace(/\s+/g, " ").trim())
      .filter(Boolean)
      .join(" | ")
  ).catch(() => "");
}

// Wait until the server has finished its startup round trips. Right after the
// websocket connects, input$radius_now is still undefined; clicking Start then
// makes sanitized_radius_now() req()-fail inside the analysis observer, which
// stops silently and leaves "Step 1 of 3 ... 0% done" on screen forever.
async function waitForAppSettled(page, { quietMs = 2_000, timeoutMs = 120_000 } = {}) {
  const deadline = Date.now() + timeoutMs;
  let readySince = null;
  while (Date.now() < deadline) {
    const ready = await page.evaluate(() => {
      const button = document.getElementById("bt_get_results");
      return !document.documentElement.classList.contains("shiny-busy") &&
        window.Shiny.shinyapp.$inputValues.radius_now !== undefined &&
        Boolean(button) && !button.disabled &&
        button.getAttribute("aria-disabled") !== "true";
    });
    if (!ready) {
      readySince = null;
    } else if (readySince === null) {
      readySince = Date.now();
    } else if (Date.now() - readySince >= quietMs) {
      return;
    }
    await page.waitForTimeout(250);
  }
  throw new Error("The app did not finish starting up (radius slider or Start Analysis button never became ready).");
}

async function openTab(page, inputId, tabName) {
  const current = await page.evaluate(
    (id) => window.Shiny.shinyapp.$inputValues[id],
    inputId,
  );
  if (current !== tabName) {
    await page.locator(`#${inputId} a[data-value="${tabName}"]`).click();
  }
  await page.waitForFunction(
    ({ id, name }) => window.Shiny.shinyapp.$inputValues[id] === name,
    { id: inputId, name: tabName },
    { timeout: 30_000 },
  );
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1400, height: 1000 } });
  const page = await context.newPage();

  try {
    console.log(`Opening ${launchUrl.href}`);
    await page.goto(launchUrl.href, {
      waitUntil: "domcontentloaded",
      timeout: 120_000,
    });
    await page.waitForFunction(
      () => window.Shiny &&
        window.Shiny.shinyapp &&
        window.Shiny.shinyapp.$socket &&
        window.Shiny.shinyapp.$socket.readyState === 1,
      null,
      { timeout: 120_000 },
    );
    console.log(`Connected to the deployed Shiny session at ${page.url()}`);

    await waitForAppSettled(page);
    const radius = await page.evaluate(
      () => window.Shiny.shinyapp.$inputValues.radius_now,
    );
    console.log(`App is ready with the deep-linked site (radius ${radius} miles).`);

    await page.locator("#bt_get_results").click();
    console.log("Started the one-site analysis.");

    // A finished analysis switches the app to the See Results tab by itself.
    try {
      await page.waitForFunction(
        () => window.Shiny.shinyapp.$inputValues.all_tabs === "See Results",
        null,
        { timeout: 5 * 60_000 },
      );
    } catch (error) {
      throw new Error(
        `The analysis did not finish within 5 minutes. On screen: ${await shinyNotices(page) || "(no notices)"}`,
      );
    }
    console.log("The analysis finished.");

    // The report download link stays disabled until the Community Report's
    // header, map and plot have rendered, and they only render while visible.
    await openTab(page, "all_tabs", "See Results");
    await openTab(page, "results_tabs", "Community Report");

    await page.locator('input[name="fileextension"][value="pdf"]').check({ force: true });
    await page.waitForFunction(
      () => window.Shiny.shinyapp.$inputValues.fileextension === "pdf",
      null,
      { timeout: 30_000 },
    );
    console.log("Requested PDF output.");

    await page.waitForFunction(
      () => {
        const link = document.getElementById("download_report_multisite");
        return link &&
          !link.classList.contains("disabled") &&
          !link.hasAttribute("disabled") &&
          link.getAttribute("aria-disabled") !== "true" &&
          Boolean(link.getAttribute("href"));
      },
      null,
      { timeout: 5 * 60_000 },
    );
    const href = await page.locator("#download_report_multisite").getAttribute("href");
    const downloadUrl = new URL(href, page.url());
    console.log("The report download link is ready; requesting the PDF.");

    // page.request shares the browser's cookies, including the load balancer's
    // stickiness cookie, so this reaches the same server as the Shiny session.
    const started = Date.now();
    const response = await page.request.get(downloadUrl.href, { timeout: 5 * 60_000 });
    const bytes = await response.body();
    const contentType = response.headers()["content-type"];
    if (response.status() !== 200) {
      throw new Error(
        `PDF request returned HTTP ${response.status()} (${contentType}): ${bytes.subarray(0, 200).toString("utf8")}`,
      );
    }
    fs.writeFileSync(pdfPath, bytes);
    assertPdf(bytes, contentType);
    console.log(
      `Valid deployed PDF: ${bytes.length} bytes, ${contentType}, in ${Math.round((Date.now() - started) / 1000)} s.`,
    );
  } catch (error) {
    await page.screenshot({ path: screenshotPath, fullPage: true }).catch(() => {});
    throw error;
  } finally {
    await context.close();
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
