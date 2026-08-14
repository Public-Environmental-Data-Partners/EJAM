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

const artifactDir = process.env.EJAM_PDF_VERIFICATION_ARTIFACT_DIR ||
  path.join(os.tmpdir(), "ejam-pdf-verification");
fs.mkdirSync(artifactDir, { recursive: true });

const pdfPath = path.join(artifactDir, "deployed-ejam-verification.pdf");
const screenshotPath = path.join(artifactDir, "failure.png");

function assertPdf(filePath, suggestedFilename) {
  if (path.extname(suggestedFilename).toLowerCase() !== ".pdf") {
    throw new Error(`Expected a .pdf download, got '${suggestedFilename}'.`);
  }

  const bytes = fs.readFileSync(filePath);
  if (bytes.length < 100) {
    throw new Error(`Downloaded PDF is unexpectedly small (${bytes.length} bytes).`);
  }
  if (bytes.subarray(0, 4).toString("ascii") !== "%PDF") {
    throw new Error("Downloaded file does not begin with the %PDF magic bytes.");
  }
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ acceptDownloads: true });
  const page = await context.newPage();

  try {
    console.log(`Opening ${parsedUrl.href}`);
    await page.goto(parsedUrl.href, {
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
    console.log("Connected to the deployed Shiny session.");

    const mapChoice = page.locator(
      'input[name="ss_choose_method"][value="mapclick"]',
    );
    await mapChoice.check({ force: true });
    await page.waitForFunction(
      () => window.Shiny.shinyapp.$inputValues.ss_choose_method === "mapclick",
      null,
      { timeout: 30_000 },
    );

    await page.evaluate(() => {
      window.Shiny.setInputValue(
        "an_leaf_map_click",
        { lat: 41.8240, lng: -71.4128 },
        { priority: "event" },
      );
    });
    console.log("Selected one Rhode Island map point.");

    await page.waitForFunction(
      () => {
        const button = document.getElementById("bt_get_results");
        return button && !button.disabled &&
          button.getAttribute("aria-disabled") !== "true";
      },
      null,
      { timeout: 120_000 },
    );
    await page.locator("#bt_get_results").click();
    console.log("Started the one-point analysis.");

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
      { timeout: 10 * 60_000 },
    );
    console.log("The deployed report is ready to download.");

    const pdfChoice = page.locator(
      'input[name="fileextension"][value="pdf"]',
    );
    await pdfChoice.check({ force: true });
    await page.waitForFunction(
      () => window.Shiny.shinyapp.$inputValues.fileextension === "pdf",
      null,
      { timeout: 30_000 },
    );
    console.log("Requested PDF output.");

    const downloadPromise = page.waitForEvent("download", {
      timeout: 3 * 60_000,
    });
    await page.locator("#download_report_multisite").click();
    const download = await downloadPromise;
    await download.saveAs(pdfPath);

    assertPdf(pdfPath, download.suggestedFilename());
    console.log(
      `Valid deployed PDF: ${download.suggestedFilename()} (${fs.statSync(pdfPath).size} bytes)`,
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
