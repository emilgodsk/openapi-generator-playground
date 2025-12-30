using System.Net.Http;

namespace MyPackageClient.ThisIsTest.ManyOf.Them.ApiClients
{
    /// <summary>
    /// Any Api client
    /// </summary>
    public interface IApi
    {
        /// <summary>
        /// The HttpClient
        /// </summary>
        HttpClient HttpClient { get; }
    }
}