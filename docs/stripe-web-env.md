# ScanLeno Web Stripe subscriptions

Stripe is used for ScanLeno Web subscriptions only.

- iOS subscriptions must continue to use Apple In-App Purchase.
- Android subscriptions must continue to use Google Play Billing.
- Do not add Stripe secret keys to Flutter, iOS, Android, Web assets, or Git.
- Premium is activated only after a trusted Stripe webhook updates the backend account metadata.

## Backend environment variables

Put these variables on the backend server only. In production, use your host's secret manager or protected environment variables. Do not commit real values.

```env
STRIPE_WEB_ENABLED=true
STRIPE_MODE=test
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_SCANLENO_MONTHLY_PRICE_ID=
STRIPE_SCANLENO_YEARLY_PRICE_ID=
STRIPE_SUCCESS_URL=https://your-web-domain.example/premium/success
STRIPE_CANCEL_URL=https://your-web-domain.example/premium/cancel
```

`STRIPE_SECRET_KEY` may be a Stripe secret key or, preferably, a restricted API key with the minimum Billing and Checkout permissions required by this backend.

## Test environment

Use Stripe test mode values:

- `STRIPE_MODE=test`
- `STRIPE_WEB_ENABLED=true`
- test-mode secret or restricted key in `STRIPE_SECRET_KEY`
- test-mode publishable key in `STRIPE_PUBLISHABLE_KEY`
- test-mode webhook signing secret in `STRIPE_WEBHOOK_SECRET`
- test-mode recurring Price IDs for monthly and yearly plans
- success/cancel URLs that point to the ScanLeno Web test environment

For local webhook testing, use the Stripe CLI to forward events to:

```text
POST /api/stripe/webhook
```

## Production environment

Use Stripe live mode values:

- `STRIPE_MODE=live`
- `STRIPE_WEB_ENABLED=true`
- live-mode secret or restricted key in `STRIPE_SECRET_KEY`
- live-mode publishable key in `STRIPE_PUBLISHABLE_KEY`
- live-mode webhook signing secret in `STRIPE_WEBHOOK_SECRET`
- live-mode recurring Price IDs for monthly and yearly plans
- production success/cancel URLs

When `NODE_ENV=production` or `SCANLENO_ENV=production` and `STRIPE_WEB_ENABLED=true`, the backend refuses to start if required Stripe server values are missing.

## Endpoints

- `GET /api/stripe/config`
  - Returns public-safe values only: `stripeEnabled`, `mode`, and `publishableKey`.
  - Never returns `STRIPE_SECRET_KEY` or `STRIPE_WEBHOOK_SECRET`.

- `POST /api/stripe/create-checkout-session`
  - Requires a Firebase ID Token.
  - Accepts only `plan=monthly` or `plan=yearly`.
  - Uses backend environment Price IDs only.
  - Returns `checkoutUrl`.

- `POST /api/stripe/webhook`
  - Verifies Stripe webhook signatures using `STRIPE_WEBHOOK_SECRET`.
  - Updates the user's local backend subscription metadata after trusted Stripe events.

## Security notes

- Do not send Price IDs from the client as trusted values.
- Do not mark users Premium from client data.
- Do not log Stripe keys, webhook secrets, Checkout URLs, or payment details.
- Keep Stripe separate from mobile subscriptions.
