using MatterNow.Application.Dtos.Usuarios;

namespace MatterNow.Application.Interfaces;

public interface IUsuarioAppService
{
    Task<PerfilResponse> ObterPerfilAsync(Guid usuarioId, CancellationToken ct = default);
    Task<PerfilResponse> AtualizarPerfilAsync(Guid usuarioId, AtualizarPerfilRequest request, CancellationToken ct = default);
    Task AtualizarEmailAsync(Guid usuarioId, AtualizarEmailRequest request, CancellationToken ct = default);
    Task AlterarSenhaAsync(Guid usuarioId, AlterarSenhaRequest request, CancellationToken ct = default);
    Task<PreferenciasNotificacaoResponse> ObterNotificacoesAsync(Guid usuarioId, CancellationToken ct = default);
    Task<PreferenciasNotificacaoResponse> AtualizarNotificacoesAsync(Guid usuarioId, PreferenciasNotificacaoRequest request, CancellationToken ct = default);
    Task CancelarContaAsync(Guid usuarioId, CancellationToken ct = default);
}
