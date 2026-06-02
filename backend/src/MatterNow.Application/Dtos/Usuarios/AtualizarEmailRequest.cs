using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Usuarios;

public class AtualizarEmailRequest
{
    [Required]
    [EmailAddress]
    [StringLength(180)]
    public string Email { get; set; }
}
