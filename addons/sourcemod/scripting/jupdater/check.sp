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

        PrintToServer("Check for new updates for \"%s\"", tmp.Name);
        
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
        return;
    }
}
