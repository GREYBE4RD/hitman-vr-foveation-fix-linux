#!/usr/bin/env bash
# HitmanVRFoveationFix for Linux/Proton - iteration v1.6.0
# Direct port of RealChrizzl's Windows PowerShell v1.6 implementation.

set -euo pipefail
cd -- "$(dirname -- "$(readlink -f -- "$0")")"
exec sudo python3 -I ./Linux-HitmanVRFoveationFix-v1.6.py "$@"
