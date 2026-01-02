FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY src/JokeApi/JokeApi.csproj ./src/JokeApi/
RUN dotnet restore src/JokeApi/JokeApi.csproj
COPY . ./
RUN dotnet publish src/JokeApi/JokeApi.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0
ENV ASPNETCORE_URLS=http://+:8000
EXPOSE 8000
WORKDIR /app
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "JokeApi.dll"]
