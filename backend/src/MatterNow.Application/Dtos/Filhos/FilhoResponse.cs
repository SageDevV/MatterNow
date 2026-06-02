namespace MatterNow.Application.Dtos.Filhos;

public class FilhoResponse
{
    public Guid Id { get; set; }
    public string Nome { get; set; }
    public string Avatar { get; set; }
    public DateOnly? DataNascimento { get; set; }
    public string FaixaEtaria { get; set; }
    public string TamanhoRoupa { get; set; }
    public int Genero { get; set; }
    public decimal? PesoKg { get; set; }
}
