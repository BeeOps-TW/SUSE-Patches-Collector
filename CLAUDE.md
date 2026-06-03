# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A single-script CLI tool (`main.py`) that scrapes SUSE Customer Center (SCC) patch data and exports it to Excel. It queries SCC's undocumented frontend patch-finder JSON API for `important` and `critical` patches, enriches each result with detail-API fields, and writes a fixed 7-column `.xlsx`.

Note: comments, README, and shell-script output are in Traditional Chinese.

## Commands

This project uses `mise` + `uv` (Python 3.13). The venv is auto-created (`python.uv_venv_auto = true` in `mise.toml`).

```bash
uv sync                 # install dependencies from pyproject.toml / uv.lock
uv run python main.py   # run with defaults (SLES LTSS 12 SP5, x86_64)
```

Batch generation of all tracked SLES versions (both scripts prompt for a start date, `rm`/`del` existing `*.xlsx`, then run `main.py` via `uv run` for each version):
```bash
bash patch.sh           # Linux/macOS
patch.bat               # Windows
```

There are no tests, linters, or build steps.

> Environment note: `pandas` has no prebuilt Windows wheel for Python 3.14, so a venv on 3.14 fails to build it (needs MSVC). Keep the venv on Python 3.13 (`mise.toml` pins this) — `uv venv --python 3.13 && uv sync` if it ever gets recreated on the wrong version.

## Architecture

`main.py` runs as a linear pipeline in `main()`:

1. **Fetch** — `fetch_all_pages_for_severity()` is called once per severity in `SEVERITIES` (`important`, `critical`). It paginates the search API (`BASE_URL`), reading `meta.total_pages` to know how many pages to pull, and strips `special_product_names` from each hit.
2. **Sort & filter** — results are merged, sorted by `issued_at` (newest first), then filtered by `--since` *before* the detail calls (filtering first minimizes per-patch detail requests).
3. **Enrich** — `fetch_detail_fields()` hits `DETAIL_URL` per surviving patch to pull `ibs_id` (→ "Patch Detail" column) and `description` (→ "CVE or Issues Fixed" column).
4. **Export** — rows are mapped to a fixed column order and written via pandas/openpyxl.

### Key conventions

- **All datetimes are normalized to UTC.** `parse_issued_at` (API values) and `parse_user_datetime` (`--since` input) both coerce to timezone-aware UTC; unparseable values fall back to `datetime.min` (UTC) so they sort last. `--since` accepts `YYYY-MM-DD`, `YYYY/MM/DD`, or full ISO8601.
- **Both network functions retry** (default 3 attempts, exponential-ish backoff via `0.5 * attempt`). The detail fetch swallows failures and returns empty strings rather than aborting the run; the search fetch re-raises after exhausting retries.
- **Output schema is fixed** to these 7 columns in order: `Severity`, `Patch name`, `Patch Detail`, `Product(s)`, `Arch`, `Release`. `CVE or Issues Fixed`. Changing column names/order means editing both the `row` dict and the `df` columns list.
- `--product-names`, `--product-versions`, `--product-architectures` map directly to SCC API query params. Note in the batch scripts that 12/15 SP3–SP6 use the `LTSS` product name while SP7 uses `"SUSE Linux Enterprise Live Patching"` — product naming is version-dependent.

### External dependency

The tool depends entirely on SCC's frontend API shape (`hits`, `meta.total_pages`, `ibs_id`, `description`, `issued_at`, `product_friendly_names`). There is no API contract — breakage here means SCC changed their endpoints or response fields.
