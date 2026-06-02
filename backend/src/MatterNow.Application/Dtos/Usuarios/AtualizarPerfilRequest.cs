using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Usuarios;

public class AtualizarPerfilRequest
{
    [StringLength(120, MinimumLength = 2)]
    public string Nome { get; set; }

    [StringLength(180)]
    public string Localizacao { get; set; }

    [StringLength(120)]
    public string Avatar { get; set; }

    public List<string> Interesses { get; set; } = new();
}
