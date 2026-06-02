using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MatterNow.Data.Mapeamentos;

public class NotificacaoMap : IEntityTypeConfiguration<Notificacao>
{
    public void Configure(EntityTypeBuilder<Notificacao> builder)
    {
        builder.ToTable("notificacoes");
        builder.HasKey(n => n.Id);

        builder.Property(n => n.UsuarioId).HasColumnName("usuario_id").IsRequired();
        builder.HasIndex(n => n.UsuarioId);

        builder.Property(n => n.Tipo).HasColumnName("tipo").HasConversion<int>().IsRequired();
        builder.Property(n => n.Titulo).HasColumnName("titulo").HasMaxLength(200).IsRequired();
        builder.Property(n => n.Subtitulo).HasColumnName("subtitulo").HasMaxLength(500);
        builder.Property(n => n.Lida).HasColumnName("lida").IsRequired();
        builder.Property(n => n.CriadoEm).HasColumnName("criado_em").IsRequired();
    }
}
