public Action Timer_CheckForUpdates(Handle timer)
{
    if (g_aPlugins.Length == 0)
    {
        PrintToServer("No plugins found to check for updates.");
        return Plugin_Continue;
    }

    PrintToServer("Checking for new plugin updates...");

    for (int i = 0; i < g_aPlugins.Length; i++)
    {
        PluginData tmp;
        g_aPlugins.GetArray(i, tmp, sizeof(tmp));
        
        HTTPRequest request = new HTTPRequest(tmp.URL);
        request.Get(GetPluginInformations, tmp.Plugin);
    }

    return Plugin_Continue;
}

public void GetPluginInformations(HTTPResponse response, Handle plugin, const char[] error)
{
    PluginData pdPlugin;

    for (int i = 0; i < g_aPlugins.Length; i++)
    {
        g_aPlugins.GetArray(i, pdPlugin, sizeof(pdPlugin));
        
        if (pdPlugin.Plugin == plugin)
        {
            break;
        }
    }

    if (response.Status != HTTPStatus_OK)
    {
        LogError("Error while checking for plugin updates. (Plugin: \"%s\", Error Code: %d)", pdPlugin.Name, response.Status);

        PrintToServer(" "); // TODO In debug mode?
        return;
    }

    JSONObject jInfos = view_as<JSONObject>((view_as<JSONObject>(response.Data).Get("Informations")));

    char sVersion[MAX_VERSION_LENGTH];
    jInfos.GetString("Version", sVersion, sizeof(sVersion));

    char sBuffer[MAX_VERSION_LENGTH];
    strcopy(sBuffer, sizeof(sBuffer), pdPlugin.Version);
    int iLocalVersion = GetIntVersion(sBuffer, sizeof(sBuffer));

    strcopy(sBuffer, sizeof(sBuffer), sVersion);
    int iOnlineVersion = GetIntVersion(sBuffer, sizeof(sBuffer));
    
    bool bOkay = (iLocalVersion >= iOnlineVersion) ? true : false;

    PrintToServer("Plugin: %s, LocalVersion: %s, OnlineVersion: %s, Status: %s", pdPlugin.Name, pdPlugin.Version, sVersion, (bOkay) ? "Up2date" : "Outdated, Changelogs:");

    if (!bOkay)
    {
        JSONArray jChanges = view_as<JSONArray>(jInfos.Get("Changelogs"));

        char sChange[64];
        for (int i = 0; i < jChanges.Length; i++)
        {
            jChanges.GetString(i, sChange, sizeof(sChange));
            PrintToServer(" [%d] %s", i + 1, sChange);
            sChange[0] = '\0';
        }

        delete jChanges;
    }

    PrintToServer(" "); // TODO In debug mode?

    delete jInfos;
}

int GetIntVersion(char[] version, int size)
{
    ReplaceString(version, size, ".", "", false);
    return StringToInt(version);
}
