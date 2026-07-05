# Feature Context: Razorpay SDK Landing Page Integration

## Overview
Replaces the direct hyperlink button of the "Buy Me A Coffee" call-to-action on the landing page with a direct Razorpay Checkout script callback. When a supporter clicks the button, the official Razorpay payment modal is opened directly on the page, allowing credit/debit card, UPI, wallet, or Netbanking transactions.

---

## 1. Razorpay JS SDK Reference
The official client-side checkout SDK script tag is included in the `<head>` block of `index.html`:
```html
<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
```

---

## 2. Checkout Modal Options Config
The button click triggers a JavaScript function `openRazorpay()` that initiates the Checkout object:
*   **Merchant Name**: `Zepkit Support`
*   **Description**: `Buy Zepkit developers a cup of coffee!`
*   **Amount**: `₹100` (entered as `10000` paise subunits)
*   **Theme Color**: `#E03E52` (matching Zepkit's primary brand pink-red accent color)
*   **Prefill Info**: Prefills a dummy supporter name/email, which the supporter can customize inside the checkout sheet.

---

## 3. Key ID Configuration
By default, the script initializes with the placeholder Key ID:
`"key": "rzp_test_YOUR_KEY_HERE"`
To configure live transactions:
1.  Log in to your Razorpay Dashboard (`https://dashboard.razorpay.com`).
2.  Navigate to **Settings** -> **API Keys**.
3.  Click **Generate Key** (or use your existing active Key ID).
4.  Copy the Key ID and replace `"rzp_test_YOUR_KEY_HERE"` in `index.html` line 265.
