# ADR 0002 — Trunk-based development on a protected `main`

* **Status:** Accepted
* **Date:** 2026-08-31
* **Module:** MODULE 2

## Context

The team is 2–5 developers delivering an integration that must stay releasable. Long-lived
environment branches (`develop`, `uat`, `prod`, `release/*`) are a common alternative, but they
create drift: the code in `uat` diverges from the code in `prod`, merges become large and risky,
and it stops being true that what was tested is what ships.

## Decision

1. `main` is the only long-lived branch. It is always protected and always releasable.
2. All work happens on short-lived branches named `feature/`, `fix/`, `docs/`, `chore/`, `spike/`
   or `dependabot/*`, cut from current `main` and deleted on merge.
3. `develop`, `uat`, `prod`, `production` and permanent release branches are prohibited.
4. Environments are represented by **GitHub Environments and Bicep parameter files**, never by
   branches.
5. `main` is protected with: required pull request; one approval from someone other than the
   author; required code-owner review; stale approvals dismissed on push; approval of the most
   recent reviewable push; a required `pr-validation` status check; branch current with `main`
   before merge; all conversations resolved; linear history; force pushes blocked; branch deletion
   blocked; rules applied to administrators; no routine bypass.
6. Squash merge only. Merge commits and rebase merges are disabled.

## Consequences

* Every change is reviewed and validated; there is no direct push path to `main`.
* History is linear and each merged change is a single revertible commit.
* Branches stay small, which is what makes a two-to-five person review load sustainable.
* A bootstrap commit is required before protection can be applied to an empty repository. That is
  a one-time, documented exception recorded in the implementation report.
* Emergency changes made outside this path must be reconciled within one business day
  (see `CONTRIBUTING.md`).
