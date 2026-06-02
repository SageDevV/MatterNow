using MatterNow.Application.Dtos.Auth;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace MatterNow.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthAppService _authAppService;

    public AuthController(IAuthAppService authAppService)
    {
        _authAppService = authAppService;
    }

    /// <summary>Cria um novo usuário e retorna o token JWT.</summary>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Register([FromBody] RegistrarUsuarioRequest request, CancellationToken ct)
    {
        try
        {
            var response = await _authAppService.RegistrarAsync(request, ct);
            return StatusCode(StatusCodes.Status201Created, response);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro de autenticação");
        }
    }

    /// <summary>Autentica usuário existente e retorna o token JWT.</summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken ct)
    {
        try
        {
            var response = await _authAppService.LoginAsync(request, ct);
            return Ok(response);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro de autenticação");
        }
    }

    /// <summary>Solicita o envio de um código de recuperação de senha por e-mail.</summary>
    /// <remarks>Sempre responde 204 mesmo que o e-mail não exista, para evitar enumeração.</remarks>
    [HttpPost("forgot-password")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> EsqueceuSenha([FromBody] EsqueceuSenhaRequest request, CancellationToken ct)
    {
        await _authAppService.EsqueceuSenhaAsync(request, ct);
        return NoContent();
    }

    /// <summary>Redefine a senha usando o código recebido por e-mail.</summary>
    [HttpPost("reset-password")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RedefinirSenha([FromBody] RedefinirSenhaRequest request, CancellationToken ct)
    {
        try
        {
            await _authAppService.RedefinirSenhaAsync(request, ct);
            return NoContent();
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }
}
