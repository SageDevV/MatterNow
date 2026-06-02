using MatterNow.Domain.Entities;

namespace MatterNow.Application.Interfaces;

public interface ITokenService
{
    (string token, DateTime expiraEm) GerarToken(Usuario usuario);
}
