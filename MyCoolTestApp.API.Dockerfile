# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS build
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
FROM mcr.microsoft.com/dotnet/nightly/aspnet:8.0-jammy-chiseled-composite
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["./MyCoolTestApp.API"]