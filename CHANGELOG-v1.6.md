# HitmanVRFoveationFix v1.6

## Fixed at the source

- Replaced the v1.5 polling workaround for save/reload black circles with two source-level mask patches in HITMAN's own renderer calculation.
- `0x011CDAC1`: `mulss xmm0,xmm0` -> `xorps xmm0,xmm0 ; nop` so `device+0x4C4` is generated as zero.
- `0x011CDAC9`: `mulss xmm2,xmm2` -> `xorps xmm2,xmm2 ; nop` so `device+0x4C0` is generated as zero.
- HITMAN now stores the desired zero mask itself whenever the renderer rebuilds, including mission and save-game loads. There is no post-write race to win.

## Renderer lifecycle cleanup

- Removed all v1.5 Scale/Mask device writes.
- Removed the ~1 ms renderer-guard worker thread, high-resolution waitable timer, renderer-value lock, direct-repair callback, repair counters and reload latch.
- Removed renderer-value ownership/rollback/restore state that existed only to support those data writes.
- Scale values are left at HITMAN's own values. They are read only as an initialization/plausibility gate.
- Mask values are read only as a correctness check. Once the device block is initialized, any readable non-zero mask is treated as a real failure.
- Idle process scanning is throttled to 500 ms; the attached validation/lifecycle timer remains lightweight. Local testing generally showed 0% script CPU with brief peaks around 0.4%.

## Refraction readiness and diagnostics

- Green/Active readiness now proves the outer refraction owner path rather than requiring both optional `CopyRefractionDepth` call sites to have executed.
- CopyA and CopyB remain fully validated and continue to report bad owner/count state, restore imbalance and wrapper stalls as errors.
- Runtime coverage is tracked separately as:
  - `no copy path observed`
  - `CopyA verified; CopyB not observed`
  - `CopyB verified; CopyA not observed`
  - `CopyA + CopyB verified`
- A Copy path is considered verified only after both a local 4 -> 2 change and its successful restore to 4 have been observed.

## Unknown-build scanner hardening

- Added scanner entries for both new mask-source instructions.
- Both entries use the same 66-byte context and patch different hit offsets (14 and 22).
- The signature deliberately extends through both mask stores and the later XMM reloads. This proves that replacing scalar `mulss` with full-register `xorps` cannot leak cleared upper lanes into a later consumer.
- As before, unknown builds fail closed unless every required pattern is unique and mutually consistent.

## Preserved

- v1.5's second view-count patch remains unchanged, keeping the full field of view in both eyes and preventing the one-eye black oval / Instinct smear.
- v1.4's refraction wrappers remain unchanged: geometry/visibility retain four logical views while each direct `CopyRefractionDepth` call temporarily sees the two physical eye views.
- Oculus (LibOVR) and SteamVR/OpenVR remain supported by the Windows implementation.
- Build 3.270.1 remains the fixed-address verified path.

## Validation

- Tested locally on the verified Windows build with Oculus Link, Air Link and SteamVR across repeated save reloads and extended normal play.
- The final code used for v1.6 was also tested externally on the verified SteamVR/OpenVR build that reproduced the v1.5 save/reload black-circle issue. Repeated reloads did not reproduce the issue and the supplied telemetry remained balanced.

## Linux

The Linux/Proton port remains on **v1.5**. It is not changed by this Windows v1.6 release and still uses the polling renderer-guard architecture until the source-level v1.6 changes are ported separately.
