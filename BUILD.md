# Build

This repository is a public HarmonyOS UI shell. It does not commit local machine paths. The build script creates `local.properties` from environment variables at build time and removes it when the build exits.

## Requirements

- DevEco Studio with `tools/node`, `tools/ohpm`, `tools/hvigor`, and `jbr` installed.
- HarmonyOS SDK matching API 22 / DevEco model version 6.0.2.

## Windows PowerShell

Set `DEVECO_STUDIO_HOME` for your machine, then run the script from the repository root:

```powershell
$env:DEVECO_STUDIO_HOME = "<path-to-DevEco-Studio>"
.\scripts\build.ps1
```

By default the script uses `<DEVECO_STUDIO_HOME>/sdk`. If your SDK lives elsewhere, set `HARMONYOS_SDK_HOME` to the SDK parent directory that contains `default/sdk-pkg.json`. The script also accepts the `default`, `default/hms`, or `default/openharmony` subdirectory and normalizes it before invoking hvigor.

The unsigned HAP is written under `entry/build/default/outputs/default/`.

No signing material is required for the public build. The repository intentionally keeps `signingConfigs` empty, so DevEco/Hvigor may print a skip-sign warning while still producing the unsigned HAP.

