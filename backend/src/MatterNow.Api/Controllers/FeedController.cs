using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using MatterNow.Application.Dtos.Feed;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MatterNow.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class FeedController : ControllerBase
{
    private readonly IFeedAppService _appService;

    public FeedController(IFeedAppService appService)
    {
        _appService = appService;
    }

    /// <summary>Retorna os dados consolidados da home (saudação, feed, recomendações).</summary>
    [HttpGet("home")]
    [ProducesResponseType(typeof(HomeResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> Home(CancellationToken ct)
    {
        try
        {
            var id = ObterUsuarioId();
            var dados = await _appService.ObterHomeAsync(id, ct);
            return Ok(dados);
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
