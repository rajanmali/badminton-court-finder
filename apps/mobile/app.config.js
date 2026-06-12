const { withAndroidManifest, withDangerousMod } = require('@expo/config-plugins');
const path = require('path');
const fs = require('fs');

// CocoaPods prebuilt tarballs use Pathname operations that break on paths containing
// spaces (this project lives in "Badminton Court Availability App/"). Force React Native
// to build from source so the tarball download path is never hit.
const withBuildFromSource = (config) =>
  withDangerousMod(config, [
    'ios',
    (c) => {
      const propsPath = path.join(c.modRequest.platformProjectRoot, 'Podfile.properties.json');
      if (fs.existsSync(propsPath)) {
        const props = JSON.parse(fs.readFileSync(propsPath, 'utf8'));
        props['ios.buildReactNativeFromSource'] = 'true';
        props['EXPO_USE_PRECOMPILED_MODULES'] = 'false';
        fs.writeFileSync(propsPath, JSON.stringify(props, null, 2));
      }
      return c;
    },
  ]);

// MapLibreReactNative delivers its native framework via SPM (not a CocoaPods dep).
// Its podspec registers $MLRN.post_install which adds the SPM reference to the Xcode
// project, but Expo's generated Podfile doesn't call it. Patch the Podfile so it does.
const withMapLibrePostInstall = (config) =>
  withDangerousMod(config, [
    'ios',
    (c) => {
      const podfilePath = path.join(c.modRequest.platformProjectRoot, 'Podfile');
      if (fs.existsSync(podfilePath)) {
        let podfile = fs.readFileSync(podfilePath, 'utf8');
        if (!podfile.includes('$MLRN.post_install')) {
          podfile = podfile.replace(
            'react_native_post_install(',
            '$MLRN.post_install(installer)\n    react_native_post_install('
          );
          fs.writeFileSync(podfilePath, podfile);
        }
      }
      return c;
    },
  ]);

/** @type {import('expo/config').ExpoConfig} */
const config = {
  name: 'Smash',
  slug: 'smash',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  ios: {
    supportsTablet: false,
    bundleIdentifier: 'com.rajanmali.smash',
    infoPlist: {
      ITSAppUsesNonExemptEncryption: false,
    },
  },
  android: {
    package: 'com.rajanmali.smash',
    adaptiveIcon: {
      backgroundColor: '#00C853',
      foregroundImage: './assets/android-icon-foreground.png',
      backgroundImage: './assets/android-icon-background.png',
      monochromeImage: './assets/android-icon-monochrome.png',
    },
    predictiveBackGestureEnabled: false,
  },
  owner: 'notrajanmali',
  extra: {
    apiUrl: process.env.EXPO_PUBLIC_API_URL ?? 'http://localhost:3000/api/v1',
    eas: {
      projectId: 'aaa9f3ed-dca9-4779-8b95-15db63604cfe',
    },
  },
  plugins: [
    'expo-dev-client',
    [
      'expo-location',
      {
        locationWhenInUsePermission: 'Smash uses your location to find badminton courts near you.',
      },
    ],
    // Inject Maptiler API key into AndroidManifest.xml for MapLibre
    [
      withAndroidManifest,
      (config) => {
        const maptilerKey = process.env.MAPTILER_API_KEY ?? '';
        const manifest = config.modResults;
        const application = manifest.manifest.application?.[0];
        if (application) {
          application['meta-data'] = application['meta-data'] ?? [];
          application['meta-data'].push({
            $: {
              'android:name': 'MAPTILER_API_KEY',
              'android:value': maptilerKey,
            },
          });
        }
        return config;
      },
    ],
    withBuildFromSource,
    withMapLibrePostInstall,
  ],
};

module.exports = config;
