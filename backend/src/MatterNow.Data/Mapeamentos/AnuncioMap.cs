using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MatterNow.Data.Mapeamentos;

public class AnuncioMap : IEntityTypeConfiguration<Anuncio>
{
    public void Configure(EntityTypeBuilder<Anuncio> builder)
    {
        builder.ToTable("anuncios");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.UsuarioId).HasColumnName("usuario_id").IsRequired();
        builder.HasIndex(a => a.UsuarioId);

        builder.Property(a => a.Tipo).HasColumnName("tipo").HasConversion<int>().IsRequired();
        builder.Property(a => a.Titulo).HasColumnName("titulo").HasMaxLength(200).IsRequired();
        builder.Property(a => a.Descricao).HasColumnName("descricao").HasMaxLength(2000);
        builder.Property(a => a.Valor).HasColumnName("valor").HasColumnType("decimal(10,2)");
        builder.Property(a => a.Localizacao).HasColumnName("localizacao").HasMaxLength(180);
        builder.Property(a => a.FotoUrl).HasColumnName("foto_url").HasMaxLength(500);
        builder.Property(a => a.Tag).HasColumnName("tag").HasMaxLength(40);
        builder.Property(a => a.Visualizacoes).HasColumnName("visualizacoes");
        builder.Property(a => a.Curtidas).HasColumnName("curtidas");
        builder.Property(a => a.Comentarios).HasColumnName("comentarios");
        builder.Property(a => a.CriadoEm).HasColumnName("criado_em").IsRequired();
    }
}
