using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MatterNow.Data.Mapeamentos;

public class TokenRecuperacaoSenhaMap : IEntityTypeConfiguration<TokenRecuperacaoSenha>
{
    public void Configure(EntityTypeBuilder<TokenRecuperacaoSenha> builder)
    {
        builder.ToTable("tokens_recuperacao_senha");
        builder.HasKey(t => t.Id);

        builder.Property(t => t.UsuarioId).HasColumnName("usuario_id").IsRequired();
        builder.HasIndex(t => t.UsuarioId);

        builder.Property(t => t.CodigoHash).HasColumnName("codigo_hash").HasMaxLength(128).IsRequired();
        builder.Property(t => t.ExpiraEm).HasColumnName("expira_em").IsRequired();
        builder.Property(t => t.UsadoEm).HasColumnName("usado_em");
        builder.Property(t => t.CriadoEm).HasColumnName("criado_em").IsRequired();
    }
}
