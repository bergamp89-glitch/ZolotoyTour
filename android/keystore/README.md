# Keystore Directory for Release Signing

Place your production release keystore file here:
`android/keystore/zolotoytour-release.jks`

### How to generate the release keystore:

Run this command in your terminal (PowerShell or Bash):

```bash
keytool -genkey -v -keystore android/keystore/zolotoytour-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zolotoytour
```

Then edit `android/key.properties`:

```properties
storePassword=YOUR_ACTUAL_STORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=zolotoytour
storeFile=../keystore/zolotoytour-release.jks
```

> **IMPORTANT**:
> 1. Never commit `zolotoytour-release.jks` or `key.properties` to Git! (Both are already added to `.gitignore`).
> 2. Keep a secure backup of `zolotoytour-release.jks` and your passwords. If you lose this key, you will not be able to update your app on Google Play!
