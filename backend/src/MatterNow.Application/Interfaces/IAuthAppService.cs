using MatterNow.Application.Dtos.Auth;

namespace MatterNow.Application.Interfaces;

public interface IAuthAppService
{
    Task<AuthResponse> RegistrarAsync(RegistrarUsuarioRequest request, CancellationToken ct = default);
    Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken ct = default);
    Task EsqueceuSenhaAsync(EsqueceuSenhaRequest request, CancellationToken ct = default);
    Task RedefinirSenhaAsync(RedefinirSenhaRequest request, CancellationToken ct = default);
}
