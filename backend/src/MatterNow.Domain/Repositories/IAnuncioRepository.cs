using MatterNow.Domain.Entities;

namespace MatterNow.Domain.Repositories;

public interface IAnuncioRepository
{
    /// Lista todos os anúncios da comunidade (mais recentes primeiro), com autor.
    Task<IReadOnlyList<(Anuncio Anuncio, Usuario Autor)>> ListarFeedAsync(int limite, CancellationToken ct = default);

    Task<IReadOnlyList<Anuncio>> ListarRecomendacoesAsync(int limite, TipoAnuncio? tipo = null, CancellationToken ct = default);

    Task<int> ContarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default);

    Task AdicionarAsync(Anuncio anuncio, CancellationToken ct = default);
    Task SalvarAsync(CancellationToken ct = default);
}
