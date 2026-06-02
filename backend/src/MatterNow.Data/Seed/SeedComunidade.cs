using MatterNow.Data.Contextos;
using MatterNow.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace MatterNow.Data.Seed;

/// Popula a comunidade com alguns anúncios mockados para o feed da home.
/// Roda uma única vez por banco — se já houver anúncios, não faz nada.
public static class SeedComunidade
{
    public static async Task ExecutarAsync(MatterNowDbContext ctx, CancellationToken ct = default)
    {
        if (await ctx.Anuncios.AnyAsync(ct)) return;

        // Cria um usuário "comunidade" fictício para ser autor dos posts mockados.
        var marina = new Usuario(
            nome: "Marina Silva",
            email: "marina.demo@matternow.test",
            telefone: null,
            senhaHash: "$2a$11$" + new string('x', 53)); // hash inválido, conta de demo
        var gabriela = new Usuario(
            nome: "Gabriela Costa",
            email: "gabriela.demo@matternow.test",
            telefone: null,
            senhaHash: "$2a$11$" + new string('x', 53));

        await ctx.Usuarios.AddRangeAsync(new[] { marina, gabriela }, ct);

        var anuncios = new[]
        {
            Configurar(new Anuncio(
                marina.Id,
                TipoAnuncio.Pergunta,
                "Dúvida sobre a rotina de sono do bebê de 4 meses: o que funciona?",
                "Tenho recebido várias dicas conflitantes e queria saber a opinião de outras mães.",
                valor: null,
                localizacao: null,
                fotoUrl: null,
                tag: "PERGUNTA"
            ), 1200, 84, 26),
            Configurar(new Anuncio(
                gabriela.Id,
                TipoAnuncio.Venda,
                "Vendo carrinho de passeio com 1 ano de uso",
                "Carrinho em ótimo estado, foi pouco usado. Acompanha bolsa.",
                valor: 250,
                localizacao: "Ipiranga",
                fotoUrl: null,
                tag: "VENDA"
            ), 1200, 84, 26),
            Configurar(new Anuncio(
                gabriela.Id,
                TipoAnuncio.Venda,
                "Carrinho Chicco",
                "Modelo 2023, completo.",
                valor: 250,
                localizacao: "Ipiranga",
                fotoUrl: null,
                tag: "VENDA"
            ), 0, 0, 0),
            Configurar(new Anuncio(
                marina.Id,
                TipoAnuncio.Venda,
                "Berço madeira novo",
                "Pinus, sem uso. Já montado.",
                valor: 190,
                localizacao: "Carvoeira",
                fotoUrl: null,
                tag: "VENDA"
            ), 0, 0, 0),
            Configurar(new Anuncio(
                gabriela.Id,
                TipoAnuncio.Venda,
                "Cadeirinha carro",
                "Cadeirinha 0-13kg. Acompanha base.",
                valor: 120,
                localizacao: "Carvoeira",
                fotoUrl: null,
                tag: "VENDA"
            ), 0, 0, 0)
        };

        await ctx.Anuncios.AddRangeAsync(anuncios, ct);
        await ctx.SaveChangesAsync(ct);
    }

    private static Anuncio Configurar(Anuncio a, int v, int c, int co)
    {
        a.DefinirMetricas(v, c, co);
        return a;
    }
}
