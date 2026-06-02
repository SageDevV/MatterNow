using MatterNow.Application.Dtos.Notificacoes;
using MatterNow.Application.Interfaces;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;

namespace MatterNow.Application.Servicos;

public class NotificacaoAppService : INotificacaoAppService
{
    private readonly INotificacaoRepository _repository;

    public NotificacaoAppService(INotificacaoRepository repository)
    {
        _repository = repository;
    }

    public async Task<IReadOnlyList<NotificacaoResponse>> ListarAsync(Guid usuarioId, CancellationToken ct = default)
    {
        await GarantirSeedDeBoasVindasAsync(usuarioId, ct);
        var lista = await _repository.ListarPorUsuarioAsync(usuarioId, ct);
        return lista.Select(Mapear).ToList();
    }

    public Task<int> ContarNaoLidasAsync(Guid usuarioId, CancellationToken ct = default)
        => _repository.ContarNaoLidasAsync(usuarioId, ct);

    public async Task MarcarTodasComoLidasAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var lista = await _repository.ListarPorUsuarioAsync(usuarioId, ct);
        foreach (var n in lista.Where(n => !n.Lida)) n.MarcarComoLida();
        await _repository.SalvarAsync(ct);
    }

    /// Cria um conjunto inicial de notificações de demo na primeira vez que o
    /// usuário acessa a tela. Substituível por gatilhos reais (favoritou,
    /// curtiu, etc.) quando esses fluxos existirem.
    private async Task GarantirSeedDeBoasVindasAsync(Guid usuarioId, CancellationToken ct)
    {
        var total = await _repository.ContarPorUsuarioAsync(usuarioId, ct);
        if (total > 0) return;

        var agora = DateTime.UtcNow;
        var iniciais = new[]
        {
            new Notificacao(usuarioId, TipoNotificacao.Info,
                "Bem-vindo ao Maternow!",
                "Esta é uma notificação de teste do sistema. Explore a comunidade, faça vendas e conecte-se com outras mães!",
                agora.AddDays(-5)),
            new Notificacao(usuarioId, TipoNotificacao.Avaliacao,
                "Uma nova avaliação...",
                "Maurício Pena curtiu: Carrinho de bebê",
                agora.AddDays(-5)),
            new Notificacao(usuarioId, TipoNotificacao.Favorito,
                "Seu item foi favoritado",
                "Carrinho de bebê",
                agora.AddHours(-5)),
            new Notificacao(usuarioId, TipoNotificacao.Curtida,
                "Seu item recebeu...",
                "Maurício Pena curtiu: Carrinho de bebê",
                agora.AddMinutes(-2)),
            new Notificacao(usuarioId, TipoNotificacao.Favorito,
                "Seu item foi favoritado",
                "Pediatra especialista em alergia",
                agora)
        };

        await _repository.AdicionarRangeAsync(iniciais, ct);
        await _repository.SalvarAsync(ct);
    }

    private static NotificacaoResponse Mapear(Notificacao n) => new()
    {
        Id = n.Id,
        Tipo = (int)n.Tipo,
        Titulo = n.Titulo,
        Subtitulo = n.Subtitulo,
        Lida = n.Lida,
        CriadoEm = n.CriadoEm
    };
}
