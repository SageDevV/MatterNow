namespace MatterNow.Domain.Entities;

public enum TipoNotificacao
{
    Info = 0,
    Favorito = 1,
    Curtida = 2,
    Avaliacao = 3,
    Mensagem = 4
}

public class Notificacao
{
    public Guid Id { get; private set; }
    public Guid UsuarioId { get; private set; }
    public TipoNotificacao Tipo { get; private set; }
    public string Titulo { get; private set; }
    public string Subtitulo { get; private set; }
    public bool Lida { get; private set; }
    public DateTime CriadoEm { get; private set; }

    private Notificacao() { }

    public Notificacao(Guid usuarioId, TipoNotificacao tipo, string titulo, string subtitulo, DateTime? criadoEm = null)
    {
        Id = Guid.NewGuid();
        UsuarioId = usuarioId;
        Tipo = tipo;
        Titulo = titulo?.Trim();
        Subtitulo = subtitulo?.Trim();
        Lida = false;
        CriadoEm = criadoEm ?? DateTime.UtcNow;
    }

    public void MarcarComoLida()
    {
        Lida = true;
    }
}
