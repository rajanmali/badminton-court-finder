const { withAndroidManifest } = require('@expo/config-plugins');

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
  ],
};

module.exports = config;
