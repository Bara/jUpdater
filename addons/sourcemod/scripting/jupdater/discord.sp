void PostDiscordNotification(const char[] name, const char[] localVersion, const char[] onlineVersion, const char[] changeLogs)
{
    char sWebhook[MAX_URL_LENGTH];
    Core.DiscordWebhook.GetString(sWebhook, sizeof(sWebhook));

    if (strlen(sWebhook) < 1)
    {
        return;
    }

    char sMessage[512];
    FormatEx(sMessage, sizeof(sMessage), "Update for %s available!", name);

    Embed eEmbed = new Embed();
    eEmbed.SetColor(16758272);
    EmbedField eVersion = new EmbedField("Version", localVersion, true);
    eEmbed.AddField(eVersion);
    EmbedField eNewVersion = new EmbedField("New Version", onlineVersion, true);
    eEmbed.AddField(eNewVersion);
    EmbedField eChangelogs = new EmbedField("Changelogs", changeLogs, false);
    eEmbed.AddField(eChangelogs);

    Webhook wWebhook = new Webhook();
    wWebhook.SetContent(sMessage);
    wWebhook.AddEmbed(eEmbed);
    wWebhook.Execute(sWebhook, OnWebHookExecuted);
    delete wWebhook;
}

public void OnWebHookExecuted(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_NoContent)
    {
        LogError("[Discord.OnWebHookExecuted] An error has occured while sending the webhook. Status Code: %d", response.Status);
    }
}
