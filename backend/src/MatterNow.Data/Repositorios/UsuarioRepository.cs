using MatterNow.Data.Contextos;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Repositorios;

public class UsuarioRepository : IUsuarioRepository
{
    private readonly MatterNowDbContext _context;

    public UsuarioRepository(MatterNowDbContext context)
    {
        _context = context;
    }

    public Task<Usuario> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => _context.Usuarios.FirstOrDefaultAsync(u => u.Id == id, ct);

    public Task<Usuario> ObterPorEmailAsync(string email, CancellationToken ct = default)
        => _context.Usuarios.FirstOrDefaultAsync(u => u.Email == email, ct);

    public Task<bool> EmailExisteAsync(string email, CancellationToken ct = default)
        => _context.Usuarios.AnyAsync(u => u.Email == email, ct);

    public async Task AdicionarAsync(Usuario usuario, CancellationToken ct = default)
        => await _context.Usuarios.AddAsync(usuario, ct);

    public Task SalvarAsync(CancellationToken ct = default)
        => _context.SaveChangesAsync(ct);
}
