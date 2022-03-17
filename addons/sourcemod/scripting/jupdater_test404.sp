#include <sourcemod>
#include <jupdater>

public Plugin myinfo =
{
    name = "jUpdater - Test404",
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
    AddToUpdater();
}

void AddToUpdater()
{
    if (!jUpdater_RegisterPlugin("https://raw.githubusercontent.com/Bara/jUpdater/main/examples/updater.example.json1"))
    {
        SetFailState("Noooooo.....");
    }
}