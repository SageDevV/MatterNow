using MatterNow.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace MatterNow.Application.Servicos;

/// Implementação para desenvolvimento — escreve o e-mail no log do servidor
/// em vez de enviar de fato. Isso permite testar todo o fluxo sem precisar de
/// SMTP configurado.
public class ConsoleEmailService : IEmailService
{
    private readonly ILogger<ConsoleEmailService> _logger;

    public ConsoleEmailService(ILogger<ConsoleEmailService> logger)
    {
        _logger = logger;
    }

    public Task EnviarCodigoRecuperacaoAsync(string destinatario, string nome, string codigo, CancellationToken ct = default)
    {
        _logger.LogWarning(
            "===== E-MAIL DE RECUPERAÇÃO (DEV) =====\nPara: {Destinatario}\nNome: {Nome}\nCódigo: {Codigo}\n=======================================",
            destinatario, nome, codigo);
        return Task.CompletedTask;
    }
}
