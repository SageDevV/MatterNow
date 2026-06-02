namespace MatterNow.Application.Dtos.Notificacoes;

public class NotificacaoResponse
{
    public Guid Id { get; set; }
    public int Tipo { get; set; }
    public string Titulo { get; set; }
    public string Subtitulo { get; set; }
    public bool Lida { get; set; }
    public DateTime CriadoEm { get; set; }
}
