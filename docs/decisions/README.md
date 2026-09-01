# Architecture decision records

One file per decision, numbered sequentially: `NNNN-short-title.md`.

Each record states the context, the decision, the consequences and the status
(`Proposed`, `Accepted`, `Superseded by NNNN`, or `Blocked`).

| ADR | Title | Status |
| --- | --- | --- |
| [0001](0001-oidc-deployment-identity-blocked.md) | GitHub-to-Azure authentication uses OIDC; no identity exists yet | **Blocked — Azure identity required** |
| [0002](0002-trunk-based-branching.md) | Trunk-based development on a protected `main` | Accepted |
| [0003](0003-single-artifact-promotion.md) | One artifact and one Bicep template, promoted across environments | Accepted |

