using MailKit.Net.Smtp;
using MailKit.Security;
using MatterNow.Application.Configuracoes;
using MatterNow.Application.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MimeKit;

namespace MatterNow.Application.Servicos;

/// Envio real via SMTP (configurar em appsettings: Email:Host, Username, etc.).
public class SmtpEmailService : IEmailService
{
    private readonly EmailOptions _options;
    private readonly ILogger<SmtpEmailService> _logger;

    public SmtpEmailService(IOptions<EmailOptions> options, ILogger<SmtpEmailService> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public async Task EnviarCodigoRecuperacaoAsync(string destinatario, string nome, string codigo, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(_options.Host))
        {
            _logger.LogWarning("SMTP host não configurado — pulando envio para {Destinatario}.", destinatario);
            return;
        }

        var mensagem = new MimeMessage();
        mensagem.From.Add(new MailboxAddress(_options.FromName, _options.FromAddress));
        mensagem.To.Add(new MailboxAddress(nome ?? destinatario, destinatario));
        mensagem.Subject = "MatterNow — código de recuperação";
        mensagem.Body = new TextPart("plain")
        {
            Text = $"Olá!\n\nSeu código de recuperação é: {codigo}\n\nEle expira em 30 minutos.\n\nSe você não solicitou, ignore este e-mail.\n\n— MatterNow"
        };

        using var smtp = new SmtpClient();
        var socketOptions = _options.UseStartTls ? SecureSocketOptions.StartTls : SecureSocketOptions.Auto;
        await smtp.ConnectAsync(_options.Host, _options.Port, socketOptions, ct);
        if (!string.IsNullOrWhiteSpace(_options.Username))
            await smtp.AuthenticateAsync(_options.Username, _options.Password, ct);
        await smtp.SendAsync(mensagem, ct);
        await smtp.DisconnectAsync(true, ct);
    }
}
