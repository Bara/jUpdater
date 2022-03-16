#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

#define MAX_URL_LENGTH 512
#define MAX_VERSION_LENGTH 32

enum struct PluginData {
    Handle Plugin;

    char Name[MAX_NAME_LENGTH];
    char Version[MAX_VERSION_LENGTH];
    char URL[MAX_URL_LENGTH];
    char FileName[PLATFORM_MAX_PATH];
}

ArrayList g_aPlugins = null;

public Plugin myinfo =
{
    name = "jUpdater",
    author = "Bara",
    description = "New plugin updater from scratch which use ripext and json.",
    version = "1.0.0",
    url = "https://bara.dev"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("jupdater");

    CreateNative("jUpdater_RegisterPlugin", Native_RegisterPlugin);

    return APLRes_Success;
}

public void OnPluginStart()
{
    g_aPlugins = new ArrayList(sizeof(PluginData));

    RegAdminCmd("sm_listplugins", Command_ListPlugins, ADMFLAG_ROOT);
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
        ReplyToCommand(client, "Plugin: %s, Version: %s, File: %s, URL: %s", tmp.Name, tmp.Version, tmp.FileName, tmp.URL);
    }

    return Plugin_Handled;
}

public any Native_RegisterPlugin(Handle plugin, int numParams)
{
    char sName[MAX_NAME_LENGTH];
    if (!GetPluginInfo(plugin, PlInfo_Name, sName, sizeof(sName)))
    {
        ThrowNativeError(SP_ERROR_NATIVE, "No plugin name found.");
        return false;
    }

    char sVersion[MAX_VERSION_LENGTH];
    if (!GetPluginInfo(plugin, PlInfo_Version, sVersion, sizeof(sVersion)))
    {
        ThrowNativeError(SP_ERROR_NATIVE, "No plugin version found.");
        return false;
    }

    PluginData pdPlugin;
    pdPlugin.Plugin = plugin;
    strcopy(pdPlugin.Name, sizeof(PluginData::Name), sName);
    strcopy(pdPlugin.Version, sizeof(PluginData::Version), sVersion);
    GetPluginFilename(plugin, pdPlugin.FileName, sizeof(PluginData::FileName));
    GetNativeString(1, pdPlugin.URL, sizeof(PluginData::URL));

    int index = g_aPlugins.PushArray(pdPlugin, sizeof(pdPlugin));
    LogMessage("Plugin \"%s\" (%d) was successfully registered.", pdPlugin.Name, index);

    // TODO Trigger update check

    return true;
}
