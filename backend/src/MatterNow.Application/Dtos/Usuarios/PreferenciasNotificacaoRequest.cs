namespace MatterNow.Application.Dtos.Usuarios;

public class PreferenciasNotificacaoRequest
{
    /// Lista de chaves: "email", "push", "messages".
    public List<string> Chaves { get; set; } = new();
}

public class PreferenciasNotificacaoResponse
{
    public bool Email { get; set; }
    public bool Push { get; set; }
    public bool Mensagens { get; set; }
}
