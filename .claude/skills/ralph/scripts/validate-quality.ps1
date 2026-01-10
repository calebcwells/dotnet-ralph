#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Ralph .NET Quality Gate Script

.DESCRIPTION
    Runs all quality checks required before committing a Ralph story.
    All gates must pass for a story to be marked complete.

.PARAMETER SkipBuild
    Skip the dotnet build step

.PARAMETER SkipTest
    Skip the dotnet test step

.PARAMETER SkipFormat
    Skip the dotnet format verification step

.PARAMETER Project
    Specific project or solution file to target

.PARAMETER Verbose
    Show verbose output from commands

.EXAMPLE
    ./validate-quality.ps1

.EXAMPLE
    ./validate-quality.ps1 -SkipTest -Project ./src/MyApp.sln
#>

param(
    [switch]$SkipBuild,
    [switch]$SkipTest,
    [switch]$SkipFormat,
    [string]$Project = "",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$script:HasErrors = $false

function Write-StepHeader($message) {
    Write-Host "`n$("=" * 60)" -ForegroundColor Cyan
    Write-Host " $message" -ForegroundColor Cyan
    Write-Host "$("=" * 60)" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "[PASS] $message" -ForegroundColor Green
}

function Write-Failure($message) {
    Write-Host "[FAIL] $message" -ForegroundColor Red
    $script:HasErrors = $true
}

# Determine project/solution target
$targetArg = if ($Project) { @($Project) } else { @() }

Write-Host "Ralph .NET Quality Gates" -ForegroundColor Magenta
Write-Host "========================" -ForegroundColor Magenta

# Step 1: Build
if (-not $SkipBuild) {
    Write-StepHeader "dotnet build"

    $buildArgs = @("build", "--no-incremental") + $targetArg
    if ($Verbose) { $buildArgs += @("-v", "normal") }

    & dotnet @buildArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Build completed successfully"
    } else {
        Write-Failure "Build failed with exit code $LASTEXITCODE"
    }
}

# Step 2: Format Check
if (-not $SkipFormat) {
    Write-StepHeader "dotnet format --verify-no-changes"

    $formatArgs = @("format", "--verify-no-changes") + $targetArg

    & dotnet @formatArgs 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code formatting is correct"
    } else {
        Write-Failure "Code formatting issues detected (run 'dotnet format' to fix)"
    }
}

# Step 3: Tests
if (-not $SkipTest) {
    Write-StepHeader "dotnet test"

    $testArgs = @("test", "--no-build") + $targetArg
    if ($Verbose) { $testArgs += @("-v", "normal") }

    & dotnet @testArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Success "All tests passed"
    } else {
        Write-Failure "Tests failed"
    }
}

# Summary
Write-Host "`n$("=" * 60)" -ForegroundColor Cyan
if ($script:HasErrors) {
    Write-Host " QUALITY GATES: FAILED" -ForegroundColor Red
    Write-Host " Fix the issues above before committing." -ForegroundColor Red
    Write-Host "$("=" * 60)" -ForegroundColor Cyan
    exit 1
} else {
    Write-Host " QUALITY GATES: PASSED" -ForegroundColor Green
    Write-Host " Ready to commit!" -ForegroundColor Green
    Write-Host "$("=" * 60)" -ForegroundColor Cyan
    exit 0
}
