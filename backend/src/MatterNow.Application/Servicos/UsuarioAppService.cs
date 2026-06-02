using MatterNow.Application.Dtos.Usuarios;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;

namespace MatterNow.Application.Servicos;

public class UsuarioAppService : IUsuarioAppService
{
    private readonly IUsuarioRepository _repository;

    public UsuarioAppService(IUsuarioRepository repository)
    {
        _repository = repository;
    }

    public async Task<PerfilResponse> ObterPerfilAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);
        return Mapear(usuario);
    }

    public async Task<PerfilResponse> AtualizarPerfilAsync(Guid usuarioId, AtualizarPerfilRequest request, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);

        usuario.AtualizarPerfil(
            nome: request.Nome,
            localizacao: request.Localizacao,
            avatar: request.Avatar,
            interesses: request.Interesses ?? new List<string>()
        );

        await _repository.SalvarAsync(ct);
        return Mapear(usuario);
    }

    public async Task AtualizarEmailAsync(Guid usuarioId, AtualizarEmailRequest request, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);

        var novoEmail = request.Email.Trim().ToLowerInvariant();
        if (novoEmail == usuario.Email) return; // sem mudança

        var jaExiste = await _repository.EmailExisteAsync(novoEmail, ct);
        if (jaExiste) throw new AuthException("Já existe outra conta com esse e-mail.", 409);

        usuario.AtualizarEmail(novoEmail);
        await _repository.SalvarAsync(ct);
    }

    public async Task AlterarSenhaAsync(Guid usuarioId, AlterarSenhaRequest request, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);

        if (!BCrypt.Net.BCrypt.Verify(request.SenhaAtual, usuario.SenhaHash))
            throw new AuthException("Senha atual incorreta.", 400);

        var novoHash = BCrypt.Net.BCrypt.HashPassword(request.NovaSenha, workFactor: 11);
        usuario.DefinirNovaSenha(novoHash);
        await _repository.SalvarAsync(ct);
    }

    public async Task<PreferenciasNotificacaoResponse> ObterNotificacoesAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);
        return MapearNotificacoes(usuario);
    }

    public async Task<PreferenciasNotificacaoResponse> AtualizarNotificacoesAsync(Guid usuarioId, PreferenciasNotificacaoRequest request, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);

        usuario.DefinirPreferenciasNotificacao(request.Chaves ?? new List<string>());
        await _repository.SalvarAsync(ct);
        return MapearNotificacoes(usuario);
    }

    public async Task CancelarContaAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var usuario = await _repository.ObterPorIdAsync(usuarioId, ct);
        if (usuario == null) throw new AuthException("Usuário não encontrado.", 404);

        usuario.Cancelar();
        await _repository.SalvarAsync(ct);
    }

    private static PerfilResponse Mapear(Usuario u) => new()
    {
        Id = u.Id,
        Nome = u.Nome,
        Email = u.Email,
        Telefone = u.Telefone,
        Localizacao = u.Localizacao,
        Avatar = u.Avatar,
        Interesses = u.Interesses
    };

    private static PreferenciasNotificacaoResponse MapearNotificacoes(Usuario u)
    {
        var prefs = u.PreferenciasNotificacao;
        return new PreferenciasNotificacaoResponse
        {
            Email = prefs.Contains("email"),
            Push = prefs.Contains("push"),
            Mensagens = prefs.Contains("messages"),
        };
    }
}
