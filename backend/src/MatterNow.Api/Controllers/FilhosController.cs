using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using MatterNow.Application.Dtos.Filhos;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MatterNow.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class FilhosController : ControllerBase
{
    private readonly IFilhoAppService _appService;

    public FilhosController(IFilhoAppService appService)
    {
        _appService = appService;
    }

    /// <summary>Lista os filhos do usuário autenticado.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<FilhoResponse>), StatusCodes.Status200OK)]
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

    /// <summary>Cria um novo filho vinculado ao usuário autenticado.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(FilhoResponse), StatusCodes.Status201Created)]
    public async Task<IActionResult> Criar([FromBody] FilhoRequest request, CancellationToken ct)
    {
        try
        {
            var usuarioId = ObterUsuarioId();
            var filho = await _appService.CriarAsync(usuarioId, request, ct);
            return CreatedAtAction(nameof(Listar), filho);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    /// <summary>Atualiza dados do filho.</summary>
    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(FilhoResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] FilhoRequest request, CancellationToken ct)
    {
        try
        {
            var usuarioId = ObterUsuarioId();
            var filho = await _appService.AtualizarAsync(usuarioId, id, request, ct);
            return Ok(filho);
        }
        catch (AuthException ex)
        {
            return Problem(detail: ex.Message, statusCode: ex.StatusCode, title: "Erro");
        }
    }

    /// <summary>Remove um filho.</summary>
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Remover(Guid id, CancellationToken ct)
    {
        try
        {
            var usuarioId = ObterUsuarioId();
            await _appService.RemoverAsync(usuarioId, id, ct);
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
