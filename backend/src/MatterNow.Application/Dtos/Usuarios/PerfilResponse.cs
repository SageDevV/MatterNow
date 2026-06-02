namespace MatterNow.Application.Dtos.Usuarios;

public class PerfilResponse
{
    public Guid Id { get; set; }
    public string Nome { get; set; }
    public string Email { get; set; }
    public string Telefone { get; set; }
    public string Localizacao { get; set; }
    public string Avatar { get; set; }
    public IReadOnlyList<string> Interesses { get; set; } = Array.Empty<string>();
}
