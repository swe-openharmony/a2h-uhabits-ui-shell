param(
  [string]$Module = "entry",
  [switch]$SkipOhpm,
  [switch]$KeepLocalProperties
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Require-Path([string]$Path, [string]$Description) {
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "$Description not found: $Path"
  }
}

if (-not $env:DEVECO_STUDIO_HOME) {
  throw "Set DEVECO_STUDIO_HOME to your DevEco Studio installation directory."
}
$DevEco = (Resolve-Path -LiteralPath $env:DEVECO_STUDIO_HOME).Path

$BuildProfile = Get-Content -LiteralPath (Join-Path $ProjectRoot "build-profile.json5") -Raw
$RuntimeOS = "HarmonyOS"
if ($BuildProfile -match '"runtimeOS"\s*:\s*"([^"]+)"') { $RuntimeOS = $Matches[1] }

$SdkRoot = $env:HARMONYOS_SDK_HOME
if ($RuntimeOS -eq "OpenHarmony" -and $env:OPENHARMONY_SDK_HOME) { $SdkRoot = $env:OPENHARMONY_SDK_HOME }
if (-not $SdkRoot) { $SdkRoot = $env:DEVECO_SDK_HOME }
if (-not $SdkRoot) {
  $DefaultSdkRoot = Join-Path $DevEco "sdk"
  if (Test-Path -LiteralPath (Join-Path $DefaultSdkRoot "default/sdk-pkg.json")) {
    $SdkRoot = $DefaultSdkRoot
  } else {
    throw "Set HARMONYOS_SDK_HOME to your HarmonyOS/OpenHarmony SDK root. The script also checks '<DEVECO_STUDIO_HOME>/sdk'. For OpenHarmony projects, OPENHARMONY_SDK_HOME may be used."
  }
}
elseif ((Test-Path -LiteralPath (Join-Path $SdkRoot "sdk/default/sdk-pkg.json"))) {
  $SdkRoot = Join-Path $SdkRoot "sdk"
}
elseif (-not (Test-Path -LiteralPath (Join-Path $SdkRoot "default/sdk-pkg.json"))) {
  $DefaultSdkRoot = Join-Path $DevEco "sdk"
  if (Test-Path -LiteralPath (Join-Path $DefaultSdkRoot "default/sdk-pkg.json")) {
    $SdkRoot = $DefaultSdkRoot
  }
}

$SdkRoot = (Resolve-Path -LiteralPath $SdkRoot).Path
if ((Split-Path -Leaf $SdkRoot) -eq "default" -and (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $SdkRoot) "default/sdk-pkg.json"))) {
  $SdkRoot = (Split-Path -Parent $SdkRoot)
}
if (((Split-Path -Leaf $SdkRoot) -eq "hms" -or (Split-Path -Leaf $SdkRoot) -eq "openharmony") -and
    (Test-Path -LiteralPath (Join-Path (Split-Path -Parent (Split-Path -Parent $SdkRoot)) "default/sdk-pkg.json"))) {
  $SdkRoot = (Split-Path -Parent (Split-Path -Parent $SdkRoot))
}
$NodeDir = Join-Path $DevEco "tools/node"
$NodeExe = Join-Path $NodeDir "node.exe"
$OhpmBat = Join-Path $DevEco "tools/ohpm/bin/ohpm.bat"
$HvigorBat = Join-Path $DevEco "tools/hvigor/bin/hvigorw.bat"
$JbrDir = Join-Path $DevEco "jbr"

Require-Path $NodeExe "DevEco Node.js"
Require-Path $OhpmBat "DevEco ohpm"
Require-Path $HvigorBat "DevEco hvigor"
Require-Path $JbrDir "DevEco JBR"
if (-not (Test-Path -LiteralPath (Join-Path $SdkRoot "default/sdk-pkg.json"))) {
  throw "SDK package metadata not found under: $SdkRoot. Set HARMONYOS_SDK_HOME to the DevEco SDK parent directory, for example '<DevEco Studio>/sdk'."
}

$env:JAVA_HOME = $JbrDir
$env:DEVECO_SDK_HOME = $SdkRoot
$env:HARMONYOS_SDK_HOME = $SdkRoot
$env:OHOS_SDK_HOME = $SdkRoot
$env:PATH = "$NodeDir;$(Split-Path -Parent $OhpmBat);$(Split-Path -Parent $HvigorBat);$env:PATH"

$LocalProperties = Join-Path $ProjectRoot "local.properties"
@(
  "sdk.dir=$SdkRoot",
  "nodejs.dir=$NodeDir",
  "npm.dir=$(Join-Path $NodeDir 'bin')"
) | Set-Content -LiteralPath $LocalProperties -Encoding ASCII

Push-Location $ProjectRoot
try {
  Write-Host "Runtime: $RuntimeOS"
  Write-Host "SDK: $SdkRoot"
  if (-not $SkipOhpm) {
    & $OhpmBat install --all
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }

  & $HvigorBat --no-daemon assembleHap --mode module -p "module=$Module"
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

  $Haps = Get-ChildItem -Path $ProjectRoot -Recurse -Filter "*.hap" |
    Where-Object { $_.FullName -match "[\\/]build[\\/]" } |
    Sort-Object LastWriteTime -Descending
  if (-not $Haps) {
    throw "Build finished, but no HAP was found under build outputs."
  }
  Write-Host "HAP: $($Haps[0].FullName)"
}
finally {
  Pop-Location
  if (-not $KeepLocalProperties) {
    Remove-Item -LiteralPath $LocalProperties -Force -ErrorAction SilentlyContinue
  }
}
