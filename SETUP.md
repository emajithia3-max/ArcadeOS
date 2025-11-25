# ArcadeOS – Setup Guide

Complete setup instructions for building and running **ArcadeOS – Retro Arcade** iOS app.

---

## Quick Start - Code Signing Setup

Before building, you must configure code signing in Xcode:

### 1. Open the Project
1. Open `ArcadeOS.xcodeproj` in Xcode
2. Select the **ArcadeOS** target in the project navigator

### 2. Configure Signing & Capabilities
1. Go to **Signing & Capabilities** tab
2. Check **Automatically manage signing**
3. Select your **Team** from the dropdown (requires Apple Developer account)
4. The bundle identifier is already set to `com.unleeshed.ArcadeOS`
   - You can change this to your own bundle identifier if desired

### 3. Common Code Signing Errors & Solutions

**"No Account for Team" Error:**
- Go to Xcode → Settings → Accounts
- Click **+** to add your Apple ID
- Sign in with your Apple Developer account

**"No provisioning profiles" Error:**
- Ensure you've selected a valid Team in Signing & Capabilities
- Xcode will automatically create provisioning profiles when you select a team

**"Info.plist not found" Error:**
- The Info.plist is located at `ArcadeOS/Info.plist`
- Verify the **INFOPLIST_FILE** build setting points to `ArcadeOS/Info.plist`

---

## 1. Prerequisites

- **Xcode 15.0+** (for iOS 16+ support)
- **Swift 5.9+**
- **iOS 16.0+** deployment target
- Apple Developer account (for StoreKit and TestFlight testing)

---

## 2. Required Assets

### A. Fonts

Download and add these fonts to `ArcadeOS/Resources/Fonts/`:

