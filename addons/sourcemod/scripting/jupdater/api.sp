public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("jupdater");

    CreateNative("jUpdater_RegisterPlugin", Native_RegisterPlugin);
    CreateNative("jUpdater_UnregisterPlugin", Native_UnregisterPlugin);
    CreateNative("jUpdater_ForceUpdateCheck", Native_ForceUpdateCheck);

    Core.LateLoad = late;
    Core.MySelf = myself;

    Core.OnPluginReady = new GlobalForward("jUpdater_OnPluginReady", ET_Ignore);

    return APLRes_Success;
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
    GetNativeString(2, pdPlugin.BaseURL, sizeof(PluginData::BaseURL));

    AddPluginToArray(pdPlugin);

    return true;
}

void AddPluginToArray(PluginData pdPlugin)
{
    int index = g_aPlugins.PushArray(pdPlugin, sizeof(pdPlugin));
    if (Core.Debug.BoolValue)
    {
        PrintToServer("Plugin \"%s\" (%d) was successfully registered.", pdPlugin.Name, index);
    }

    if (Core.UpdateCheckOnRegister.BoolValue)
    {
        HTTPRequest request = new HTTPRequest(pdPlugin.URL);
        request.Get(GetPluginInformations, pdPlugin.Plugin);
    }
}

public any Native_UnregisterPlugin(Handle plugin, int numParams)
{
    for (int i = 0; i < g_aPlugins.Length; i++)
    {
        PluginData tmp;
        g_aPlugins.GetArray(i, tmp, sizeof(tmp));
        
        if (tmp.Plugin == plugin)
        {
            g_aPlugins.Erase(i);
            return true;
        }
    }

    return false;
}

public any Native_ForceUpdateCheck(Handle plugin, int numParams)
{
    PrintToServer("Forcing update check. Okay, I'll check for new updates...");

    if (Core.UpdateTimer != null)
    {
        TriggerTimer(Core.UpdateTimer);
    }
    else
    {
        for (int i = 0; i < g_aPlugins.Length; i++)
        {
            PluginData tmp;
            g_aPlugins.GetArray(i, tmp, sizeof(tmp));
            
            HTTPRequest request = new HTTPRequest(tmp.URL);
            request.Get(GetPluginInformations, tmp.Plugin);
        }
    }
}
