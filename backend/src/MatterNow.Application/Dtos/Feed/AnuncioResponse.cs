namespace MatterNow.Application.Dtos.Feed;

public class AnuncioResponse
{
    public Guid Id { get; set; }
    public int Tipo { get; set; }
    public string TipoNome { get; set; }
    public string Titulo { get; set; }
    public string Descricao { get; set; }
    public decimal? Valor { get; set; }
    public string Localizacao { get; set; }
    public string FotoUrl { get; set; }
    public string Tag { get; set; }
    public int Visualizacoes { get; set; }
    public int Curtidas { get; set; }
    public int Comentarios { get; set; }
    public string AutorNome { get; set; }
    public string AutorAvatar { get; set; }
    public DateTime CriadoEm { get; set; }
}
