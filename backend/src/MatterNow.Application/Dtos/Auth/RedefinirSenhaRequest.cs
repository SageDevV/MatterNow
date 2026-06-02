using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Auth;

public class RedefinirSenhaRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; }

    [Required]
    [StringLength(8, MinimumLength = 4)]
    public string Codigo { get; set; }

    [Required]
    [StringLength(64, MinimumLength = 6, ErrorMessage = "Senha deve ter entre 6 e 64 caracteres.")]
    public string NovaSenha { get; set; }
}
