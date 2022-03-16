#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

#define MAX_URL_LENGTH 512

enum struct PluginData {
    Handle Plugin;

    char Name[MAX_NAME_LENGTH];
    char URL[MAX_URL_LENGTH];
}

ArrayList g_aPlugins = null;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("jupdater");

    CreateNative("jUpdater_RegisterPlugin", Native_RegisterPlugin);

    return APLRes_Success;
}

public void OnPluginStart()
{
    g_aPlugins = new ArrayList(sizeof(PluginData));
}

public any Native_RegisterPlugin(Handle plugin, int numParams)
{
    bool bReplace = view_as<bool>(GetNativeCell(2));
    
    if (!bReplace)
    {
        for (int i = 0; i < g_aPlugins.Length; i++)
        {
            PluginData tmp;
            g_aPlugins.GetArray(i, tmp, sizeof(tmp));

            if (tmp.Plugin == plugin)
            {
                return false;
            }
        }
    }

    char sName[MAX_NAME_LENGTH];
    if (!GetPluginInfo(plugin, PlInfo_Name, sName, sizeof(sName)))
    {
        return false;
    }

    PluginData pdPlugin;
    pdPlugin.Plugin = plugin;
    strcopy(pdPlugin.Name, sizeof(PluginData::Name), sName);
    GetNativeString(1, pdPlugin.URL, sizeof(PluginData::URL));

    return true;
}
