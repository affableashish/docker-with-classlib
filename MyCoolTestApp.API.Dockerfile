# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY "MyCoolTestApp.API/*.csproj" "MyCoolTestApp.API/"
COPY "MyCoolTestApp.Lib/*.csproj" "MyCoolTestApp.Lib/"
RUN dotnet restore "MyCoolTestApp.API/MyCoolTestApp.API.csproj"

# copy and build app and libraries
COPY "MyCoolTestApp.API/" "MyCoolTestApp.API/"
COPY "MyCoolTestApp.Lib/" "MyCoolTestApp.Lib/"

FROM build AS publish
WORKDIR "/source/MyCoolTestApp.API"
RUN dotnet publish --no-restore -o /app

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "MunsonPickles.API.dll"]