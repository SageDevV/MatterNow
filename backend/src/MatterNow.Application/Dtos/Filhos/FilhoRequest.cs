using System.ComponentModel.DataAnnotations;

namespace MatterNow.Application.Dtos.Filhos;

public class FilhoRequest
{
    [Required(ErrorMessage = "Nome é obrigatório.")]
    [StringLength(120, MinimumLength = 1)]
    public string Nome { get; set; }

    [StringLength(120)]
    public string Avatar { get; set; }

    /// Data no formato yyyy-MM-dd.
    public DateOnly? DataNascimento { get; set; }

    [StringLength(40)]
    public string FaixaEtaria { get; set; }

    [StringLength(40)]
    public string TamanhoRoupa { get; set; }

    /// 0 = não informar, 1 = menina, 2 = menino.
    public int Genero { get; set; }

    [Range(0, 200)]
    public decimal? PesoKg { get; set; }
}
