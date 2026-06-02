using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Auth;

public class RegistrarUsuarioRequest
{
    [Required(ErrorMessage = "Nome é obrigatório.")]
    [StringLength(120, MinimumLength = 2, ErrorMessage = "Nome deve ter entre 2 e 120 caracteres.")]
    public string Nome { get; set; }

    [Required(ErrorMessage = "E-mail é obrigatório.")]
    [EmailAddress(ErrorMessage = "E-mail inválido.")]
    [StringLength(180)]
    public string Email { get; set; }

    [StringLength(32)]
    public string Telefone { get; set; }

    [Required(ErrorMessage = "Senha é obrigatória.")]
    [StringLength(64, MinimumLength = 6, ErrorMessage = "Senha deve ter entre 6 e 64 caracteres.")]
    public string Senha { get; set; }
}
