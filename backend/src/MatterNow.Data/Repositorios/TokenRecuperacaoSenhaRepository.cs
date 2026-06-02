using MatterNow.Data.Contextos;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Repositorios;

public class TokenRecuperacaoSenhaRepository : ITokenRecuperacaoSenhaRepository
{
    private readonly MatterNowDbContext _context;

    public TokenRecuperacaoSenhaRepository(MatterNowDbContext context)
    {
        _context = context;
    }

    public Task<TokenRecuperacaoSenha> ObterUltimoValidoAsync(Guid usuarioId, CancellationToken ct = default)
        => _context.TokensRecuperacaoSenha
            .Where(t => t.UsuarioId == usuarioId && t.UsadoEm == null && t.ExpiraEm > DateTime.UtcNow)
            .OrderByDescending(t => t.CriadoEm)
            .FirstOrDefaultAsync(ct);

    public async Task InvalidarPendentesAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var pendentes = await _context.TokensRecuperacaoSenha
            .Where(t => t.UsuarioId == usuarioId && t.UsadoEm == null)
            .ToListAsync(ct);
        foreach (var t in pendentes) t.MarcarComoUsado();
    }

    public async Task AdicionarAsync(TokenRecuperacaoSenha token, CancellationToken ct = default)
        => await _context.TokensRecuperacaoSenha.AddAsync(token, ct);

    public Task SalvarAsync(CancellationToken ct = default)
        => _context.SaveChangesAsync(ct);
}
