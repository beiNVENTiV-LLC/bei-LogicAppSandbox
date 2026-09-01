# Tests

| Folder | Purpose |
| --- | --- |
| `payloads/valid/` | Synthetic orders that must be accepted |
| `payloads/invalid/` | Synthetic orders that must be rejected, with the expected rejection reason |
| `payloads/edge-cases/` | Boundary cases — empty line items, unusual currency, oversized payload, duplicate order id |
| `contracts/` | The order contract / JSON schema the ingest endpoint accepts |
| `integration/` | Tests that exercise the workflow end to end against a deployed environment |
| `smoke/` | Minimal post-deployment checks run by `scripts/invoke-smoke-test.ps1` |

## Rules

* **Synthetic data only.** Never commit a real Shopify payload, real customer data or any personal
  data. Fixtures are invented.
* Never commit a secret, token, key, signature or callback URL in a fixture.
* Fixtures are versioned with the contract they test — when the contract changes, the fixtures
  change in the same pull request.

No tests exist yet. Test content arrives with the integration behaviour in a later module.
