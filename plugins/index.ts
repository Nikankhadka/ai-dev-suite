/**
 * ECC Plugins for OpenCode
 *
 * This module exports all ECC plugins for OpenCode integration.
 * Plugins provide hook-based automation across the full session, tool,
 * file, and shell lifecycle events exposed by OpenCode.
 */

export { ECCHooksPlugin, default } from "./ecc-hooks.js"

// Re-export for named imports
export * from "./ecc-hooks.js"
