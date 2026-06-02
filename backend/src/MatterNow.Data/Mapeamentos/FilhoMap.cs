using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MatterNow.Data.Mapeamentos;

public class FilhoMap : IEntityTypeConfiguration<Filho>
{
    public void Configure(EntityTypeBuilder<Filho> builder)
    {
        builder.ToTable("filhos");
        builder.HasKey(f => f.Id);

        builder.Property(f => f.UsuarioId)
            .HasColumnName("usuario_id")
            .IsRequired();

        builder.HasIndex(f => f.UsuarioId);

        builder.Property(f => f.Nome)
            .HasColumnName("nome")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(f => f.Avatar)
            .HasColumnName("avatar")
            .HasMaxLength(120);

        builder.Property(f => f.DataNascimento)
            .HasColumnName("data_nascimento");

        builder.Property(f => f.FaixaEtaria)
            .HasColumnName("faixa_etaria")
            .HasMaxLength(40);

        builder.Property(f => f.TamanhoRoupa)
            .HasColumnName("tamanho_roupa")
            .HasMaxLength(40);

        builder.Property(f => f.Genero)
            .HasColumnName("genero")
            .HasConversion<int>();

        builder.Property(f => f.PesoKg)
            .HasColumnName("peso_kg")
            .HasColumnType("decimal(6,2)");

        builder.Property(f => f.CriadoEm)
            .HasColumnName("criado_em")
            .IsRequired();

        builder.Property(f => f.AtualizadoEm)
            .HasColumnName("atualizado_em")
            .IsRequired();
    }
}
