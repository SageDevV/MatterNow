using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Usuarios;

public class AlterarSenhaRequest
{
    [Required]
    public string SenhaAtual { get; set; }

    [Required]
    [StringLength(64, MinimumLength = 6, ErrorMessage = "Senha deve ter entre 6 e 64 caracteres.")]
    public string NovaSenha { get; set; }
}
