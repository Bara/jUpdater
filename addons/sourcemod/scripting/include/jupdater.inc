#if defined _jupdater_included
  #endinput
#endif
#define _jupdater_included

/**
 * This forward will called when jUpdater was reloaded due manually update or due an self update.
 */
forward void jUpdater_OnPluginReady();

/**
 * Register your plugin with the url which will be used for update checks.
 * Base URL is the absolute url to the directory where are the update files located (without(!) ending slash).
 *
 * @return		true - successfully registered, otherwise false
 */
native bool jUpdater_RegisterPlugin(const char[] url, const char[] baseURL);

/**
 * Unregister your plugin for update checks.
 *
 * @return		true - successfully registered, otherwise false
 */
native bool jUpdater_UnregisterPlugin();

/**
 * Force update check for all registered plugins
 */
native void jUpdater_ForceUpdateCheck();

public SharedPlugin __pl_jupdater = 
{
    name = "jupdater",
    file = "jupdater.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_jupdater_SetNTVOptional()
{
    MarkNativeAsOptional("jUpdater_RegisterPlugin");
    MarkNativeAsOptional("jUpdater_UnregisterPlugin");
    MarkNativeAsOptional("jUpdater_ForceUpdateCheck");
}
#endif
