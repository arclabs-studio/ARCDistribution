# Common App Store Rejection Rules — ARC Labs Reference

Quick-reference of Apple Review Guidelines most likely to cause rejection for ARC Labs apps.
Each rule includes what to check, how to detect it, and how to fix it.

---

## Privacy & Data (Guideline 5.1)

### Privacy Manifest Missing — 5.1.1(i)

**What:** Since Spring 2024, all apps must include a `PrivacyInfo.xcprivacy` file declaring
required reason APIs used (UserDefaults, file timestamp, disk space, system boot time, etc.).

**Detect:**
```bash
find . -name "PrivacyInfo.xcprivacy" -not -path "*/.*"
```

**Fix:** Add `PrivacyInfo.xcprivacy` to the app target. Declare each required reason API
with its approved use case. See [Apple documentation](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files).

### Unnecessary Data Collection — 5.1.1(ii)

**What:** Requesting personal data unrelated to core functionality (e.g., asking for birthday
in a weather app).

**Detect:** Review all permission prompts (Info.plist `NS*UsageDescription` keys) and ensure
each corresponds to a user-facing feature.

**Fix:** Remove unused permission requests. Ensure usage descriptions clearly explain why
the data is needed.

---

## Entitlements (Guideline 2.4.5)

### Unused Entitlements — 2.4.5(i)

**What:** App declares entitlements (HealthKit, HomeKit, Push Notifications, etc.) but never
uses the corresponding APIs. Apple flags this automatically.

**Detect:**
```bash
# List declared entitlements
plutil -p *.entitlements

# Cross-reference with actual imports
grep -r "import HealthKit\|import HomeKit\|import CloudKit" Sources/
```

**Fix:** Remove unused entitlements from the `.entitlements` file and corresponding
capabilities in Xcode > Signing & Capabilities.

---

## Metadata (Guideline 2.3)

### Competitor Brand Names — 2.3.1

**What:** Mentioning competitor platforms or devices (Android, Google Play, Samsung, etc.)
in app name, subtitle, keywords, or description.

**Detect:**
```bash
grep -ri -E "android|google play|samsung|pixel|huawei|galaxy|windows phone" \
  ~/Documents/ARCLabsStudio/Distribution/*/metadata/
```

**Fix:** Remove all competitor references. Focus metadata on your app's own value proposition.

### Inaccurate Metadata — 2.3.4

**What:** Screenshots showing device frames from a different device class, or preview videos
using simulator chrome.

**Fix:** Use clean screenshots without device frames, or ensure frames match the target device.

---

## Subscriptions (Guideline 3.1.2)

### Missing Terms of Service / Privacy Policy — 3.1.2(a)

**What:** Apps with auto-renewable subscriptions must link to Terms of Service and
Privacy Policy both in-app and in App Store Connect metadata.

**Detect:** Check App Store Connect > App Information for both URLs. Verify URLs are live
and accessible.

**Fix:** Add links in App Store Connect and ensure the paywall screen shows both links
before purchase.

### Misleading Pricing — 3.1.2(b)

**What:** Displaying monthly price prominently when the subscription is billed annually.
Apple requires the actual billing amount to be equally or more prominent.

**Fix:** Show the per-billing-period price (e.g., "$29.99/year") at least as prominently as
any per-month breakdown.

---

## Sign in with Apple (Guideline 4.0)

### Redundant Data After SIWA — 4.0

**What:** If the app offers Sign in with Apple and the user chooses to hide their email,
the app must not then ask for their name or email in a subsequent form.

**Fix:** Use the data returned by the SIWA credential directly. Do not present additional
registration forms requesting the same information.

---

## Apple Trademarks (Guideline 5.2.5)

### Misuse of Apple Device Images — 5.2.5

**What:** Using Apple product images (iPhone, iPad, Mac) in your app icon or marketing
materials without following Apple's trademark guidelines.

**Fix:** Remove Apple device imagery from app icons. For marketing, use only Apple-provided
device frames from the [Apple Design Resources](https://developer.apple.com/design/resources/).
