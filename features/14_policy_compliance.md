# Feature Context: Policy Compliance Pages

## Overview
Deploys four mandatory merchant policy pages (Terms, Privacy, Refund, Cancellation) to the root workspace directory for public hosting on GitHub Pages. This ensures full compliance with payment gateway providers like Razorpay.

---

## 1. Compliance Page Requirements

### A. Terms & Conditions (`terms.html`)
*   **Definition**: Outlines service rules, user roles, virtual stats, and limitations of liability.
*   **Note**: Specifically highlights that Zepkit is a simulated cravings application. Items check out visually with zero real money transactions, except voluntary support donations.

### B. Privacy Policy (`privacy.html`)
*   **Definition**: Discloses the handling of user metrics, stats, and historical local orders.
*   **Note**: Declares that all user data is stored locally in the application's SQLite sandbox. No personal data is uploaded to remote tracking servers.

### C. Refund Policy (`refund.html`)
*   **Definition**: Discloses donation terms.
*   **Note**: Voluntary developer support payments (e.g. coffee contributions via Razorpay) are completed as non-refundable contributions for software maintenance.

### D. Cancellation Policy (`cancellation.html`)
*   **Definition**: Discloses simulated order cancellations.
*   **Note**: Because orders are purely simulated events executed instantly inside the local application, order records cannot be canceled or modified post-checkout.

---

## 2. Footer References
All policy files are hosted at root directories and referenced inside the landing page footer:
```html
<div class="footer-policy-links">
  <a href="terms.html">Terms & Conditions</a>
  <a href="privacy.html">Privacy Policy</a>
  <a href="refund.html">Refund Policy</a>
  <a href="cancellation.html">Cancellation Policy</a>
</div>
```
