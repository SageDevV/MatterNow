using MatterNow.Data.Contextos;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Repositorios;

public class FilhoRepository : IFilhoRepository
{
    private readonly MatterNowDbContext _context;

    public FilhoRepository(MatterNowDbContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<Filho>> ListarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default)
        => await _context.Filhos
            .Where(f => f.UsuarioId == usuarioId)
            .OrderBy(f => f.CriadoEm)
            .ToListAsync(ct);

    public Task<Filho> ObterPorIdAsync(Guid id, Guid usuarioId, CancellationToken ct = default)
        => _context.Filhos.FirstOrDefaultAsync(f => f.Id == id && f.UsuarioId == usuarioId, ct);

    public async Task AdicionarAsync(Filho filho, CancellationToken ct = default)
        => await _context.Filhos.AddAsync(filho, ct);

    public Task RemoverAsync(Filho filho, CancellationToken ct = default)
    {
        _context.Filhos.Remove(filho);
        return Task.CompletedTask;
    }

    public Task SalvarAsync(CancellationToken ct = default)
        => _context.SaveChangesAsync(ct);
}
