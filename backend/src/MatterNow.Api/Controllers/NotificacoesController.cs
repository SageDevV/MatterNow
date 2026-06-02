using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using MatterNow.Application.Dtos.Notificacoes;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MatterNow.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class NotificacoesController : ControllerBase
{
    private readonly INotificacaoAppService _appService;

    public NotificacoesController(INotificacaoAppService appService)
    {
        _appService = appService;
    }

    /// <summary>Lista as notificações do usuário autenticado (mais recentes primeiro).</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<NotificacaoResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            var lista = await _appService.ListarAsync(id, ct);
            return Ok(lista);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    /// <summary>Marca todas as notificações pendentes como lidas.</summary>
    [HttpPost("marcar-lidas")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> MarcarLidas(CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            await _appService.MarcarTodasComoLidasAsync(id, ct);
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
