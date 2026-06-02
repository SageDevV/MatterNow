using MatterNow.Application.Dtos.Filhos;

namespace MatterNow.Application.Interfaces;

public interface IFilhoAppService
{
    Task<IReadOnlyList<FilhoResponse>> ListarAsync(Guid usuarioId, CancellationToken ct = default);
    Task<FilhoResponse> CriarAsync(Guid usuarioId, FilhoRequest request, CancellationToken ct = default);
    Task<FilhoResponse> AtualizarAsync(Guid usuarioId, Guid filhoId, FilhoRequest request, CancellationToken ct = default);
    Task RemoverAsync(Guid usuarioId, Guid filhoId, CancellationToken ct = default);
}
