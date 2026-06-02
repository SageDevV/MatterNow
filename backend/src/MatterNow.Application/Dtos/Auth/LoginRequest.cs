using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Auth;

public class LoginRequest
{
    [Required(ErrorMessage = "E-mail é obrigatório.")]
    [EmailAddress(ErrorMessage = "E-mail inválido.")]
    public string Email { get; set; }

    [Required(ErrorMessage = "Senha é obrigatória.")]
    public string Senha { get; set; }
}
