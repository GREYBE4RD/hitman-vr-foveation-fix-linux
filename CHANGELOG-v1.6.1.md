# HitmanVRFoveationFix v1.6.1

## Faster unknown-build startup

- Replaced the PowerShell byte-by-byte fallback signature scan with an equivalent compiled matcher.
- Unknown builds no longer compute a full executable SHA-256 before signature scanning. SHA-256 verification remains unchanged for the verified HITMAN 3.270.1 fixed-address path.
- Matching semantics remain fail-closed: `??` wildcards are preserved, every required pattern must still resolve uniquely, and refraction targets are still cross-checked.
- Unknown builds now show a clear scanning status and log the signature-scan duration to `foveationfix.log`.

## Why

Issue #15 exposed a startup timing problem on an unverified HITMAN build. The old fallback path could take roughly 12 seconds to locate all required sites. If VR was started before that work completed, the safety check correctly refused to patch because VR was already active.

The optimized fallback path removes that practical timing window without weakening the pre-VR safety check.

## Validation

The Issue #15 reporter tested this v1.6.1 candidate three times while deliberately pressing the in-game YES-to-VR prompt as quickly as possible. All three runs succeeded.

Their logs measured the full 28,325,888-byte `.text` signature scan at 343 ms and 366 ms on build timestamp `1779890224`, compared with roughly 12 seconds with the previous fallback path.

## Preserved

- v1.6 source-level mask patches remain unchanged.
- v1.5 second view-count fix remains unchanged.
- v1.4 refraction wrappers remain unchanged.
- No renderer Scale/Mask device writes or polling renderer guard return.
- Linux/Proton v1.6 is unchanged; this release only optimizes the Windows PowerShell fallback path.
