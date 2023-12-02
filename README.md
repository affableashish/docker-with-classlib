# docker-with-classlib
Containerizing a .NET 8 web api with a dependent class library.

[Reference](https://github.com/dotnet/dotnet-docker/tree/main/samples/complexapp).

## Create a simple web api project with a dependent class library
<img width="900" alt="image" src="https://github.com/affableashish/docker-with-classlib/assets/30603497/4e5d4512-e3e7-49ed-b263-a3686cc3d853">

Check out the code in this repo to see how simple this is. 😃

## Create Dockerfile
```dockerfile
# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# copy csproj files and restore as distinct layers
COPY "MyCoolTestApp.API/*.csproj" "MyCoolTestApp.API/"
COPY "MyCoolTestApp.Lib/*.csproj" "MyCoolTestApp.Lib/"
RUN dotnet restore "MyCoolTestApp.API/MyCoolTestApp.API.csproj"

# copy and build app and libraries
COPY "MyCoolTestApp.API/" "MyCoolTestApp.API/"
COPY "MyCoolTestApp.Lib/" "MyCoolTestApp.Lib/"
WORKDIR "/source/MyCoolTestApp.API"
RUN dotnet publish --no-restore -o /app

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "MyCoolTestApp.API.dll"]
```

## Create an image 
Run the command
```bash
docker build -f MyCoolTestApp.API.Dockerfile . -t akhanal/my-cool-api:0.1.1
```
### With `--no-restore` in publish step in Dockerfile
```dockerfile
RUN dotnet publish --no-restore -o /app
```

It fails with this error in the publish step:
```
 > [build 9/9] RUN dotnet publish --no-restore -o /app:
2.203 MSBuild version 17.8.3+195e7f5a3 for .NET
3.378 /usr/share/dotnet/sdk/8.0.100/Sdks/Microsoft.NET.Sdk/targets/Microsoft.PackageDependencyResolution.targets(266,5): error NETSDK1064: Package Microsoft.AspNetCore.OpenApi, version 8.0.0 was not found. It might have been deleted since NuGet restore. Otherwise, NuGet restore might have only partially completed, which might have been due to maximum path length restrictions. [/source/MyCoolTestApp.API/MyCoolTestApp.API.csproj]

ERROR: failed to solve: process "/bin/sh -c dotnet publish --no-restore -o /app" did not complete successfully: exit code: 1
```

### Without `--no-restore` in publish step in Dockerfile
```dockerfile
RUN dotnet publish -o /app
```

It succeeds:

<img width="750" alt="image" src="https://github.com/affableashish/docker-with-classlib/assets/30603497/15c31a17-b11e-42e1-a8d7-737114e12524">

### Question
Why does it fail with `--no-restore` flag in publish step? Shouldn't it succeed? I already restored packages during `dotnet restore "MyCoolTestApp.API/MyCoolTestApp.API.csproj"` step, so I don't want to restore it again during the publish step. Looks like I can't do that.
Is this by design or is it a bug?

To learn more about this, I opened an issue at dotnet/sdk github repo: https://github.com/dotnet/sdk/issues/37291

## Run the image
```bash
docker run --rm -it -p 8000:8080 -e ASPNETCORE_ENVIRONMENT=Development akhanal/my-cool-api:0.1.1
```

And navigate to Swagger index page and play around:

<img width="900" alt="image" src="https://github.com/affableashish/docker-with-classlib/assets/30603497/bcbbc2cf-5ca0-4fd7-b686-01300fdce838">
