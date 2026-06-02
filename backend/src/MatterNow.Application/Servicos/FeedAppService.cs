using MatterNow.Application.Dtos.Feed;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;

namespace MatterNow.Application.Servicos;

public class FeedAppService : IFeedAppService
{
    private readonly IUsuarioRepository _usuarioRepository;
    private readonly IAnuncioRepository _anuncioRepository;
    private readonly IFilhoRepository _filhoRepository;

    public FeedAppService(
        IUsuarioRepository usuarioRepository,
        IAnuncioRepository anuncioRepository,
        IFilhoRepository filhoRepository)
    {
        _usuarioRepository = usuarioRepository;
        _anuncioRepository = anuncioRepository;
        _filhoRepository = filhoRepository;
    }

    public async Task<HomeResponse> ObterHomeAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var usuario = await _usuarioRepository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);

        var meusAnuncios = await _anuncioRepository.ContarPorUsuarioAsync(usuarioId, ct);
        var feed = await _anuncioRepository.ListarFeedAsync(20, ct);
        var primeiroAcesso = meusAnuncios == 0;

        var filhos = await _filhoRepository.ListarPorUsuarioAsync(usuarioId, ct);
        var filhoFoco = filhos.FirstOrDefault();

        var recomendacoes = primeiroAcesso || filhoFoco == null
            ? Array.Empty<Anuncio>().ToList()
            : (await _anuncioRepository.ListarRecomendacoesAsync(6, TipoAnuncio.Venda, ct)).ToList();

        return new HomeResponse
        {
            PrimeiroAcesso = primeiroAcesso,
            SaudacaoNome = PrimeiroNome(usuario.Nome),
            Comunidade = feed.Select(t => Mapear(t.Anuncio, t.Autor)).ToList(),
            Recomendacoes = recomendacoes.Select(a => Mapear(a, null)).ToList(),
            NomeFilhoFoco = filhoFoco?.Nome
        };
    }

    private static string PrimeiroNome(string nomeCompleto)
    {
        if (string.IsNullOrWhiteSpace(nomeCompleto)) return string.Empty;
        var espaco = nomeCompleto.IndexOf(' ');
        return espaco < 0 ? nomeCompleto : nomeCompleto[..espaco];
    }

    private static AnuncioResponse Mapear(Anuncio a, Usuario autor) => new()
    {
        Id = a.Id,
        Tipo = (int)a.Tipo,
        TipoNome = a.Tipo.ToString().ToUpperInvariant(),
        Titulo = a.Titulo,
        Descricao = a.Descricao,
        Valor = a.Valor,
        Localizacao = a.Localizacao,
        FotoUrl = a.FotoUrl,
        Tag = a.Tag,
        Visualizacoes = a.Visualizacoes,
        Curtidas = a.Curtidas,
        Comentarios = a.Comentarios,
        AutorNome = autor?.Nome,
        AutorAvatar = autor?.Avatar,
        CriadoEm = a.CriadoEm
    };
}
