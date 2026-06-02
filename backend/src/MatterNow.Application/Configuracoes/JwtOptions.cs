namespace MatterNow.Application.Configuracoes;

public class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Issuer { get; set; }
    public string Audience { get; set; }
    public string SigningKey { get; set; }
    public int ExpiracaoMinutos { get; set; } = 60 * 8; // 8h
}
