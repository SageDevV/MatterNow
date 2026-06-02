using MatterNow.Application.Dtos.Feed;

namespace MatterNow.Application.Interfaces;

public interface IFeedAppService
{
    Task<HomeResponse> ObterHomeAsync(Guid usuarioId, CancellationToken ct = default);
}
