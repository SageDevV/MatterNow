using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using MatterNow.Application.Dtos.Usuarios;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MatterNow.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly IUsuarioAppService _appService;

    public UsuariosController(IUsuarioAppService appService)
    {
        _appService = appService;
    }

    [HttpGet("me")]
    [ProducesResponseType(typeof(PerfilResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterPerfil(CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            var perfil = await _appService.ObterPerfilAsync(id, ct);
            return Ok(perfil);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    [HttpPut("me")]
    [ProducesResponseType(typeof(PerfilResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> AtualizarPerfil([FromBody] AtualizarPerfilRequest request, CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            var perfil = await _appService.AtualizarPerfilAsync(id, request, ct);
            return Ok(perfil);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    [HttpPut("me/email")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AtualizarEmail([FromBody] AtualizarEmailRequest request, CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            await _appService.AtualizarEmailAsync(id, request, ct);
            return NoContent();
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    [HttpPut("me/password")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AlterarSenha([FromBody] AlterarSenhaRequest request, CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            await _appService.AlterarSenhaAsync(id, request, ct);
            return NoContent();
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    [HttpGet("me/notifications")]
    [ProducesResponseType(typeof(PreferenciasNotificacaoResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterNotificacoes(CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            var prefs = await _appService.ObterNotificacoesAsync(id, ct);
            return Ok(prefs);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    [HttpPut("me/notifications")]
    [ProducesResponseType(typeof(PreferenciasNotificacaoResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> AtualizarNotificacoes([FromBody] PreferenciasNotificacaoRequest request, CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            var prefs = await _appService.AtualizarNotificacoesAsync(id, request, ct);
            return Ok(prefs);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    [HttpDelete("me")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> CancelarConta(CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            await _appService.CancelarContaAsync(id, ct);
            return NoContent();
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    private Guid ObterUsuarioId()
    {
        var sub = User.FindFirstValue(JwtRegisteredClaimNames.Sub)
                  ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (sub == null || !Guid.TryParse(sub, out var id))
            throw new AuthException("Token inválido.", 401);
        return id;
    }
}
