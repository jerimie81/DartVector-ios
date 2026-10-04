# Apple signing for GitHub Actions

This repository expects a remote macOS runner to build and sign the iOS app. The workflow will look for the following GitHub repository secrets:

- `APPLE_CERTIFICATE`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISIONING_PROFILE`
- `APPLE_TEAM_ID`
- `APPLE_ISSUER_ID`
- `APPLE_KEY_ID`
- `APPLE_PRIVATE_KEY`

## Where to add them

In GitHub:

1. Open the repository.
2. Go to Settings > Secrets and variables > Actions.
3. Add the values above.

## What each secret is for

- `APPLE_CERTIFICATE`: base64-encoded `.p12` certificate.
- `APPLE_CERTIFICATE_PASSWORD`: password for that certificate.
- `APPLE_PROVISIONING_PROFILE`: provisioning profile used for the app bundle.
- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `APPLE_ISSUER_ID`: App Store Connect issuer ID.
- `APPLE_KEY_ID`: App Store Connect API key ID.
- `APPLE_PRIVATE_KEY`: App Store Connect private key content.

## Typical generation steps

1. Create a signing certificate in Xcode or Apple Developer.
2. Export it as a `.p12` file.
3. Base64 encode it:
   `base64 -i MyCert.p12 | pbcopy`
4. Export the provisioning profile for the app bundle.
5. Create an App Store Connect API key and save the key ID and private key.
6. Add all values as GitHub Actions secrets.

When the secrets are present, the workflow will build and archive the app automatically. Without them, the workflow still validates the static export and the simulator build path, but it will not sign or export a distributable `.ipa`.
