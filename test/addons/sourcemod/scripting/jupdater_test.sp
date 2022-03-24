#include <sourcemod>
#include <jupdater>

public Plugin myinfo =
{
    name = "Test Plugin",
    author = "Bara",
    description = "",
    version = "1.0.2",
    url = "https://bara.dev"
};

public void OnPluginEnd()
{
    jUpdater_UnregisterPlugin();
}

public void OnAllPluginsLoaded()
{
    jUpdater_RegisterPlugin("https://raw.githubusercontent.com/Bara/jUpdater/main/test/updater.json", "https://raw.githubusercontent.com/Bara/jUpdater/main/test");
}
