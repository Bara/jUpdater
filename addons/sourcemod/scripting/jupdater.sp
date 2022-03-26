#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <autoexecconfig>
#include <ripext>
#include <discordWebhookAPI>

#define UPDATER_NAME "jUpdater"
#define UPDATER_VERSION "1.0.0"
#define UPDATER_URL "https://raw.githubusercontent.com/Bara/jUpdater/main/updater.json"
#define UPDATER_BASEURL "https://raw.githubusercontent.com/Bara/jUpdater/main"

#define MAX_URL_LENGTH 512
#define MAX_VERSION_LENGTH 32

enum struct Globals {
    ConVar DiscordWebhook;
    ConVar Debug;

    bool LateLoad;
    Handle MySelf;

    GlobalForward OnPluginReady;
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
    name = UPDATER_NAME,
    author = "Bara",
    description = "New plugin updater from scratch which use ripext and json.",
    version = UPDATER_VERSION,
    url = "https://bara.dev"
};

public void OnPluginStart()
{
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile("jupdater");
    Core.DiscordWebhook = AutoExecConfig_CreateConVar("jupdater_discord_webhook", "", "Set your discord webhook url if you want update notifications on discord", _, true, 0.0, true, 1.0);
    Core.Debug = AutoExecConfig_CreateConVar("jupdater_debug", "1", "Enable/Disable debug mode/messages", _, true, 0.0, true, 1.0);
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();

    g_aPlugins = new ArrayList(sizeof(PluginData));
    AddMySelfToArray();

    CreateTimer(10800.0, Timer_CheckForUpdates, _, TIMER_REPEAT);

    RegAdminCmd("sm_listplugins", Command_ListPlugins, ADMFLAG_ROOT);
}

public void OnAllPluginsLoaded()
{
    if (Core.LateLoad)
    {
        Call_StartForward(Core.OnPluginReady);
        Call_Finish();
    }
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

void AddMySelfToArray()
{
    PluginData pdPlugin;
    pdPlugin.Plugin = Core.MySelf;
    strcopy(pdPlugin.Name, sizeof(PluginData::Name), UPDATER_NAME);
    strcopy(pdPlugin.Version, sizeof(PluginData::Version), UPDATER_VERSION);
    strcopy(pdPlugin.URL, sizeof(PluginData::URL), UPDATER_URL);
    strcopy(pdPlugin.BaseURL, sizeof(PluginData::BaseURL), UPDATER_BASEURL);
    GetPluginFilename(Core.MySelf, pdPlugin.FileName, sizeof(PluginData::FileName));

    AddPluginToArray(pdPlugin);
}
