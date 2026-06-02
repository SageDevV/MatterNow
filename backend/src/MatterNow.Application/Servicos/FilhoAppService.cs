using MatterNow.Application.Dtos.Filhos;
using MatterNow.Application.Excecoes;
using MatterNow.Application.Interfaces;
using MatterNow.Domain.Entities;
using MatterNow.Domain.Repositories;

namespace MatterNow.Application.Servicos;

public class FilhoAppService : IFilhoAppService
{
    private readonly IFilhoRepository _repository;

    public FilhoAppService(IFilhoRepository repository)
    {
        _repository = repository;
    }

    public async Task<IReadOnlyList<FilhoResponse>> ListarAsync(Guid usuarioId, CancellationToken ct = default)
    {
        var filhos = await _repository.ListarPorUsuarioAsync(usuarioId, ct);
        return filhos.Select(Mapear).ToList();
    }

    public async Task<FilhoResponse> CriarAsync(Guid usuarioId, FilhoRequest request, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(request.Nome))
            throw new AuthException("Nome é obrigatório.", 400);

        var filho = new Filho(usuarioId, request.Nome);
        AplicarRequest(filho, request);
        await _repository.AdicionarAsync(filho, ct);
        await _repository.SalvarAsync(ct);
        return Mapear(filho);
    }

    public async Task<FilhoResponse> AtualizarAsync(Guid usuarioId, Guid filhoId, FilhoRequest request, CancellationToken ct = default)
    {
        var filho = await _repository.ObterPorIdAsync(filhoId, usuarioId, ct);
        if (filho == null) throw new AuthException("Filho não encontrado.", 404);

        AplicarRequest(filho, request);
        await _repository.SalvarAsync(ct);
        return Mapear(filho);
    }

    public async Task RemoverAsync(Guid usuarioId, Guid filhoId, CancellationToken ct = default)
    {
        var filho = await _repository.ObterPorIdAsync(filhoId, usuarioId, ct);
        if (filho == null) throw new AuthException("Filho não encontrado.", 404);
        await _repository.RemoverAsync(filho, ct);
        await _repository.SalvarAsync(ct);
    }

    private static void AplicarRequest(Filho filho, FilhoRequest r)
    {
        var genero = Enum.IsDefined(typeof(GeneroFilho), r.Genero)
            ? (GeneroFilho)r.Genero
            : GeneroFilho.NaoInformar;

        filho.Atualizar(
            nome: r.Nome,
            avatar: r.Avatar,
            dataNascimento: r.DataNascimento,
            faixaEtaria: r.FaixaEtaria,
            tamanhoRoupa: r.TamanhoRoupa,
            genero: genero,
            pesoKg: r.PesoKg
        );
    }

    private static FilhoResponse Mapear(Filho f) => new()
    {
        Id = f.Id,
        Nome = f.Nome,
        Avatar = f.Avatar,
        DataNascimento = f.DataNascimento,
        FaixaEtaria = f.FaixaEtaria,
        TamanhoRoupa = f.TamanhoRoupa,
        Genero = (int)f.Genero,
        PesoKg = f.PesoKg
    };
}
