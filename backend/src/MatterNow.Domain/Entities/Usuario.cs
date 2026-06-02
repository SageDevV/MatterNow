namespace MatterNow.Domain.Entities;

public class Usuario
{
    public Guid Id { get; private set; }
    public string Nome { get; private set; }
    public string Email { get; private set; }
    public string Telefone { get; private set; }
    public string Localizacao { get; private set; }
    public string Avatar { get; private set; }
    public string InteressesCsv { get; private set; }
    public string SenhaHash { get; private set; }
    public DateTime CriadoEm { get; private set; }
    public DateTime AtualizadoEm { get; private set; }

    private Usuario() { }

    public Usuario(string nome, string email, string telefone, string senhaHash)
    {
        Id = Guid.NewGuid();
        Nome = nome?.Trim();
        Email = email?.Trim().ToLowerInvariant();
        Telefone = string.IsNullOrWhiteSpace(telefone) ? null : telefone.Trim();
        SenhaHash = senhaHash;
        CriadoEm = DateTime.UtcNow;
        AtualizadoEm = CriadoEm;
        InteressesCsv = string.Empty;
    }

    public IReadOnlyList<string> Interesses =>
        string.IsNullOrWhiteSpace(InteressesCsv)
            ? Array.Empty<string>()
            : InteressesCsv.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    public void AtualizarPerfil(string nome, string localizacao, string avatar, IEnumerable<string> interesses)
    {
        if (!string.IsNullOrWhiteSpace(nome)) Nome = nome.Trim();
        Localizacao = string.IsNullOrWhiteSpace(localizacao) ? null : localizacao.Trim();
        Avatar = string.IsNullOrWhiteSpace(avatar) ? null : avatar.Trim();
        InteressesCsv = interesses == null
            ? string.Empty
            : string.Join(',', interesses.Where(i => !string.IsNullOrWhiteSpace(i)).Select(i => i.Trim()));
        AtualizadoEm = DateTime.UtcNow;
    }

    public void DefinirNovaSenha(string novoHash)
    {
        if (string.IsNullOrWhiteSpace(novoHash))
            throw new ArgumentException("Hash inválido.", nameof(novoHash));
        SenhaHash = novoHash;
        AtualizadoEm = DateTime.UtcNow;
    }

    public string PreferenciasNotificacaoCsv { get; private set; } = "push,messages";
    public bool Cancelado { get; private set; }
    public DateTime? CanceladoEm { get; private set; }

    public IReadOnlyList<string> PreferenciasNotificacao =>
        string.IsNullOrWhiteSpace(PreferenciasNotificacaoCsv)
            ? Array.Empty<string>()
            : PreferenciasNotificacaoCsv.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    public void DefinirPreferenciasNotificacao(IEnumerable<string> chaves)
    {
        PreferenciasNotificacaoCsv = chaves == null
            ? string.Empty
            : string.Join(',', chaves.Where(c => !string.IsNullOrWhiteSpace(c)).Select(c => c.Trim().ToLowerInvariant()).Distinct());
        AtualizadoEm = DateTime.UtcNow;
    }

    public void AtualizarEmail(string novoEmail)
    {
        if (string.IsNullOrWhiteSpace(novoEmail))
            throw new ArgumentException("E-mail inválido.", nameof(novoEmail));
        Email = novoEmail.Trim().ToLowerInvariant();
        AtualizadoEm = DateTime.UtcNow;
    }

    public void Cancelar()
    {
        Cancelado = true;
        CanceladoEm = DateTime.UtcNow;
        AtualizadoEm = CanceladoEm.Value;
    }
}
