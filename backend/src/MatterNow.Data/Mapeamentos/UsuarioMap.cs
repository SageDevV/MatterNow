using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MatterNow.Data.Mapeamentos;

public class UsuarioMap : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.ToTable("usuarios");
        builder.HasKey(u => u.Id);

        builder.Property(u => u.Nome)
            .HasColumnName("nome")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(u => u.Email)
            .HasColumnName("email")
            .HasMaxLength(180)
            .IsRequired();

        builder.HasIndex(u => u.Email).IsUnique();

        builder.Property(u => u.Telefone)
            .HasColumnName("telefone")
            .HasMaxLength(32);

        builder.Property(u => u.Localizacao)
            .HasColumnName("localizacao")
            .HasMaxLength(180);

        builder.Property(u => u.Avatar)
            .HasColumnName("avatar")
            .HasMaxLength(120);

        builder.Property(u => u.InteressesCsv)
            .HasColumnName("interesses")
            .HasMaxLength(500);

        builder.Property(u => u.SenhaHash)
            .HasColumnName("senha_hash")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(u => u.CriadoEm)
            .HasColumnName("criado_em")
            .IsRequired();

        builder.Property(u => u.AtualizadoEm)
            .HasColumnName("atualizado_em")
            .IsRequired();

        builder.Property(u => u.PreferenciasNotificacaoCsv)
            .HasColumnName("preferencias_notificacao")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(u => u.Cancelado)
            .HasColumnName("cancelado")
            .HasDefaultValue(false);

        builder.Property(u => u.CanceladoEm)
            .HasColumnName("cancelado_em");
    }
}
