#if defined _jupdater_included
  #endinput
#endif
#define _jupdater_included

/**
 * Register your plugin with the url which will be used for checking for updates.
 * You can replace the existing url by set replace to true, which is false by default.
 *
 * @return		True, plugin was successfully registered. Otherwise it's false.
 * @error		Plugin is already registered or plugin has no name.
 */
native bool jUpdater_RegisterPlugin(const char[] url, bool replace = false);

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
}
#endif
