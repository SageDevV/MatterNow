using MatterNow.Application.Configuracoes;
using MatterNow.Application.Interfaces;
using MatterNow.Application.Servicos;
using MatterNow.Data.Contextos;
using MatterNow.Data.Repositorios;
using MatterNow.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace MatterNow.Ioc;

public static class DependencyInjection
{
    public static IServiceCollection AddMatterNow(this IServiceCollection services, IConfiguration configuration)
    {
        // Configurações
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));
        services.Configure<EmailOptions>(configuration.GetSection(EmailOptions.SectionName));

        // Banco — SQLite por padrão. Para PostgreSQL, troque para UseNpgsql e ajuste a connection string.
        var provider = configuration.GetValue<string>("Database:Provider") ?? "Sqlite";
        var connectionString = configuration.GetConnectionString("Default") ?? "Data Source=matternow.db";

        services.AddDbContext<MatterNowDbContext>(opt =>
        {
            if (string.Equals(provider, "Postgres", StringComparison.OrdinalIgnoreCase))
                opt.UseNpgsql(connectionString);
            else
                opt.UseSqlite(connectionString);
        });

        // Repositórios
        services.AddScoped<IUsuarioRepository, UsuarioRepository>();
        services.AddScoped<IFilhoRepository, FilhoRepository>();
        services.AddScoped<IAnuncioRepository, AnuncioRepository>();
        services.AddScoped<ITokenRecuperacaoSenhaRepository, TokenRecuperacaoSenhaRepository>();
        services.AddScoped<INotificacaoRepository, NotificacaoRepository>();

        // AppServices
        services.AddScoped<IAuthAppService, AuthAppService>();
        services.AddScoped<IUsuarioAppService, UsuarioAppService>();
        services.AddScoped<IFilhoAppService, FilhoAppService>();
        services.AddScoped<IFeedAppService, FeedAppService>();
        services.AddScoped<INotificacaoAppService, NotificacaoAppService>();
        services.AddSingleton<ITokenService, TokenService>();

        // Email — Console em dev (loga no terminal), Smtp em produção.
        var emailProvider = configuration.GetValue<string>("Email:Provider") ?? "Console";
        if (string.Equals(emailProvider, "Smtp", StringComparison.OrdinalIgnoreCase))
            services.AddScoped<IEmailService, SmtpEmailService>();
        else
            services.AddScoped<IEmailService, ConsoleEmailService>();

        return services;
    }
}
