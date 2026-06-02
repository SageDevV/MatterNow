using MatterNow.Data.Contextos;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Repositorios;

public class AnuncioRepository : IAnuncioRepository
{
    private readonly MatterNowDbContext _context;

    public AnuncioRepository(MatterNowDbContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<(Anuncio Anuncio, Usuario Autor)>> ListarFeedAsync(int limite, CancellationToken ct = default)
    {
        var query = await (
            from a in _context.Anuncios
            join u in _context.Usuarios on a.UsuarioId equals u.Id into autores
            from autor in autores.DefaultIfEmpty()
            orderby a.CriadoEm descending
            select new { Anuncio = a, Autor = autor }
        ).Take(limite).ToListAsync(ct);

        return query.Select(x => (x.Anuncio, x.Autor)).ToList();
    }

    public async Task<IReadOnlyList<Anuncio>> ListarRecomendacoesAsync(int limite, TipoAnuncio? tipo = null, CancellationToken ct = default)
    {
        var query = _context.Anuncios.AsQueryable();
        if (tipo.HasValue) query = query.Where(a => a.Tipo == tipo.Value);
        return await query.OrderByDescending(a => a.CriadoEm).Take(limite).ToListAsync(ct);
    }

    public Task<int> ContarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default)
        => _context.Anuncios.CountAsync(a => a.UsuarioId == usuarioId, ct);

    public async Task AdicionarAsync(Anuncio anuncio, CancellationToken ct = default)
        => await _context.Anuncios.AddAsync(anuncio, ct);

    public Task SalvarAsync(CancellationToken ct = default)
        => _context.SaveChangesAsync(ct);
}
