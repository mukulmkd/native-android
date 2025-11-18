const path = require("path");
const { getDefaultConfig, mergeConfig } = require("@react-native/metro-config");

const projectRoot = __dirname;
const nodeModules = path.join(projectRoot, "node_modules");

const defaultConfig = getDefaultConfig(projectRoot);

module.exports = mergeConfig(defaultConfig, {
  resolver: {
    nodeModulesPaths: [nodeModules],
    // Allow optional dependencies like expo (used in modules but not required for native bundles)
    unstable_enablePackageExports: true,
  },
  watchFolders: [nodeModules],
});

