public Action Timer_CheckForUpdates(Handle timer)
{
    if (Core.Debug.BoolValue && g_aPlugins.Length == 0)
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

        return;
    }

    JSONObject jInfos = view_as<JSONObject>((view_as<JSONObject>(response.Data).Get("Informations")));
    JSONObject jSettings = view_as<JSONObject>((view_as<JSONObject>(response.Data).Get("Settings")));
    JSONObject jFiles = view_as<JSONObject>((view_as<JSONObject>(response.Data).Get("Files")));

    char sVersion[MAX_VERSION_LENGTH];
    jInfos.GetString("Version", sVersion, sizeof(sVersion));

    char sBuffer[MAX_VERSION_LENGTH];
    strcopy(sBuffer, sizeof(sBuffer), pdPlugin.Version);
    int iLocalVersion = GetIntVersion(sBuffer, sizeof(sBuffer));

    strcopy(sBuffer, sizeof(sBuffer), sVersion);
    int iOnlineVersion = GetIntVersion(sBuffer, sizeof(sBuffer));
    
    bool bOkay = (iLocalVersion >= iOnlineVersion) ? true : false;

    if (Core.Debug.BoolValue && bOkay)
    {
        PrintToServer("Plugin: %s, LocalVersion: %s, OnlineVersion: %s", pdPlugin.Name, pdPlugin.Version, sVersion);
    }

    if (!bOkay)
    {
        JSONArray jChanges = view_as<JSONArray>(jInfos.Get("Changelogs"));

        char sChange[64];
        char sChangelogs[512];
        for (int i = 0; i < jChanges.Length; i++)
        {
            jChanges.GetString(i, sChange, sizeof(sChange));
            Format(sChangelogs, sizeof(sChangelogs), "%s [%d] %s\n", sChangelogs, i + 1, sChange);
            sChange[0] = '\0';
        }

        delete jChanges;

        if (GetObjectBool(jSettings, "UpdateFiles") && jFiles.Size > 0)
        {
            JSONObjectKeys jDirectories = jFiles.Keys();

            char sDirectory[32];
            char sFile[PLATFORM_MAX_PATH];
            char sPath[PLATFORM_MAX_PATH];
            char sURL[MAX_URL_LENGTH];
            while (jDirectories.ReadKey(sDirectory, sizeof(sDirectory)))
            {
                JSONArray jFile = view_as<JSONArray>(jFiles.Get(sDirectory));

                for (int i = 0; i < jFile.Length; i++)
                {
                    jFile.GetString(i, sFile, sizeof(sFile));

                    if (sDirectory[0] != 'r')
                    {
                        BuildPath(Path_SM, sPath, sizeof(sPath), "%s/%s", sDirectory, sFile);
                    }
                    else
                    {
                        FormatEx(sPath, sizeof(sPath), "%s", sFile);
                    }

                    Format(sURL, sizeof(sURL), "%s/%s", pdPlugin.BaseURL, sPath);
                    if (Core.Debug.BoolValue)
                    {
                        PrintToServer("URL: %s", sURL);
                    }

                    CreateDirectories(sPath);

                    DataPack pack = new DataPack();
                    pack.WriteString(sPath);
                    pack.WriteCell(view_as<int>(GetObjectBool(jSettings, "ReloadPlugin")));
                    pack.WriteCell(view_as<int>(GetObjectBool(jSettings, "ReloadNewPlugins")));
                    pack.WriteString(pdPlugin.FileName);

                    HTTPRequest request = new HTTPRequest(sURL);
                    request.DownloadFile(sPath, OnFileDownloaded, pack);

                    sFile[0] = '\0';
                }

                delete jFile;
            }
            delete jDirectories;
        }

        if (GetObjectBool(jSettings, "LogUpdate"))
        {
            LogMessage("Update for %s from version %s to %s is available! Changelogs:\n%s", pdPlugin.Name, pdPlugin.Version, sVersion, sChangelogs);
        }

        if (GetObjectBool(jSettings, "DiscordNotification"))
        {
            PostDiscordNotification(pdPlugin.Name, pdPlugin.Version, sVersion, sChangelogs);
        }
    }

    delete jInfos;
    delete jSettings;
}

public void OnFileDownloaded(HTTPStatus status, DataPack pack, const char[] error)
{
    pack.Reset();

    char sPath[PLATFORM_MAX_PATH];
    pack.ReadString(sPath, sizeof(sPath));

    bool bReload = view_as<bool>(pack.ReadCell());
    bool bReloadNew = view_as<bool>(pack.ReadCell());

    char sFileName[PLATFORM_MAX_PATH];
    pack.ReadString(sFileName, sizeof(sFileName));

    delete pack;

    if (status != HTTPStatus_OK)
    {
        LogError("Can't download file \"%s\".", sPath);
        return;
    }

    if (Core.Debug.BoolValue)
    {
        PrintToServer("File \"%s\" downloaded!", sPath);
    }

    if (bReload && StrContains(sPath, ".smx", false) != -1)
    {
        if (Core.Debug.BoolValue)
        {
            PrintToServer("smx-File found.");
        }

        if (StrContains(sPath, sFileName, false) != -1)
        {
            ServerCommand("sm plugins reload %s", sFileName);
        }
        else if (bReloadNew)
        {
            ReplaceString(sPath, sizeof(sPath), "addons/sourcemod/plugins/", "", false);
            ReplaceString(sPath, sizeof(sPath), ".smx", "", false);

            ServerCommand("sm plugins load %s", sPath);
        }
    }
}

int GetIntVersion(char[] version, int size)
{
    ReplaceString(version, size, ".", "", false);
    return StringToInt(version);
}

bool GetObjectBool(JSONObject obj, const char[] key)
{
    if (obj.HasKey(key))
    {
        return obj.GetBool(key);
    }

    return false;
}

void CreateDirectories(const char[] path)
{
    char sDirectories[32][PLATFORM_MAX_PATH];
    char sDirectory[PLATFORM_MAX_PATH];

    int iNumDirectories = ExplodeString(path, "/", sDirectories, sizeof(sDirectories), sizeof(sDirectories[]));

    // Remove file.extension
    iNumDirectories -= 1;

    for (int i = 0; i < iNumDirectories; i++)
    {
        FormatEx(sDirectory, sizeof(sDirectory), "%s%s%s", sDirectory, (i > 0) ? "/" : "", sDirectories[i]);

        if (DirExists(sDirectory))
        {
            continue;
        }

        CreateDirectory(sDirectory, FPERM_U_READ|FPERM_U_WRITE|FPERM_U_EXEC|FPERM_G_READ|FPERM_G_EXEC|FPERM_O_READ|FPERM_O_EXEC);

        if (Core.Debug.BoolValue)
        {
            PrintToServer("Directory \"%s\" created.", sDirectory);
        }
    }
}
