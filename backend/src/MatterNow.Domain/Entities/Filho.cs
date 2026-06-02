namespace MatterNow.Domain.Entities;

public enum GeneroFilho
{
    NaoInformar = 0,
    Menina = 1,
    Menino = 2
}

public class Filho
{
    public Guid Id { get; private set; }
    public Guid UsuarioId { get; private set; }
    public string Nome { get; private set; }
    public string Avatar { get; private set; }
    public DateOnly? DataNascimento { get; private set; }
    public string FaixaEtaria { get; private set; }
    public string TamanhoRoupa { get; private set; }
    public GeneroFilho Genero { get; private set; }
    public decimal? PesoKg { get; private set; }
    public DateTime CriadoEm { get; private set; }
    public DateTime AtualizadoEm { get; private set; }

    private Filho() { }

    public Filho(Guid usuarioId, string nome)
    {
        Id = Guid.NewGuid();
        UsuarioId = usuarioId;
        Nome = nome?.Trim();
        Genero = GeneroFilho.NaoInformar;
        CriadoEm = DateTime.UtcNow;
        AtualizadoEm = CriadoEm;
    }

    public void Atualizar(
        string nome,
        string avatar,
        DateOnly? dataNascimento,
        string faixaEtaria,
        string tamanhoRoupa,
        GeneroFilho genero,
        decimal? pesoKg)
    {
        if (!string.IsNullOrWhiteSpace(nome)) Nome = nome.Trim();
        Avatar = string.IsNullOrWhiteSpace(avatar) ? null : avatar.Trim();
        DataNascimento = dataNascimento;
        FaixaEtaria = string.IsNullOrWhiteSpace(faixaEtaria) ? null : faixaEtaria.Trim();
        TamanhoRoupa = string.IsNullOrWhiteSpace(tamanhoRoupa) ? null : tamanhoRoupa.Trim();
        Genero = genero;
        PesoKg = pesoKg.HasValue && pesoKg.Value > 0 ? pesoKg : null;
        AtualizadoEm = DateTime.UtcNow;
    }
}
