import { AppRegistry } from "react-native";

// Import modules to trigger their AppRegistry registration
import "@app/module-products"; // Registers "ModuleProducts"
import "@app/module-cart";     // Registers "ModuleCart"
import "@app/module-pdp";      // Registers "ModulePDP"

// Each module package already registers itself with AppRegistry
// We just need to ensure they're imported so the registration happens

