#include <sourcemod>
#include <jupdater>

public Plugin myinfo =
{
    name = "jUpdater - Test",
    author = "Bara",
    description = "",
    version = "1.0.0",
    url = "https://bara.dev"
};

public void OnConfigsExecuted()
{
    AddToUpdater();
}

void AddToUpdater()
{
    if (!jUpdater_RegisterPlugin("https://csgottt.com/jupdater/updater.json"))
    {
        SetFailState("Noooooo.....");
    }
}
