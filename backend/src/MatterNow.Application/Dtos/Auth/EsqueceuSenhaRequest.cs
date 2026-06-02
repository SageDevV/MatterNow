using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Auth;

public class EsqueceuSenhaRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; }
}
