using MatterNow.Application.Dtos.Notificacoes;

namespace MatterNow.Application.Interfaces;

public interface INotificacaoAppService
{
    Task<IReadOnlyList<NotificacaoResponse>> ListarAsync(Guid usuarioId, CancellationToken ct = default);
    Task<int> ContarNaoLidasAsync(Guid usuarioId, CancellationToken ct = default);
    Task MarcarTodasComoLidasAsync(Guid usuarioId, CancellationToken ct = default);
}
