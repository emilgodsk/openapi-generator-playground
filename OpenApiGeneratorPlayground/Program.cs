using MyPackageServer.Another.Test;
using OpenApiGeneratorPlayground;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddControllers();

// var a = new Job();
// a.CompletedAt

var host = builder.Build();
host.Run();
