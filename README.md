# Hanzo Chat (Flutter)

Streaming AI chat in Flutter, wired to the Hanzo /v1 API.

**Live demo** — https://flutter-chat.hanzo.app — the **same** app, compiled to WebAssembly by `flutter build web`. Not a mock-up.

## What you get

`Stream<String>` of tokens from `POST /v1/chat/completions`, SSE reassembled
with `LineSplitter`, and settings that change the endpoint at run time. The tests
prove a send with no key surfaces a readable error and keeps the user's text
instead of crashing.

## Run it

```sh
flutter pub get
flutter run             # -d ios for the simulator
flutter test
flutter build web --release
```

## Building for iOS — read this first

**Our runner fleet cannot produce an iOS build today.** Two separate gaps, both
measured rather than assumed:

1. **No macOS runner exists.** An archive / IPA needs macOS + Xcode + a signing
   identity. Every runner registered to `hanzoai` (519 of them) reports
   `os: linux`; `luxfi` has 151, same; `zooai` has none. The only macOS builds
   in the org today (`hanzoai/world` `build-desktop.yml`) run on GitHub-**hosted**
   `macos-14`, which is what the house CI rule exists to avoid.
2. **`hanzo-templates` is not in the arcd org list.** `arcd` serves
   `hanzoai, luxfi, zooai, parsdao, zenlm`. Until this org is added, even the
   Linux jobs in `hanzo.yml` sit `queued` with no runner to claim them.

A third gap turned up while wiring this and is already **fixed**: this org
defaulted `GITHUB_TOKEN` to `read`, and `hanzoai/ci` declares
`permissions: packages: write`. A caller cannot be granted more than the org
maximum, so every run died as `startup_failure` before a job was even created —
no logs, no annotation, nothing to read. The org now defaults to `write`, the
same as `hanzoai`, and runs reach `queued`. If you fork these into another org
and see `startup_failure` with an empty log, check
`/orgs/<org>/actions/permissions/workflow` first.

So `hanzo.yml` declares only what a Linux arc runner *could* run, and the
macOS archive sits in a separate `workflow_dispatch`-only
`.github/workflows/ios.yml` — a job pinned to a label nothing advertises would
queue forever if it fired on push.

Both gaps close with the installer, no code change:

```sh
# (2) serve this org — re-run on any existing arcd host
~/work/hanzo/arc/scripts/install-arcd.sh \
  --labels self-hosted,linux,amd64 \
  --orgs hanzoai,luxfi,zooai,parsdao,zenlm,hanzo-templates

# (1) add the macOS lane — on an Apple Silicon Mac, once
xcode-select --install && sudo xcodebuild -license accept
~/work/hanzo/arc/scripts/install-arcd.sh \
  --labels self-hosted,macos,arm64,xcode \
  --orgs hanzoai,luxfi,zooai,parsdao,zenlm,hanzo-templates
```

Then `runs-on: [self-hosted, macos, arm64, xcode]` resolves and `ios.yml`
archives + exports the IPA. Signing material comes from KMS
(`kms.hanzo.ai`), never from a checked-in `.p12`.


## CI

`hanzo.yml` + a seven-line `.github/workflows/cicd.yml` importing
`hanzoai/ci`. On every push a Linux arc runner runs:

- **analyze** — `flutter analyze`
- **test** — `flutter test`
- **web-bundle** — `flutter build web --release`


`.github/workflows/ios.yml` holds the macOS archive job and is
`workflow_dispatch` only — see above.

## Upstream

Derived from **flutter/samples** (BSD-3-Clause). This template is MIT; the upstream licence
travels with the code it came from.
