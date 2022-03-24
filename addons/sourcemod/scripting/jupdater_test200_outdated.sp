#include <sourcemod>
#include <jupdater>

public Plugin myinfo =
{
    name = "jUpdater - Test200 - Outdated",
    author = "Bara",
    description = "",
    version = "1.0.0",
    url = "https://bara.dev"
};

public void OnPluginEnd()
{
    jUpdater_UnregisterPlugin();
}

public void OnAllPluginsLoaded()
{
    jUpdater_RegisterPlugin("https://raw.githubusercontent.com/Bara/jUpdater/main/examples/updater.example101.json", "https://raw.githubusercontent.com/Bara/jUpdater/main");
}
