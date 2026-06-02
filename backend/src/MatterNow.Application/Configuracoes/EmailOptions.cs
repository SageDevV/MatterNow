namespace MatterNow.Application.Configuracoes;

public class EmailOptions
{
    public const string SectionName = "Email";

    /// "Console" (apenas loga no terminal) ou "Smtp" (envio real).
    public string Provider { get; set; } = "Console";

    public string FromAddress { get; set; } = "no-reply@matternow.test";
    public string FromName { get; set; } = "MatterNow";

    public string Host { get; set; }
    public int Port { get; set; } = 587;
    public bool UseStartTls { get; set; } = true;
    public string Username { get; set; }
    public string Password { get; set; }
}