1. **Press Start 2P** - [Download](https://fonts.google.com/specimen/Press+Start+2P)
   - File: `PressStart2P-Regular.ttf`

2. **Jersey15** - [Download](https://fonts.google.com/specimen/Jersey+15)
   - File: `Jersey15-Regular.ttf`

3. **Doto Rounded** - Search "Doto font" or use alternative rounded pixel font
   - File: `DotoRounded-Black.ttf`

**Add to Info.plist:**
```xml
<key>UIAppFonts</key>
<array>
    <string>PressStart2P-Regular.ttf</string>
    <string>Jersey15-Regular.ttf</string>
    <string>DotoRounded-Black.ttf</string>
</array>
```

---

### B. Sound Effects

Add these audio files to `ArcadeOS/Resources/Sounds/`:

- `bootup.mp3` - Boot startup sound (~2 seconds)
- `click.mp3` - UI click/select sound (~0.2 seconds)
- `boop.mp3` - Close/dismiss sound (~0.3 seconds)

**Sources:**
- Create your own using retro sound generators
- Find royalty-free retro SFX on Freesound.org or Zapsplat.com
- Use chiptune/8-bit sound generators

---

## 3. Info.plist Configuration

Add the following to your `Info.plist`:

### A. Fonts (see above)

### B. AdMob Configuration

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>

<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add all Google AdMob SKAdNetwork IDs -->
    <!-- Full list: https://developers.google.com/admob/ios/quick-start#update_your_infoplist -->
</array>
```

**Important:**
- Replace `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` with your **actual AdMob App ID**
- Add all SKAdNetwork IDs from [Google's list](https://developers.google.com/admob/ios/quick-start#update_your_infoplist)

### C. Status Bar Settings

```xml
<key>UIStatusBarHidden</key>
<true/>
<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>
```

---

## 4. Xcode Project Configuration

### A. Add Packages (SPM)

Add Google Mobile Ads SDK:

1. Xcode → File → Add Package Dependencies
2. Enter: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
3. Version: `11.0.0` or latest
4. Add to target: `ArcadeOS`

### B. Capabilities

Enable these capabilities in Xcode:

1. **In-App Purchase**
   - Target → Signing & Capabilities → + Capability → In-App Purchase

2. **StoreKit Testing**
   - Add `Products.storekit` to your project
   - Scheme → Edit Scheme → Run → Options → StoreKit Configuration → Select `Products.storekit`

---

## 5. StoreKit Setup

### A. Products.storekit (Already Created)

File location: `ArcadeOS/Resources/StoreKit/Products.storekit`

Product configured:
- **Product ID:** `arcadepass.monthly`
- **Price:** $0.99/month
- **Type:** Auto-renewable subscription

### B. App Store Connect (Production)

1. Create app in App Store Connect
2. Go to **Features → In-App Purchases**
3. Create new **Auto-Renewable Subscription**:
   - Reference Name: `ArcadePass Monthly`
   - Product ID: `arcadepass.monthly`
   - Subscription Group: `ArcadePass`
   - Duration: `1 Month`
   - Price: `$0.99` (Tier 1)
4. Submit for review with app

---

## 6. AdMob Setup

### A. Create AdMob Account

1. Go to [AdMob Console](https://apps.admob.com/)
2. Create new app: **ArcadeOS – Retro Arcade**
3. Platform: **iOS**

### B. Create Rewarded Ad Unit

1. Apps → Your App → Ad Units → Add Ad Unit
2. Select: **Rewarded**
3. Name: `Premium Game Unlock`
4. Create ad unit
5. Copy **Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)

### C. Update Code

In `RewardedAdManager.swift`:

```swift
// Replace test ID with your production ad unit ID
private let adUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
```

**During development**, use test ID:
```swift
private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // Test ID
```

### D. Verify NPA (Non-Personalized Ads)

Code already implements NPA in `RewardedAdManager.swift`:

```swift
let extras = GADExtras()
extras.additionalParameters = ["npa": "1"]
request.register(extras)
```

✅ This ensures **no ATT prompt** is needed.

---

## 7. Build and Run

### A. Clean Build

1. Product → Clean Build Folder (⇧⌘K)
2. Delete Derived Data: `~/Library/Developer/Xcode/DerivedData/ArcadeOS-*`

### B. Run on Simulator

1. Select iOS Simulator (iPhone 15 recommended)
2. Product → Run (⌘R)

### C. Test Features

**Boot Screen:**
- Should show "Loading ArcadeOS..." with green terminal effect
- Plays `bootup.mp3` (if file exists)

**Desktop:**
- 100 game icons in responsive grid
- Single tap highlights, double tap opens
- Pong.exe is playable
- Other games show placeholder

**Premium Games:**
- Tap premium game (has ⭐ badge)
- Shows paywall modal
- Test "Watch Ad" (loads test ad)
- Test "Subscribe" (uses Products.storekit)

**Settings:**
- Not integrated into desktop yet (future feature)
- Can be added as Settings.exe icon

---

## 8. Testing Checklist

### StoreKit Testing

- [ ] Subscription purchase works in sandbox
- [ ] Restore purchases works
- [ ] Premium games unlock after subscription
- [ ] Subscription status persists across launches

### Ad Testing

- [ ] Test ads load successfully
- [ ] "Watch Ad" grants 30-minute temp access
- [ ] Cooldown prevents multiple unlocks (60 min)
- [ ] Daily limit enforced (2 per game per day)
- [ ] NPA parameter included in all ad requests

### Audio Testing

- [ ] Boot sound plays on launch
- [ ] Click sound plays on icon tap
- [ ] Boop sound plays on window close
- [ ] Sounds can be toggled in settings
- [ ] No crash if audio files missing

### Game Testing

- [ ] Pong is fully playable
- [ ] Score increments correctly
- [ ] AI paddle moves appropriately
- [ ] Game can restart
- [ ] Window closes with X button

---

## 9. Deployment

### A. Replace Test IDs

Before releasing to TestFlight/App Store:

1. **AdMob:** Replace test ad unit ID with production ID
2. **StoreKit:** Verify product ID matches App Store Connect

### B. App Store Submission

Required:
- Screenshots of all features
- App privacy details (no tracking, non-personalized ads)
- In-app purchase screenshot/description
- Test account with active subscription (for review)

### C. Privacy Policy

Required disclosures:
- Non-personalized ads (AdMob)
- Auto-renewable subscription ($0.99/month)
- No user tracking or personal data collection
- StoreKit for purchases

---

## 10. Common Issues

### Fonts Not Loading
- Ensure font files are in Copy Bundle Resources
- Verify font names in Info.plist match actual font names
- Check font names with `UIFont.familyNames`

### StoreKit "Cannot connect to iTunes Store"
- Enable StoreKit Configuration in scheme settings
- Use real device or iOS Simulator (not old simulators)
- Sign in with sandbox test account

### AdMob Ads Not Loading
- Check GADApplicationIdentifier in Info.plist
- Verify internet connection
- Test IDs work immediately; production IDs need approval
- Check Xcode console for AdMob error messages

### Audio Files Not Playing
- Ensure files are in Copy Bundle Resources
- Check file extensions match code (.mp3)
- Verify files are not corrupted

---

## 11. Next Steps

### Implement More Games

Follow `PongGameView.swift` pattern:

1. Create new file: `Games/YourGame/YourGameView.swift`
2. Implement SwiftUI game logic
3. Add to `WindowManager.swift`:

```swift
case "yourgame":
    YourGameView()
```

### Add Settings Icon to Desktop

In `DesktopView.swift`, add Settings.exe icon that opens `SettingsView()`.

### Enhance Premium Content

- Add 30+ unique premium games
- Create better icons (replace SF Symbols with custom art)
- Add game categories/folders

---

## 12. Support

- **StoreKit:** [Apple Documentation](https://developer.apple.com/documentation/storekit)
- **AdMob:** [Google AdMob iOS Guide](https://developers.google.com/admob/ios)
- **SwiftUI:** [Apple SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

---

✅ **Setup Complete!**

Your ArcadeOS app is ready to build and test. Follow the checklist above before submitting to the App Store.
