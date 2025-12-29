using OpenApiGeneratorPlayground;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddControllers();

var host = builder.Build();
host.Run();
