using System.Security.Cryptography;
using System.Text;
using MatterNow.Application.Dtos.Auth;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;

namespace MatterNow.Application.Servicos;

public class AuthAppService : IAuthAppService
{
    private readonly IUsuarioRepository _usuarioRepository;
    private readonly ITokenService _tokenService;
    private readonly ITokenRecuperacaoSenhaRepository _recuperacaoRepository;
    private readonly IEmailService _emailService;

    public AuthAppService(
        IUsuarioRepository usuarioRepository,
        ITokenService tokenService,
        ITokenRecuperacaoSenhaRepository recuperacaoRepository,
        IEmailService emailService)
    {
        _usuarioRepository = usuarioRepository;
        _tokenService = tokenService;
        _recuperacaoRepository = recuperacaoRepository;
        _emailService = emailService;
    }

    public async Task<AuthResponse> RegistrarAsync(RegistrarUsuarioRequest request, CancellationToken ct = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        if (await _usuarioRepository.EmailExisteAsync(email, ct))
            throw new AuthException("E-mail já cadastrado.", 409);

        var senhaHash = BCrypt.Net.BCrypt.HashPassword(request.Senha, workFactor: 11);
        var usuario = new Usuario(request.Nome, email, request.Telefone, senhaHash);

        await _usuarioRepository.AdicionarAsync(usuario, ct);
        await _usuarioRepository.SalvarAsync(ct);

        return MontarResposta(usuario);
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken ct = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var usuario = await _usuarioRepository.ObterPorEmailAsync(email, ct);

        if (usuario == null || !BCrypt.Net.BCrypt.Verify(request.Senha, usuario.SenhaHash))
            throw new AuthException("E-mail ou senha incorretos.", 401);

        return MontarResposta(usuario);
    }

    /// Gera um código numérico de 6 dígitos, persiste o hash, e envia por e-mail.
    /// Sempre retorna sem erro mesmo que o e-mail não exista, para não revelar.
    public async Task EsqueceuSenhaAsync(EsqueceuSenhaRequest request, CancellationToken ct = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var usuario = await _usuarioRepository.ObterPorEmailAsync(email, ct);
        if (usuario == null) return; // resposta neutra

        await _recuperacaoRepository.InvalidarPendentesAsync(usuario.Id, ct);

        var codigo = GerarCodigo();
        var hash = HashCodigo(codigo);
        var token = new TokenRecuperacaoSenha(usuario.Id, hash, DateTime.UtcNow.AddMinutes(30));
        await _recuperacaoRepository.AdicionarAsync(token, ct);
        await _recuperacaoRepository.SalvarAsync(ct);

        await _emailService.EnviarCodigoRecuperacaoAsync(usuario.Email, usuario.Nome, codigo, ct);
    }

    public async Task RedefinirSenhaAsync(RedefinirSenhaRequest request, CancellationToken ct = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();
        var usuario = await _usuarioRepository.ObterPorEmailAsync(email, ct);
        if (usuario == null) throw new AuthException("Código inválido.", 400);

        var token = await _recuperacaoRepository.ObterUltimoValidoAsync(usuario.Id, ct);
        if (token == null || !token.EstaValido(DateTime.UtcNow))
            throw new AuthException("Código inválido ou expirado.", 400);

        var hashInformado = HashCodigo(request.Codigo.Trim());
        if (!CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(token.CodigoHash),
                Encoding.UTF8.GetBytes(hashInformado)))
        {
            throw new AuthException("Código inválido.", 400);
        }

        var novoHash = BCrypt.Net.BCrypt.HashPassword(request.NovaSenha, workFactor: 11);
        usuario.DefinirNovaSenha(novoHash);
        token.MarcarComoUsado();

        await _usuarioRepository.SalvarAsync(ct);
    }

    private AuthResponse MontarResposta(Usuario usuario)
    {
        var (token, expiraEm) = _tokenService.GerarToken(usuario);
        return new AuthResponse
        {
            UsuarioId = usuario.Id,
            Nome = usuario.Nome,
            Email = usuario.Email,
            Token = token,
            ExpiraEm = expiraEm
        };
    }

    private static string GerarCodigo()
    {
        var bytes = RandomNumberGenerator.GetBytes(4);
        var num = BitConverter.ToUInt32(bytes, 0) % 1_000_000;
        return num.ToString("D6");
    }

    private static string HashCodigo(string codigo)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(codigo));
        return Convert.ToHexString(bytes);
    }
}
