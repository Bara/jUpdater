#include <sourcemod>
#include <jupdater>

public Plugin myinfo =
{
    name = "Test Plugin",
    author = "Bara",
    description = "",
    version = "1.0.3",
    url = "https://bara.dev"
};

public void OnAllPluginsLoaded()
{
    RegisterPlugin();
}

public void jUpdater_OnPluginReady()
{
    RegisterPlugin();
}

void RegisterPlugin()
{
    jUpdater_RegisterPlugin("https://raw.githubusercontent.com/Bara/jUpdater/main/test/updater.json", "https://raw.githubusercontent.com/Bara/jUpdater/main/test");
}

public void OnPluginEnd()
{
    jUpdater_UnregisterPlugin();
}
