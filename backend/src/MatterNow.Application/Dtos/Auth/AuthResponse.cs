namespace MatterNow.Application.Dtos.Auth;

public class AuthResponse
{
    public Guid UsuarioId { get; set; }
    public string Nome { get; set; }
    public string Email { get; set; }
    public string Token { get; set; }
    public DateTime ExpiraEm { get; set; }
}
