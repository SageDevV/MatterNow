namespace MatterNow.Application.Excecoes;

public class AuthException : Exception
{
    public int StatusCode { get; }

    public AuthException(string mensagem, int statusCode = 400) : base(mensagem)
    {
        StatusCode = statusCode;
    }
}
