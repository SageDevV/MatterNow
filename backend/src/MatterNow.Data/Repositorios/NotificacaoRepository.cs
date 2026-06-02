using MatterNow.Data.Contextos;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Repositorios;

public class NotificacaoRepository : INotificacaoRepository
{
    private readonly MatterNowDbContext _context;

    public NotificacaoRepository(MatterNowDbContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<Notificacao>> ListarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default)
        => await _context.Notificacoes
            .Where(n => n.UsuarioId == usuarioId)
            .OrderByDescending(n => n.CriadoEm)
            .ToListAsync(ct);

    public Task<int> ContarPorUsuarioAsync(Guid usuarioId, CancellationToken ct = default)
        => _context.Notificacoes.CountAsync(n => n.UsuarioId == usuarioId, ct);

    public Task<int> ContarNaoLidasAsync(Guid usuarioId, CancellationToken ct = default)
        => _context.Notificacoes.CountAsync(n => n.UsuarioId == usuarioId && !n.Lida, ct);

    public async Task AdicionarAsync(Notificacao notificacao, CancellationToken ct = default)
        => await _context.Notificacoes.AddAsync(notificacao, ct);

    public async Task AdicionarRangeAsync(IEnumerable<Notificacao> notificacoes, CancellationToken ct = default)
        => await _context.Notificacoes.AddRangeAsync(notificacoes, ct);

    public Task SalvarAsync(CancellationToken ct = default)
        => _context.SaveChangesAsync(ct);
}
