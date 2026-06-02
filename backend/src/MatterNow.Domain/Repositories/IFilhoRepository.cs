using MatterNow.Domain.Entities;

namespace MatterNow.Domain.Repositories;

public interface IFilhoRepository
{
    Task<IReadOnlyList<Filho>> ListarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default);
    Task<Filho> ObterPorIdAsync(Guid id, Guid usuarioId, CancellationToken ct = default);
    Task AdicionarAsync(Filho filho, CancellationToken ct = default);
    Task RemoverAsync(Filho filho, CancellationToken ct = default);
    Task SalvarAsync(CancellationToken ct = default);
}
