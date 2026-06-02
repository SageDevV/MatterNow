using MatterNow.Domain.Entities;

namespace MatterNow.Domain.Repositories;

public interface ITokenRecuperacaoSenhaRepository
{
    Task<TokenRecuperacaoSenha> ObterUltimoValidoAsync(Guid usuarioId, CancellationToken ct = default);
    Task InvalidarPendentesAsync(Guid usuarioId, CancellationToken ct = default);
    Task AdicionarAsync(TokenRecuperacaoSenha token, CancellationToken ct = default);
    Task SalvarAsync(CancellationToken ct = default);
}
