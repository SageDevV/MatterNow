namespace MatterNow.Domain.Entities;

public enum TipoAnuncio
{
    Venda = 1,
    Doacao = 2,
    Pergunta = 3,
    Dica = 4
}

public class Anuncio
{
    public Guid Id { get; private set; }
    public Guid UsuarioId { get; private set; }
    public TipoAnuncio Tipo { get; private set; }
    public string Titulo { get; private set; }
    public string Descricao { get; private set; }
    public decimal? Valor { get; private set; }
    public string Localizacao { get; private set; }
    public string FotoUrl { get; private set; }
    public string Tag { get; private set; }
    public int Visualizacoes { get; private set; }
    public int Curtidas { get; private set; }
    public int Comentarios { get; private set; }
    public DateTime CriadoEm { get; private set; }

    private Anuncio() { }

    public Anuncio(
        Guid usuarioId,
        TipoAnuncio tipo,
        string titulo,
        string descricao,
        decimal? valor,
        string localizacao,
        string fotoUrl,
        string tag)
    {
        Id = Guid.NewGuid();
        UsuarioId = usuarioId;
        Tipo = tipo;
        Titulo = titulo?.Trim();
        Descricao = descricao?.Trim();
        Valor = valor;
        Localizacao = localizacao?.Trim();
        FotoUrl = fotoUrl?.Trim();
        Tag = tag?.Trim();
        Visualizacoes = 0;
        Curtidas = 0;
        Comentarios = 0;
        CriadoEm = DateTime.UtcNow;
    }

    public void DefinirMetricas(int visualizacoes, int curtidas, int comentarios)
    {
        Visualizacoes = visualizacoes;
        Curtidas = curtidas;
        Comentarios = comentarios;
    }
}
