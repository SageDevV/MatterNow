namespace MatterNow.Application.Dtos.Feed;

public class HomeResponse
{
    /// Quando true, o app deve exibir a tela de "primeiro acesso".
    public bool PrimeiroAcesso { get; set; }
    public string SaudacaoNome { get; set; }
    public IReadOnlyList<AnuncioResponse> Comunidade { get; set; } = Array.Empty<AnuncioResponse>();
    public IReadOnlyList<AnuncioResponse> Recomendacoes { get; set; } = Array.Empty<AnuncioResponse>();
    public string NomeFilhoFoco { get; set; }
}
