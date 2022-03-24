/*
    TODO List
        Debug messages (atm some PrintToServer)
        Detect smx files and load it (shouldn't match the original filename)
*/

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <autoexecconfig>
#include <ripext>
#include <discordWebhookAPI>

#define MAX_URL_LENGTH 512
#define MAX_VERSION_LENGTH 32

enum struct Globals {
    ConVar Interval;
    ConVar DiscordWebhook;
}

Globals Core;

enum struct PluginData {
    Handle Plugin;

    char Name[MAX_NAME_LENGTH];
    char Version[MAX_VERSION_LENGTH];
    char URL[MAX_URL_LENGTH];
    char BaseURL[MAX_URL_LENGTH];
    char FileName[PLATFORM_MAX_PATH];
}

ArrayList g_aPlugins = null;

#include "jupdater/api.sp"
#include "jupdater/check.sp"
#include "jupdater/discord.sp"

public Plugin myinfo =
{
    name = "jUpdater",
    author = "Bara",
    description = "New plugin updater from scratch which use ripext and json.",
    version = "1.0.0",
    url = "https://bara.dev"
};

public void OnPluginStart()
{
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile("jupdater");
    Core.Interval = AutoExecConfig_CreateConVar("jupdater_check_interval", "10", "Interval in seconds for checking for plugin updates.");
    Core.DiscordWebhook = AutoExecConfig_CreateConVar("jupdater_discord_webhook", "", "Set your discord webhook url if you want update notifications on discord", _, true, 0.0, true, 1.0);
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

    g_aPlugins = new ArrayList(sizeof(PluginData));

    RegAdminCmd("sm_listplugins", Command_ListPlugins, ADMFLAG_ROOT);
}

public void OnConfigsExecuted()
{
    CreateTimer(Core.Interval.FloatValue, Timer_CheckForUpdates, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Command_ListPlugins(int client, int args)
{
    if (g_aPlugins.Length == 0)
    {
        ReplyToCommand(client, "No plugins registered.");
        return Plugin_Handled;
    }

    ReplyToCommand(client, "Found %d plugin%s:", g_aPlugins.Length, (g_aPlugins.Length > 1) ? "s" : "");
    for (int i = 0; i < g_aPlugins.Length; i++)
    {
        PluginData tmp;
        g_aPlugins.GetArray(i, tmp, sizeof(tmp));
        ReplyToCommand(client, "Plugin: %s, Version: %s, File: %s, URL: %s, BaseURL: %s", tmp.Name, tmp.Version, tmp.FileName, tmp.URL, tmp.BaseURL);
    }

    return Plugin_Handled;
}
