namespace MatterNow.Domain.Entities;

public class TokenRecuperacaoSenha
{
    public Guid Id { get; private set; }
    public Guid UsuarioId { get; private set; }
    public string CodigoHash { get; private set; }
    public DateTime ExpiraEm { get; private set; }
    public DateTime? UsadoEm { get; private set; }
    public DateTime CriadoEm { get; private set; }

    private TokenRecuperacaoSenha() { }

    public TokenRecuperacaoSenha(Guid usuarioId, string codigoHash, DateTime expiraEm)
    {
        Id = Guid.NewGuid();
        UsuarioId = usuarioId;
        CodigoHash = codigoHash;
        ExpiraEm = expiraEm;
        CriadoEm = DateTime.UtcNow;
    }

    public bool EstaValido(DateTime agoraUtc)
        => UsadoEm == null && agoraUtc < ExpiraEm;

    public void MarcarComoUsado()
        => UsadoEm = DateTime.UtcNow;
}
