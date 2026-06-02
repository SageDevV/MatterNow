using MatterNow.Data.Mapeamentos;
using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Contextos;

public class MatterNowDbContext : DbContext
{
    public MatterNowDbContext(DbContextOptions<MatterNowDbContext> options) : base(options) { }

    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Filho> Filhos { get; set; }
    public DbSet<Anuncio> Anuncios { get; set; }
    public DbSet<TokenRecuperacaoSenha> TokensRecuperacaoSenha { get; set; }
    public DbSet<Notificacao> Notificacoes { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfiguration(new UsuarioMap());
        modelBuilder.ApplyConfiguration(new FilhoMap());
        modelBuilder.ApplyConfiguration(new AnuncioMap());
        modelBuilder.ApplyConfiguration(new TokenRecuperacaoSenhaMap());
        modelBuilder.ApplyConfiguration(new NotificacaoMap());
    }
}
