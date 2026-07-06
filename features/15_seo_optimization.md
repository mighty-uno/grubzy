# Feature Context: SEO Optimization & Indexing Guide

## Overview
This document outlines the metadata integrations, crawl schemas, and manual registration steps required to get `https://grubzy.vercel.app/` indexed on Google Search and other platforms using the "grubzy" search keyword.

---

## 1. Search Engine Crawler Assets
We deployed the following files in the project root directory:
*   **[`robots.txt`](file:///Users/himanshusharma/Documents/dev-work/bhukkad/robots.txt)**: Directs crawlers to index all pages and lists the sitemap location.
*   **[`sitemap.xml`](file:///Users/himanshusharma/Documents/dev-work/bhukkad/sitemap.xml)**: Explicitly provides crawlers with the list of pages, update frequencies, and weights.

---

## 2. On-Page SEO Upgrades
We updated the headers inside [`index.html`](file:///Users/himanshusharma/Documents/dev-work/bhukkad/index.html):
*   **Canonical URL Tag**: Prevents duplicate-content warnings for query parameters.
*   **Open Graph Metadata**: Renders rich previews (e.g. logos, tags) when links are shared on WhatsApp, Telegram, or Twitter.
*   **JSON-LD Schema Markup**: Standard structured format declaring Grubzy as a `SoftwareApplication` to help Google parse and present the app directly in search cards.

---

## 3. Mandatory Google Search Console Indexing Steps
To index the site immediately (instead of waiting weeks for Google to discover it organically):

1.  **Log in to GSC**: Open [Google Search Console](https://search.google.com/search-console).
2.  **Add Property**:
    *   Choose **URL prefix**.
    *   Enter: `https://grubzy.vercel.app/` and click Continue.
3.  **Verification**:
    *   Download the GSC HTML verification file (e.g. `google1234567890.html`).
    *   Place it in the root folder of this project, commit, and push it to Vercel.
    *   *Alternative (Easier)*: Select the **HTML Tag** option, copy the `<meta name="google-site-verification" content="..." />` tag, and paste it into the `<head>` section of `index.html`. Push to Vercel, and click **Verify** in GSC.
4.  **Submit Sitemap**:
    *   In the left-hand menu of GSC, click **Sitemaps**.
    *   Under "Add a new sitemap", enter: `sitemap.xml` and click **Submit**.
5.  **Request Indexing**:
    *   In the top search bar, paste `https://grubzy.vercel.app/`.
    *   Click **Request Indexing** to queue Google's crawler to parse your page immediately.
