using MatterNow.Domain.Entities;

namespace MatterNow.Domain.Repositories;

public interface INotificacaoRepository
{
    Task<IReadOnlyList<Notificacao>> ListarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default);
    Task<int> ContarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default);
    Task<int> ContarNaoLidasAsync(Guid usuarioId, CancellationToken ct = default);
    Task AdicionarAsync(Notificacao notificacao, CancellationToken ct = default);
    Task AdicionarRangeAsync(IEnumerable<Notificacao> notificacoes, CancellationToken ct = default);
    Task SalvarAsync(CancellationToken ct = default);
}
