#include <sourcemod>
#include <jupdater>

public Plugin myinfo =
{
    name = "jUpdater - Test200",
    author = "Bara",
    description = "",
    version = "1.0.0",
    url = "https://bara.dev"
};

public void OnPluginEnd()
{
    jUpdater_UnregisterPlugin();
}

public void OnConfigsExecuted()
{
    AddToUpdater();
}

void AddToUpdater()
{
    if (!jUpdater_RegisterPlugin("https://raw.githubusercontent.com/Bara/jUpdater/main/examples/updater.example.json"))
    {
        SetFailState("Noooooo.....");
    }
}
