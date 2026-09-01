# Logic App Standard project root

Open **this folder** in Visual Studio Code so the Azure Logic Apps (Standard) extension recognises
the project. Do not open the repository root.

```
shopify-order-simulation/          <- project root
├── wf-shopify-order-ingest/
│   └── workflow.json              <- one folder per workflow
├── connections.json
├── host.json
├── parameters.json
├── local.settings.example.json    <- template; copy to local.settings.json
└── .funcignore
```

## Local setup

1. Copy `local.settings.example.json` to `local.settings.json` in this folder.
2. Replace every `<REPLACE-LOCALLY-DO-NOT-COMMIT>` placeholder with your own local values.
3. Start Azurite.
4. Open the workflow with the Logic Apps (Standard) designer.

`local.settings.json` is git-ignored and must never be committed — it is designed to hold local
secrets. `local.settings.example.json` contains placeholders only.

## Packaging boundary

The deployable ZIP contains the **contents of this folder** at the **ZIP root** — `host.json`,
`connections.json`, `parameters.json` and each `wf-*/workflow.json`. It must not contain the
`src/`, `logic-app/` or `shopify-order-simulation/` wrapper folders, and it never contains
`local.settings.json`.

## Status

`wf-shopify-order-ingest` is a valid **placeholder**. It receives a request, composes a static
acknowledgement and responds. It performs no validation, transformation, storage, notification or
telemetry, and it calls no external service. The real integration is delivered in a later module.

Workflow folder names never contain an environment name, because the same artifact is promoted
from UAT to PROD.
