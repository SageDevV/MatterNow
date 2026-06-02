namespace MatterNow.Application.Interfaces;

public interface IEmailService
{
    Task EnviarCodigoRecuperacaoAsync(string destinatario, string nome, string codigo, CancellationToken ct = default);
}
