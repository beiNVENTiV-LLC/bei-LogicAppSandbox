// ---------------------------------------------------------------------------
// bei-LogicAppSandbox - resource group
//
// INTENTIONALLY EMPTY. This module creates nothing, and that is the decision.
//
// The MODULE 2 blueprint anticipated a subscription-scoped deployment that
// created its own resource groups. MODULE 3 does not work that way, because the
// GitHub deployment identities hold Contributor and User Access Administrator at
// RESOURCE GROUP scope only and nothing at subscription scope. A subscription
// scoped deployment would fail, and widening the identity to make it succeed
// would defeat the least-privilege model recorded in ADR 0001.
//
// The two resource groups are therefore created once, out of band, by a
// subscription owner:
//
//   rg-bei-<workload>-uat-<region>-<instance>
//   rg-bei-<workload>-prod-<region>-<instance>
//
// infra/main.bicep targets an existing resource group and owns everything
// inside it.
//
// The file is retained rather than deleted so the blueprint structure stays
// intact and this decision stays visible at the place someone would look for it.
// ---------------------------------------------------------------------------

// No resources. See the comment above before adding any.
